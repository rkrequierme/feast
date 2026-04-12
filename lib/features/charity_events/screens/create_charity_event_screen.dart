import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class CreateCharityEventScreen extends StatefulWidget {
  const CreateCharityEventScreen({super.key});

  @override
  State<CreateCharityEventScreen> createState() =>
      _CreateCharityEventScreenState();
}

class _CreateCharityEventScreenState
    extends State<CreateCharityEventScreen> {
  bool _agreedToTerms = false;

  // ── Draft tracking ─────────────────────────────────────────────────────────
  bool _isDirty = false;
  bool _hasDraft = false;

  // ─── Controllers ───────────────────────────────────────────────────────────
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _callTimeController    = TextEditingController();
  final _typeController        = TextEditingController(text: 'Fundraiser');
  final _categoryController    = TextEditingController(text: 'Disaster Management');
  final _locationController    = TextEditingController();
  final _goalController        = TextEditingController();
  final _itemsController       = TextEditingController();

  // ─── Dropdown options ──────────────────────────────────────────────────────
  final List<String> _eventTypes = [
    'Fundraiser',
    'Feeding Program',
    'Relief Operation',
    'Community Drive',
    'Mixed',
  ];
  final List<String> _eventCategories = [
    'Disaster Management',
    'Health (Support & Supply)',
    'Education (Fundraise)',
    'Basic Needs (& Aid)',
    'Household (Support)',
    'Community (Support & Aid)',
  ];

  @override
  void initState() {
    super.initState();
    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }
  }

  List<TextEditingController> get _allControllers => [
        _titleController,
        _descriptionController,
        _callTimeController,
        _typeController,
        _categoryController,
        _locationController,
        _goalController,
        _itemsController,
      ];

  void _onFieldChanged() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  // ── Guard back navigation ──────────────────────────────────────────────────

  bool get _canLeaveFreely => !_isDirty || _hasDraft;

  void _handleBackAttempt() {
    if (_canLeaveFreely) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => UnsavedChangesDialog(
        onLeave: () => Navigator.pop(context),
      ),
    );
  }

  // ── Save draft ─────────────────────────────────────────────────────────────

  void _saveDraft() {
    // TODO: Persist to SharedPreferences / Hive / Firestore
    // drafts/{uid}/charity_event_draft
    setState(() {
      _isDirty = false;
      _hasDraft = true;
    });
    _showSnackbar('Draft saved.');
  }

  // ── Reset form ─────────────────────────────────────────────────────────────

  void _resetForm() {
    showDialog(
      context: context,
      builder: (_) => ResetFormDialog(
        bodyText:
            'Are you sure you want to reset the contents or field data of this charity event form?',
        onConfirm: () {
          _titleController.clear();
          _descriptionController.clear();
          _callTimeController.clear();
          _typeController.text = 'Fundraiser';
          _categoryController.text = 'Disaster Management';
          _locationController.clear();
          _goalController.clear();
          _itemsController.clear();
          setState(() {
            _agreedToTerms = false;
            _isDirty = false;
            _hasDraft = false;
          });
          _showSnackbar('Form has been reset.');
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBackAttempt();
      },
      child: Scaffold(
        appBar: const FeastAppBar(title: 'Organize Charity Event'),
        drawer: const FeastDrawer(username: 'Juan De La Cruz'),
        body: FeastBackground(
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildTopActionBar(),
                  const SizedBox(height: 8),
                  _buildWarningBanner(),
                  const SizedBox(height: 16),
                  _buildImageUploadSection(),
                  const SizedBox(height: 20),
                  _buildFormSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const FeastBottomNav(currentIndex: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── TOP ACTION BAR ───
  // ═══════════════════════════════════════════════════
  Widget _buildTopActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.arrow_back,
            onTap: _handleBackAttempt,
          ),
          Row(
            children: [
              _buildCircleButton(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                onTap: _resetForm,
              ),
              const SizedBox(width: 8),
              _buildCircleButton(
                icon: Icons.save_outlined,
                iconColor: _isDirty ? feastGreen : feastGray.withAlpha(140),
                onTap: _saveDraft,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── WARNING BANNER ───
  // ═══════════════════════════════════════════════════
  Widget _buildWarningBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Outfit',
                  color: feastBlack,
                ),
                children: [
                  TextSpan(
                    text: 'WARNING: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  TextSpan(
                    text: 'Edits CANNOT be made after posting.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── IMAGE UPLOAD SECTION ───
  // ═══════════════════════════════════════════════════
  Widget _buildImageUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: feastLighterBlue.withAlpha(60),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: feastLightBlue.withAlpha(100), width: 1.5),
            ),
            child: Center(
              child: Icon(Icons.image_outlined,
                  size: 56, color: feastBlue.withAlpha(120)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                3,
                (i) => Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: feastLighterBlue.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: feastLightBlue.withAlpha(80), width: 1),
                  ),
                  child: Icon(Icons.image_outlined,
                      size: 20, color: feastBlue.withAlpha(80)),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: image picker
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: feastLightGreen, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 16, color: feastGreen),
                      const SizedBox(width: 6),
                      const Text(
                        'Upload\nPhoto',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          color: feastGreen,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── FORM SECTION ───
  // ═══════════════════════════════════════════════════
  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Charity Event Title',
              hintText: 'Flood Relief Project',
              prefixIcon: Icons.title,
              controller: _titleController,
            ),
          ),
          const SizedBox(height: 16),

          _buildDescriptionField(),
          const SizedBox(height: 16),

          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Call Time of Charity',
              hintText: 'Insert Date & Time',
              prefixIcon: Icons.schedule,
              controller: _callTimeController,
              trailingAction: TrailingAction.datePicker,
            ),
          ),
          const SizedBox(height: 16),

          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Charity Event Type',
              hintText: 'Select Type',
              prefixIcon: Icons.category_outlined,
              controller: _typeController,
              trailingAction: TrailingAction.dropdown,
              onDropdownTap: () => _showDropdown(
                title: 'Charity Event Type',
                options: _eventTypes,
                controller: _typeController,
              ),
            ),
          ),
          const SizedBox(height: 16),

          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Charity Event Category',
              hintText: 'Select Category',
              prefixIcon: Icons.list_alt_outlined,
              controller: _categoryController,
              trailingAction: TrailingAction.dropdown,
              onDropdownTap: () => _showDropdown(
                title: 'Charity Event Category',
                options: _eventCategories,
                controller: _categoryController,
              ),
            ),
          ),
          const SizedBox(height: 16),

          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Location',
              hintText: 'BF Almanza, Almanza Dos',
              prefixIcon: Icons.location_on_outlined,
              controller: _locationController,
            ),
          ),
          const SizedBox(height: 16),

          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Fundraiser Goal',
              hintText: '₱1,000',
              prefixIcon: Icons.attach_money,
              controller: _goalController,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),

          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Accepted / Wanted Items',
              hintText:
                  'First Aid Relief, Food, Clothes & No Beer or Cigarettes',
              prefixIcon: Icons.inventory_2_outlined,
              controller: _itemsController,
            ),
          ),
          const SizedBox(height: 24),

          _buildTermsCheckbox(),
          const SizedBox(height: 20),

          FeastButton(
            text: 'CREATE CHARITY EVENT',
            onPressed: _agreedToTerms
                ? () {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmationModal(
                        title: 'Create Aid Request',
                        body:
                            'Are you sure you want to proceed with posting the aid request?',
                        boldNote:
                            'REMEMBER: You cannot edit your post or take it down after a certain amount of time has passed.',
                        onYes: () {
                          Navigator.of(context).pop(); // Close modal
                          // TODO: Submit to Firebase
                        },
                      ),
                    );
                  }
                : null,
          ),

          const SizedBox(height: 16),
          _buildFinalWarning(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── DESCRIPTION FIELD ───
  // ═══════════════════════════════════════════════════
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: 'Charity Event Description'),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, fontFamily: 'Outfit'),
            decoration: InputDecoration(
              hintText: 'Insert Description Here...',
              hintStyle: const TextStyle(
                  color: Colors.grey, fontSize: 14, fontFamily: 'Outfit'),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child:
                    Icon(Icons.description_outlined, color: Colors.black54),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── TERMS CHECKBOX ───
  // ═══════════════════════════════════════════════════
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (v) =>
                setState(() => _agreedToTerms = v ?? false),
            activeColor: feastGreen,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () =>
              setState(() => _agreedToTerms = !_agreedToTerms),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 13, fontFamily: 'Outfit', color: feastBlack),
              children: [
                TextSpan(text: "I've read the "),
                TextSpan(
                  text: 'terms and conditions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: feastGreen,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── FINAL WARNING ───
  // ═══════════════════════════════════════════════════
  Widget _buildFinalWarning() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: feastLightYellow.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: feastOrange.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FINAL WARNING:',
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                color: Colors.red),
          ),
          const SizedBox(height: 4),
          Text(
            '•  Edits CANNOT be made after posting.\n'
            '•  Charity event CANNOT be removed after\n'
            '   a certain duration OR donors have accepted.',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w500,
              color: feastGray.withAlpha(220),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── HELPERS ───
  // ═══════════════════════════════════════════════════
  Widget _buildCircleButton({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor ?? feastBlack),
      ),
    );
  }

  void _showDropdown({
    required String title,
    required List<String> options,
    required TextEditingController controller,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  color: feastBlack),
            ),
            const SizedBox(height: 12),
            ...options.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Outfit',
                    color: controller.text == option
                        ? feastGreen
                        : feastBlack,
                    fontWeight: controller.text == option
                        ? FontWeight.bold
                        : FontWeight.w400,
                  ),
                ),
                trailing: controller.text == option
                    ? const Icon(Icons.check, color: feastGreen, size: 20)
                    : null,
                onTap: () {
                  setState(() => controller.text = option);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}