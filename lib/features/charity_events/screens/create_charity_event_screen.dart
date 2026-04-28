// lib/features/charity_events/screens/create_charity_event_screen.dart
//
// Form to create a charity event. Saves draft to Firestore, submits for admin approval.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:feast/core/core.dart';

class CreateCharityEventScreen extends StatefulWidget {
  const CreateCharityEventScreen({super.key});

  @override
  State<CreateCharityEventScreen> createState() =>
      _CreateCharityEventScreenState();
}

class _CreateCharityEventScreenState extends State<CreateCharityEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coOrganiserController = TextEditingController();

  String _selectedCategory = 'Health';
  String _selectedLocation = 'BF Almanza, Almanza Dos';
  DateTime? _startTime;
  DateTime? _endTime;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  bool _isDirty = false;
  bool _hasDraft = false;

  final List<File> _selectedImages = [];
  final List<String> _coOrganiserIds = [];

  final List<String> _categories = [
    'Health',
    'Education',
    'Disaster Management',
    'Basic Needs',
    'Household',
  ];
  final List<String> _locations = [
    'BF Almanza, Almanza Dos',
    'DBP Village, Almanza Dos',
    'T.S. Cruz, Almanza Dos',
    'Almanza Dos, Las Piñas City',
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
    for (final c in [_titleController, _descriptionController]) {
      c.addListener(() {
        if (!_isDirty) setState(() => _isDirty = true);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coOrganiserController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await FirestoreService.instance.loadDraft('charity_events');
    if (draft != null && mounted) {
      setState(() {
        _titleController.text = draft['title'] ?? '';
        _descriptionController.text = draft['description'] ?? '';
        _selectedCategory = draft['category'] ?? 'Health';
        _selectedLocation = draft['location'] ?? 'BF Almanza, Almanza Dos';
        if (draft['startTime'] != null) {
          _startTime = DateTime.parse(draft['startTime']);
        }
        if (draft['endTime'] != null) {
          _endTime = DateTime.parse(draft['endTime']);
        }
        _coOrganiserIds.addAll(List<String>.from(draft['coOrganiserIds'] ?? []));
        _hasDraft = true;
        _isDirty = false;
      });
    }
  }

  Future<void> _saveDraft() async {
    try {
      await FirestoreService.instance.saveDraft(
        {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _selectedCategory,
          'location': _selectedLocation,
          'startTime': _startTime?.toIso8601String(),
          'endTime': _endTime?.toIso8601String(),
          'coOrganiserIds': _coOrganiserIds,
        },
        'charity_events',
      );
      if (!mounted) return;
      setState(() {
        _isDirty = false;
        _hasDraft = true;
      });
      FeastToast.showSuccess(context, 'Draft saved.');
    } catch (_) {
      if (!mounted) return;
      FeastToast.showError(context, 'Failed to save draft. Try again.');
    }
  }

  Future<void> _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _isDirty = true;
    });
  }

  Future<void> _pickEndTime() async {
    if (_startTime == null) {
      FeastToast.showError(context, 'Pick start time first.');
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime!.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    final proposed = DateTime(_startTime!.year, _startTime!.month, _startTime!.day, time.hour, time.minute);
    final diff = proposed.difference(_startTime!);
    if (diff.inMinutes < 1) {
      FeastToast.showError(context, 'End time must be after start time.');
      return;
    }
    if (diff.inHours > 12) {
      FeastToast.showError(context, 'Maximum event duration is 12 hours.');
      return;
    }
    setState(() {
      _endTime = proposed;
      _isDirty = true;
    });
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      allowMultiple: true,
    );
    if (result == null) return;
    setState(() {
      _selectedImages.addAll(result.files.where((f) => f.path != null).map((f) => File(f.path!)));
      _isDirty = true;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _isDirty = true;
    });
  }

  void _addCoOrganiser() {
    final name = _coOrganiserController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _coOrganiserIds.add(name);
        _coOrganiserController.clear();
        _isDirty = true;
      });
    }
  }

  void _removeCoOrganiser(int index) {
    setState(() {
      _coOrganiserIds.removeAt(index);
      _isDirty = true;
    });
  }

  void _resetForm() {
    showDialog(
      context: context,
      builder: (_) => ResetFormDialog(
        onConfirm: () {
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedCategory = 'Health';
            _selectedLocation = 'BF Almanza, Almanza Dos';
            _startTime = null;
            _endTime = null;
            _selectedImages.clear();
            _coOrganiserIds.clear();
            _agreedToTerms = false;
            _isDirty = false;
            _hasDraft = false;
          });
          FirestoreService.instance.deleteDraft('charity_events');
          FeastToast.showSuccess(context, 'Form reset.');
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      FeastToast.showError(context, 'At least one image is required.');
      return;
    }
    if (_startTime == null || _endTime == null) {
      FeastToast.showError(context, 'Event start and end times are required.');
      return;
    }
    if (_coOrganiserIds.isEmpty) {
      FeastToast.showError(context, 'At least one co-organiser is required.');
      return;
    }
    if (!_agreedToTerms) {
      FeastToast.showError(context, 'Please accept the Terms & Conditions.');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ConfirmationModal(
        title: 'Create Charity Event',
        body: 'Proceed with posting this charity event?',
        boldNote: 'Edits CANNOT be made after posting. Event CANNOT be removed after a certain duration OR participants have accepted.',
        onYes: () async {
          Navigator.pop(context);
          await _doSubmit();
        },
      ),
    );
  }

  Future<void> _doSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final user = await FirestoreService.instance.getCurrentUser();
      final fullName = user?['displayName'] ?? user?['firstName'] ?? 'Anonymous';

      final ref = await FirestoreService.instance.createCharityEvent({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'location': _selectedLocation,
        'startTime': Timestamp.fromDate(_startTime!),
        'endTime': Timestamp.fromDate(_endTime!),
        'coOrganiserIds': _coOrganiserIds,
        'organiserName': fullName,
        'imageUrls': [],
      });

      if (_selectedImages.isNotEmpty) {
        final urls = await StorageService.instance.uploadPostImages(
          _selectedImages,
          'charity_events',
          ref.id,
        );
        await ref.update({'imageUrls': urls});
      }

      await FirestoreService.instance.deleteDraft('charity_events');

      if (!mounted) return;
      FeastToast.showSuccess(context, 'Event submitted for admin approval.');
      Navigator.pushReplacementNamed(context, AppRoutes.charityEvents);
    } catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, 'Submission failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty || _hasDraft,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isDirty && !_hasDraft) {
          showDialog(
            context: context,
            builder: (_) => ConfirmationModal(
              title: 'Unsaved Changes',
              body: 'You have unsaved changes. Save as draft before leaving?',
              yesLabel: 'Save Draft',
              noLabel: 'Discard',
              onYes: () async {
                Navigator.pop(context);
                await _saveDraft();
                if (mounted) Navigator.pop(context);
              },
              onNo: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          );
        }
      },
      child: Scaffold(
        appBar: const FeastAppBar(title: 'Organise Charity Event'),
        body: FeastBackground(
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _iconBtn(Icons.arrow_back, () => Navigator.pop(context)),
                        Row(children: [
                          _iconBtn(Icons.delete_outline, _resetForm, color: Colors.red),
                          const SizedBox(width: 8),
                          _iconBtn(Icons.save_outlined, _saveDraft, color: _isDirty ? feastBlue : feastGray),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _warningBanner('WARNING: Edits CANNOT be made after posting.'),
                    const SizedBox(height: 16),
                    _buildImageSection(),
                    const SizedBox(height: 20),
                    _buildField('Charity Event Title', _titleController, Icons.title),
                    const SizedBox(height: 16),
                    _buildMultiline('Charity Event Description', _descriptionController),
                    const SizedBox(height: 16),
                    _buildTimePicker(label: 'Start Time', value: _startTime != null ? DateFormat('MMM d, y – h:mm a').format(_startTime!) : null, onTap: _pickStartTime),
                    const SizedBox(height: 16),
                    _buildTimePicker(label: 'End Time (same day, max 12h)', value: _endTime != null ? DateFormat('h:mm a').format(_endTime!) : null, onTap: _pickEndTime),
                    const SizedBox(height: 16),
                    _buildDropdown('Event Category', _selectedCategory, _categories, (v) => setState(() => _selectedCategory = v!)),
                    const SizedBox(height: 16),
                    _buildDropdown('Location', _selectedLocation, _locations, (v) => setState(() => _selectedLocation = v!)),
                    const SizedBox(height: 16),
                    _buildField('Add Co-Organiser (search by name)', _coOrganiserController, Icons.person_add_alt),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _addCoOrganiser,
                      style: ElevatedButton.styleFrom(backgroundColor: feastBlue),
                      child: const Text('Add Co-Organiser', style: TextStyle(color: Colors.white)),
                    ),
                    if (_coOrganiserIds.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _coOrganiserIds.asMap().entries.map((entry) {
                          final index = entry.key;
                          final id = entry.value;
                          return Chip(
                            label: Text(id, style: const TextStyle(fontFamily: 'Outfit')),
                            onDeleted: () => _removeCoOrganiser(index),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FeastCheckbox(
                      text: "I've read the terms and conditions.",
                      value: _agreedToTerms,
                      linkText: 'terms and conditions',
                      onLinkTap: () => Navigator.pushNamed(context, AppRoutes.legal),
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                    ),
                    const SizedBox(height: 20),
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator(color: feastBlue))
                        : ElevatedButton(
                            onPressed: _agreedToTerms ? _submit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: feastBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: const Text('CREATE CHARITY EVENT', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: feastLighterBlue.withAlpha(60),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: feastBlue.withAlpha(60)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FINAL WARNING:', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.red)),
                          SizedBox(height: 4),
                          Text(
                            '• Edits CANNOT be made after posting.\n'
                            '• Charity event CANNOT be removed after a certain duration OR participants have accepted.',
                            style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: feastGray, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const FeastBottomNav(currentIndex: 2),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: feastLighterBlue.withAlpha(40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: feastLightBlueAccent, width: 1.5),
        ),
        child: _selectedImages.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: feastBlue),
                  const SizedBox(height: 8),
                  const Text('Tap to upload images', style: TextStyle(fontFamily: 'Outfit', color: feastGray)),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_selectedImages.first, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: feastError, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          validator: (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black54, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiline(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          maxLines: 4,
          validator: (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontFamily: 'Outfit')))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimePicker({required String label, required String? value, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.black54, size: 20),
                const SizedBox(width: 12),
                Text(
                  value ?? 'Select date & time',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: value != null ? feastBlack : Colors.grey,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.calendar_month_outlined, color: Colors.black54, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6)],
        ),
        child: Icon(icon, size: 20, color: color ?? feastBlack),
      ),
    );
  }

  Widget _warningBanner(String message) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Text(message, style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red))),
      ],
    );
  }
}
