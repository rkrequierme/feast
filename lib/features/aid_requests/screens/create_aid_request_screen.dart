import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class CreateAidRequestScreen extends StatefulWidget {
  const CreateAidRequestScreen({super.key});

  @override
  State<CreateAidRequestScreen> createState() => _CreateAidRequestScreenState();
}

class _CreateAidRequestScreenState extends State<CreateAidRequestScreen> {
  bool _agreedToTerms = false;

  // ─── Controllers ───
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _typeController = TextEditingController(text: 'Fundraiser');
  final _categoryController = TextEditingController(text: 'Disaster Management');
  final _locationController = TextEditingController();
  final _goalController = TextEditingController();
  final _itemsController = TextEditingController();

  // ─── Dropdown options ───
  final List<String> _requestTypes = [
    'Fundraiser',
    'Item Donation',
    'Volunteering',
    'Mixed',
  ];
  final List<String> _requestCategories = [
    'Disaster Management',
    'Health (Support & Supply)',
    'Education (Fundraise)',
    'Basic Needs (& Aid)',
    'Household (Support)',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _typeController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _goalController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Create Aid Request'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      body: FeastBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ─── Top Action Bar ───
                _buildTopActionBar(),

                const SizedBox(height: 8),

                // ─── Warning Banner ───
                _buildWarningBanner(),

                const SizedBox(height: 16),

                // ─── Image Upload Section ───
                _buildImageUploadSection(),

                const SizedBox(height: 20),

                // ─── Form Section ───
                _buildFormSection(),

                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FeastBottomNav(currentIndex: 1),
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
          // Back button
          _buildCircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
          Row(
            children: [
              // Delete / Discard button
              _buildCircleButton(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                onTap: () {
                  // Discard action
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 8),
              // Save draft button
              _buildCircleButton(
                icon: Icons.save_outlined,
                iconColor: feastGreen,
                onTap: () {
                  // Save draft action
                },
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
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
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
          // Main image placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: feastLightGreen.withAlpha(60),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: feastLightGreen, width: 1.5),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 56,
                color: feastGreen.withAlpha(120),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Thumbnail row + upload button
          Row(
            children: [
              // Thumbnail placeholders
              ...List.generate(
                3,
                (i) => Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: feastLightGreen.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: feastLightGreen.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: feastGreen.withAlpha(80),
                  ),
                ),
              ),
              const Spacer(),
              // Upload button
              GestureDetector(
                onTap: () {
                  // Upload action
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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
          // Aid Request Title
          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Aid Request Title',
              hintText: 'Help Flood Victim in Almanza Dos',
              prefixIcon: Icons.title,
              controller: _titleController,
            ),
          ),
          const SizedBox(height: 16),

          // Aid Request Description
          _buildDescriptionField(),
          const SizedBox(height: 16),

          // Post Duration
          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Post Duration',
              hintText: 'Insert No. of Days',
              prefixIcon: Icons.timer_outlined,
              controller: _durationController,
              trailingAction: TrailingAction.datePicker,
            ),
          ),
          const SizedBox(height: 16),

          // Aid Request Type
          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Aid Request Type',
              hintText: 'Select Type',
              prefixIcon: Icons.category_outlined,
              controller: _typeController,
              trailingAction: TrailingAction.dropdown,
              onDropdownTap: () => _showDropdown(
                title: 'Aid Request Type',
                options: _requestTypes,
                controller: _typeController,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Aid Request Category
          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Aid Request Category',
              hintText: 'Select Category',
              prefixIcon: Icons.list_alt_outlined,
              controller: _categoryController,
              trailingAction: TrailingAction.dropdown,
              onDropdownTap: () => _showDropdown(
                title: 'Aid Request Category',
                options: _requestCategories,
                controller: _categoryController,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location
          LabeledTextField(
            config: LabeledTextFieldConfig(
              label: 'Location',
              hintText: 'BF Almanza, Almanza Dos',
              prefixIcon: Icons.location_on_outlined,
              controller: _locationController,
            ),
          ),
          const SizedBox(height: 16),

          // Fundraiser Goal
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

          // Accepted / Wanted Items
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

          // ─── Terms Checkbox ───
          _buildTermsCheckbox(),

          const SizedBox(height: 20),

          // ─── Submit Button ───
          FeastButton(
            text: 'CREATE AID REQUEST',
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

          // ─── Final Warning ───
          _buildFinalWarning(),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ─── DESCRIPTION FIELD (multiline) ───
  // ═══════════════════════════════════════════════════
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: 'Aid Request Description'),
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
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Outfit',
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Icon(Icons.description_outlined, color: Colors.black54),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
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
            onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
            activeColor: feastGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Outfit',
                color: feastBlack,
              ),
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
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '•  Edits CANNOT be made after posting.\n'
            '•  Aid request CANNOT be removed after a\n'
            '   certain duration OR donors have accepted.',
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
  // ─── HELPER WIDGETS ───
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
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
            ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                color: feastBlack,
              ),
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
                    color: controller.text == option ? feastGreen : feastBlack,
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
