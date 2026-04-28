// lib/core/widgets/edit_profile_modal.dart
//
// Modal for editing user profile information.
// Updates location, contact number, date of birth, and gender.
// Automatically updates residency status based on location.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// In React, implement as a form modal:
//   const [formData, setFormData] = useState({...});
//   await updateDoc(doc(db, 'users', uid), { ...formData, updatedAt: serverTimestamp() });

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../constants/firestore_paths.dart';
import 'feast_toast.dart';

class EditProfileModal extends StatefulWidget {
  final VoidCallback? onSaved;

  const EditProfileModal({super.key, this.onSaved});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _locationCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _selectedGender;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
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
    _locationCtrl.text = data['location'] as String? ?? '';
    _contactCtrl.text = data['contactNumber'] as String? ?? '';
    _dobCtrl.text = data['dateOfBirth'] as String? ?? '';
    _selectedGender = data['gender'] as String?;
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_locationCtrl.text.trim().isNotEmpty) {
        updates['location'] = _locationCtrl.text.trim();
        // Automatically check residency based on keywords
        updates['isResident'] = _locationCtrl.text
            .toLowerCase()
            .contains('almanza dos');
      }
      if (_contactCtrl.text.trim().isNotEmpty) {
        updates['contactNumber'] = _contactCtrl.text.trim();
      }
      if (_dobCtrl.text.trim().isNotEmpty) {
        updates['dateOfBirth'] = _dobCtrl.text.trim();
      }
      if (_selectedGender != null) {
        updates['gender'] = _selectedGender;
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: feastGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _dobCtrl.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.white,
      child: _isLoading
          ? const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator(color: feastGreen)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Profile Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                                color: feastBlack,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Correct any mistakes or changes to your profile.',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Outfit',
                                color: feastGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _label('Location'),
                  const SizedBox(height: 6),
                  _field(_locationCtrl, 'Insert Location Here...', Icons.location_on_outlined),
                  const SizedBox(height: 14),
                  _label('Contact Number'),
                  const SizedBox(height: 6),
                  _field(_contactCtrl, '+63 XXX XXX XXXX', Icons.phone_outlined, type: TextInputType.phone),
                  const SizedBox(height: 14),
                  _label('Date of Birth'),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: _field(_dobCtrl, 'MM/DD/YYYY', Icons.calendar_today_outlined, suffix: Icons.calendar_month_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Gender'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: _boxDeco(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        hint: const Text('-- Select --', style: TextStyle(color: Colors.grey, fontFamily: 'Outfit')),
                        items: ['Male', 'Female', 'Other'].map((g) {
                          return DropdownMenuItem(
                            value: g,
                            child: Text(g, style: const TextStyle(fontFamily: 'Outfit')),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: feastBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: feastWarning,
                        side: const BorderSide(color: feastWarning),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontFamily: 'Outfit',
      fontWeight: FontWeight.bold,
      color: feastGray,
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData prefix, {
    TextInputType type = TextInputType.text,
    IconData? suffix,
  }) {
    return Container(
      decoration: _boxDeco(),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Outfit'),
          prefixIcon: Icon(prefix, color: Colors.black54, size: 20),
          suffixIcon: suffix != null ? Icon(suffix, color: Colors.black54, size: 20) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  BoxDecoration _boxDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withAlpha(77)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
