// lib/features/aid_requests/screens/create_aid_request_screen.dart
//
// Resident-only form to create an aid request.
// Saves draft to Firestore, submits for admin approval.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:feast/core/core.dart';
import 'package:feast/core/services/firestore_service.dart';
import 'package:feast/core/services/storage_service.dart';

class CreateAidRequestScreen extends StatefulWidget {
  const CreateAidRequestScreen({super.key});

  @override
  State<CreateAidRequestScreen> createState() =>
      _CreateAidRequestScreenState();
}

class _CreateAidRequestScreenState
    extends State<CreateAidRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  bool _isDirty = false;
  bool _hasDraft = false;

  // ── Controllers ──────────────────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  final _itemsController = TextEditingController();

  // ── Dropdown values ───────────────────────────────────────────────────────
  String _selectedType = 'Fundraiser';
  String _selectedCategory = 'Health';
  String _selectedLocation = 'BF Almanza, Almanza Dos';
  int _postDurationDays = 7;

  final List<String> _requestTypes = [
    'Fundraiser',
    'In-Kind',
    'Supply & Support',
  ];
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

  // ── Images ───────────────────────────────────────────────────────────────
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    for (final c in [
      _titleController,
      _descriptionController,
      _goalController,
      _itemsController,
    ]) {
      c.addListener(() {
        if (!_isDirty) setState(() => _isDirty = true);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  // ── Image Picker ─────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      allowMultiple: true,
    );
    if (result == null) return;
    setState(() {
      _selectedImages.addAll(
        result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!)),
      );
      _isDirty = true;
    });
  }

  // ── Save Draft ────────────────────────────────────────────────────────────

  Future<void> _saveDraft() async {
    try {
      await FirestoreService.instance.saveDraft(
        {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'aidType': _selectedType,
          'category': _selectedCategory,
          'location': _selectedLocation,
          'postDurationDays': _postDurationDays,
          'fundraiserGoal': double.tryParse(_goalController.text) ?? 0,
          'acceptedItems': _itemsController.text.trim(),
        },
        'aid_requests',
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

  // ── Reset Form ────────────────────────────────────────────────────────────

  void _resetForm() {
    showDialog(
      context: context,
      builder: (_) => ResetFormDialog(
        onConfirm: () {
          _titleController.clear();
          _descriptionController.clear();
          _goalController.clear();
          _itemsController.clear();
          setState(() {
            _selectedType = 'Fundraiser';
            _selectedCategory = 'Health';
            _selectedLocation = 'BF Almanza, Almanza Dos';
            _postDurationDays = 7;
            _selectedImages.clear();
            _agreedToTerms = false;
            _isDirty = false;
            _hasDraft = false;
          });
        },
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      FeastToast.showError(context, 'Please upload at least one image.');
      return;
    }
    if (!_agreedToTerms) {
      FeastToast.showError(context, 'Please accept the Terms & Conditions.');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ConfirmationModal(
        title: 'Create Aid Request',
        body: 'Are you sure you want to proceed with posting this aid request?',
        boldNote:
            'REMEMBER: You cannot edit your post or take it down after a certain amount of time has passed.',
        onYes: () async {
          Navigator.of(context).pop();
          await _doSubmit();
        },
      ),
    );
  }

  Future<void> _doSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      // 1. Create aid request doc to get its ID
      final ref = await FirestoreService.instance.createAidRequest({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'aidType': _selectedType,
        'category': _selectedCategory,
        'location': _selectedLocation,
        'postDurationDays': _postDurationDays,
        'fundraiserGoal':
            double.tryParse(_goalController.text) ?? 0,
        'acceptedItems': _itemsController.text.trim(),
        'expiresAt': DateTime.now()
            .add(Duration(days: _postDurationDays))
            .toIso8601String(),
        'imageUrls': [], // placeholder; updated below
      });

      // 2. Upload images
      final urls = await StorageService.instance.uploadPostImages(
        _selectedImages,
        'aid_requests',
        ref.id,
      );

      // 3. Update doc with real image URLs
      await ref.update({'imageUrls': urls});

      if (!mounted) return;
      FeastToast.showSuccess(
        context,
        'Aid request submitted for admin approval.',
      );
      Navigator.pushReplacementNamed(context, AppRoutes.aidRequests);
    } catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, 'Submission failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty || _hasDraft,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (_) => ConfirmationModal(
              title: 'Unsaved Changes',
              body: 'You have unsaved changes. Save as draft before leaving?',
              onYes: () async {
                Navigator.pop(context);
                await _saveDraft();
                if (!mounted) return;
                Navigator.pop(context);
              },
            ),
          );
        }
      },
      child: Scaffold(
        appBar: const FeastAppBar(title: 'Create Aid Request'),
        body: FeastBackground(
          child: SafeArea(
            bottom: false,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Top action bar ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _iconBtn(Icons.arrow_back,
                            () => Navigator.pop(context)),
                        Row(children: [
                          _iconBtn(Icons.delete_outline,
                              _resetForm, color: Colors.red),
                          const SizedBox(width: 8),
                          _iconBtn(Icons.save_outlined, _saveDraft,
                              color: _isDirty ? feastGreen : feastGray),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Warning banner
                    _warningBanner(
                        'WARNING: Edits CANNOT be made after posting.'),
                    const SizedBox(height: 16),

                    // ── Images ─────────────────────────────────────
                    _buildImageSection(),
                    const SizedBox(height: 20),

                    // ── Title ──────────────────────────────────────
                    _buildField(
                      label: 'Aid Request Title',
                      controller: _titleController,
                      hint: 'Help Flood Victims in Almanza Dos',
                      icon: Icons.title,
                      maxLength: 120,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Description ────────────────────────────────
                    _buildMultilineField(
                      label: 'Aid Request Description',
                      controller: _descriptionController,
                      hint: 'Describe your situation...',
                      maxLength: 1000,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ── Post Duration ──────────────────────────────
                    _buildDropdown(
                      label: 'Post Duration (Days)',
                      value: _postDurationDays.toString(),
                      items: ['3', '5', '7', '14', '30'],
                      icon: Icons.timer_outlined,
                      onChanged: (v) => setState(
                          () => _postDurationDays = int.parse(v!)),
                    ),
                    const SizedBox(height: 16),

                    // ── Aid Request Type ───────────────────────────
                    _buildDropdown(
                      label: 'Aid Request Type',
                      value: _selectedType,
                      items: _requestTypes,
                      icon: Icons.category_outlined,
                      onChanged: (v) =>
                          setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 16),

                    // ── Category ───────────────────────────────────
                    _buildDropdown(
                      label: 'Aid Request Category',
                      value: _selectedCategory,
                      items: _categories,
                      icon: Icons.list_alt_outlined,
                      onChanged: (v) =>
                          setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),

                    // ── Location ───────────────────────────────────
                    _buildDropdown(
                      label: 'Location',
                      value: _selectedLocation,
                      items: _locations,
                      icon: Icons.location_on_outlined,
                      onChanged: (v) =>
                          setState(() => _selectedLocation = v!),
                    ),
                    const SizedBox(height: 16),

                    // ── Fundraiser Goal (conditional) ──────────────
                    if (_selectedType == 'Fundraiser' ||
                        _selectedType == 'Supply & Support') ...[
                      _buildField(
                        label: 'Fundraiser Goal (₱)',
                        controller: _goalController,
                        hint: '5000',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Goal amount is required';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Accepted Items (conditional) ───────────────
                    if (_selectedType == 'In-Kind' ||
                        _selectedType == 'Supply & Support') ...[
                      _buildField(
                        label: 'Accepted / Wanted Items',
                        controller: _itemsController,
                        hint: 'Food, Clothes, Medicine...',
                        icon: Icons.inventory_2_outlined,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please specify accepted items'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── T&C ────────────────────────────────────────
                    FeastCheckbox(
                      text: "I've read the terms and conditions.",
                      value: _agreedToTerms,
                      linkText: 'terms and conditions',
                      onLinkTap: () =>
                          Navigator.pushNamed(context, AppRoutes.legal),
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),
                    const SizedBox(height: 20),

                    // ── Create Button ──────────────────────────────
                    _isSubmitting
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: feastGreen))
                        : FeastButton(
                            text: 'CREATE AID REQUEST',
                            onPressed:
                                _agreedToTerms ? _submit : null,
                          ),
                    const SizedBox(height: 16),

                    // ── Final Warning ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: feastLightYellow.withAlpha(120),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: feastOrange.withAlpha(60)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FINAL WARNING:',
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                          SizedBox(height: 4),
                          Text(
                            '• Edits CANNOT be made after posting.\n'
                            '• Aid request CANNOT be removed after a certain duration OR donors have accepted.',
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: feastGray,
                                height: 1.4),
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
        bottomNavigationBar: const FeastBottomNav(currentIndex: 1),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: feastLightGreen.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: feastLightGreen, width: 1.5),
            ),
            child: _selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 48,
                          color: feastGreen.withAlpha(120)),
                      const SizedBox(height: 8),
                      const Text('Tap to upload images',
                          style: TextStyle(
                              fontFamily: 'Outfit', color: feastGray)),
                      const Text('JPG, JPEG, PNG, WEBP, GIF',
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              color: feastGray)),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_selectedImages.first,
                        fit: BoxFit.cover),
                  ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              itemBuilder: (_, i) {
                if (i == _selectedImages.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: feastLightGreen),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: feastGreen),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImages[i],
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _selectedImages.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: feastError,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.black54, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultilineField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: 5,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black54, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          items: items
              .map((i) => DropdownMenuItem(
                    value: i,
                    child: Text(i,
                        style: const TextStyle(
                            fontFamily: 'Outfit', fontSize: 14)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 20, color: color ?? feastBlack),
      ),
    );
  }

  Widget _warningBanner(String message) {
    return Row(
      children: [
        const Icon(Icons.warning_amber_rounded,
            color: Colors.red, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red),
          ),
        ),
      ],
    );
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : aid_requests
// Write     : addDoc(collection(db,'aid_requests'), { ...data, status:'pending' })
// Images    : uploadBytes(ref(storage,'aid_requests/{id}/{uuid}.ext'), file)
// Draft     : addDoc(collection(db,'drafts'), { ...data, collection:'aid_requests' })
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
