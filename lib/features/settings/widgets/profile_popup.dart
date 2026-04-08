import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

/// Profile popup dialog for editing user profile settings.
/// Shown when the user taps "Edit Profile" on the Settings screen.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => const ProfilePopup(),
/// );
/// ```
class ProfilePopup extends StatefulWidget {
  const ProfilePopup({super.key});

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _locationController.dispose();
    _contactController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: feastGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Title Row ───
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Profile Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            color: feastBlack,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Correct any mistakes or changes to your profile.',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Outfit',
                            color: feastGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 22, color: feastBlack),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Profile Picture ───
              _buildFieldLabel('Profile Picture'),
              const SizedBox(height: 6),
              _buildTextField(
                hintText: 'Insert Image',
                prefixIcon: Icons.camera_alt_outlined,
                readOnly: true,
                onTap: () {
                  // Image picker placeholder
                },
              ),
              const SizedBox(height: 16),

              // ─── Location ───
              _buildFieldLabel('Location'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _locationController,
                hintText: 'Insert Location Here...',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              // ─── Contact Number ───
              _buildFieldLabel('Contact Number'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _contactController,
                hintText: '+63 XXX XXX XXXX',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // ─── Date of Birth ───
              _buildFieldLabel('Date of Birth'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _dobController,
                hintText: 'MM/DD/YYYY',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: Icons.calendar_month_outlined,
                onSuffixTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // ─── Gender ───
              _buildFieldLabel('Gender'),
              const SizedBox(height: 6),
              _buildDropdownField(
                value: _selectedGender,
                hintText: '-- Select --',
                prefixIcon: Icons.favorite_border,
                items: _genders,
                onChanged: (val) => setState(() => _selectedGender = val),
              ),
              const SizedBox(height: 24),

              // ─── Confirm Button ───
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save profile changes
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feastBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── Cancel Button ───
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: feastWarning,
                    side: const BorderSide(color: feastWarning, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helper: Field Label ───
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontFamily: 'Outfit',
        fontWeight: FontWeight.bold,
        color: feastGray,
      ),
    );
  }

  // ─── Helper: Text Field ───
  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    required IconData prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withAlpha(77), width: 1),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, fontFamily: 'Outfit'),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Outfit',
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.black54, size: 20),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: Colors.black54, size: 20),
                  onPressed: onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ─── Helper: Dropdown Field ───
  Widget _buildDropdownField({
    required String? value,
    required String hintText,
    required IconData prefixIcon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withAlpha(77), width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Outfit',
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 14, fontFamily: 'Outfit'),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
