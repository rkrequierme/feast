// lib/core/widgets/edit_profile_modal.dart
//
// Modal for editing user profile information.
// Updates location, contact number, date of birth, and gender.
// Automatically updates residency status based on location.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/text_formatters.dart';
import 'labeled_text_field.dart';
import 'feast_toast.dart';

class EditProfileModal extends StatefulWidget {
  final VoidCallback? onSaved;

  const EditProfileModal({super.key, this.onSaved});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  
  String? _currentProfileUrl;
  File? _newProfileImage;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _allFieldsFilled = false;

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
    _addListeners();
  }

  void _addListeners() {
    _locationController.addListener(_checkAllFieldsFilled);
    _contactController.addListener(_checkAllFieldsFilled);
    _dobController.addListener(_checkAllFieldsFilled);
    _genderController.addListener(_checkAllFieldsFilled);
  }

  void _checkAllFieldsFilled() {
    final allFilled = _locationController.text.trim().isNotEmpty &&
        _contactController.text.trim().isNotEmpty &&
        _dobController.text.trim().isNotEmpty &&
        _genderController.text.isNotEmpty;
    
    if (_allFieldsFilled != allFilled) {
      setState(() => _allFieldsFilled = allFilled);
    }
  }

  Future<void> _loadCurrentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();
    if (!mounted) return;
    final data = doc.data() ?? {};
    _locationController.text = data['location'] as String? ?? '';
    _contactController.text = data['contactNumber'] as String? ?? '';
    _dobController.text = data['dateOfBirth'] as String? ?? '';
    _genderController.text = data['gender'] as String? ?? '';
    _currentProfileUrl = data['profilePictureUrl'] as String?;
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null && mounted) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (_locationController.text.trim().isNotEmpty) {
        updates['location'] = _locationController.text.trim();
        updates['isResident'] = _locationController.text
            .toLowerCase()
            .contains('almanza dos');
      }
      
      if (_contactController.text.trim().isNotEmpty) {
        updates['contactNumber'] = _contactController.text.trim();
      }
      
      if (_dobController.text.trim().isNotEmpty) {
        updates['dateOfBirth'] = _dobController.text.trim();
      }
      
      if (_genderController.text.isNotEmpty) {
        updates['gender'] = _genderController.text;
      }

      if (_newProfileImage != null) {
        final uploadedUrl = await StorageService.instance.uploadProfilePicture(
          _newProfileImage!,
          uid,
        );
        updates['profilePictureUrl'] = uploadedUrl;
      }

      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update(updates);

      widget.onSaved?.call();
      if (mounted) Navigator.of(context).pop();
      FeastToast.showSuccess(context, 'Profile updated successfully!');
    } catch (e) {
      if (mounted) {
        FeastToast.showError(context, 'Failed to save profile. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _contactController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: feastGreen)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: feastLightGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_outline, color: feastGreen, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                    color: feastBlack,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Update your personal information',
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
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: feastLightGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: feastGray),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Profile Picture
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: feastLightGreen.withAlpha(128),
                              backgroundImage: _newProfileImage != null
                                  ? FileImage(_newProfileImage!) as ImageProvider
                                  : (_currentProfileUrl != null && _currentProfileUrl!.isNotEmpty
                                      ? NetworkImage(_currentProfileUrl!)
                                      : null),
                              child: (_newProfileImage == null && (_currentProfileUrl == null || _currentProfileUrl!.isEmpty))
                                  ? const Icon(Icons.person, size: 48, color: feastGreen)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: feastGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Location Field
                      LabeledTextField(
                        label: 'Location',
                        hintText: 'e.g. Almanza Dos, Las Piñas City',
                        prefixIcon: Icons.location_on_outlined,
                        controller: _locationController,
                        validator: (v) => (v == null || v.trim().isEmpty) 
                            ? 'Location is required' 
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Contact Number Field
                      LabeledTextField(
                        label: 'Contact Number',
                        hintText: '+63 XXX XXX XXXX',
                        prefixIcon: Icons.phone_outlined,
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        textCapitalization: TextCapitalization.none,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Contact number is required';
                          }
                          if (!AuthService.isValidPhilippinePhone(v)) {
                            return 'Format: +63 XXX XXX XXXX';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth Field (using LabeledTextField with datePicker type)
                      LabeledTextField(
                        label: 'Date of Birth',
                        hintText: 'MM/DD/YYYY',
                        prefixIcon: Icons.calendar_today_outlined,
                        controller: _dobController,
                        type: LabeledFieldType.datePicker,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Date of birth is required';
                          }
                          if (AuthService.isFutureDate(v)) {
                            return 'Date cannot be in the future';
                          }
                          if (!AuthService.isAgeValid(v)) {
                            return 'You must be at least 18 years old';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gender Dropdown
                      LabeledTextField(
                        label: 'Gender',
                        hintText: 'Select',
                        prefixIcon: Icons.favorite_border,
                        controller: _genderController,
                        type: LabeledFieldType.dropdown,
                        items: _genders,
                        onDropdownChanged: (v) => setState(() {
                          _genderController.text = v ?? '';
                          _checkAllFieldsFilled();
                        }),
                        validator: (v) => (v == null || v.isEmpty) 
                            ? 'Please select your gender' 
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Buttons (Cancel left, Confirm right)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: feastError,
                                side: const BorderSide(color: feastError),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (_allFieldsFilled && !_isSaving) ? _save : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (_allFieldsFilled && !_isSaving) 
                                    ? feastGreen 
                                    : feastGreen.withOpacity(0.5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
