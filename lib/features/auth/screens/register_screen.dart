// lib/features/auth/screens/register_screen.dart
//
// Step 1 of 2 in the registration flow.
// Collects personal details, then navigates to RegisterIdScreen.
// All form-field construction is delegated to LabeledTextField.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Registration flow in React:
//   1. await createUserWithEmailAndPassword(auth, email, password)
//   2. await setDoc(doc(db, 'users', user.uid), { ...userData, role: 'user', status: 'active' })
//   3. Redirect to login or home
// Password validation: same regex rules as Flutter

import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _firstNameController  = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController   = TextEditingController();
  final _locationController   = TextEditingController();
  final _contactController    = TextEditingController();
  final _genderController     = TextEditingController();
  final _dobController        = TextEditingController();
  final _emailController      = TextEditingController();
  final _passwordController   = TextEditingController();

  // Live password-strength feedback
  List<String> _passwordErrors = [];

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Navigation to ID Upload Screen
  // ──────────────────────────────────────────────────────────────────────────

  void _goToIdUpload() {
    // Run all validators first
    if (!_formKey.currentState!.validate()) return;

    // Extra guards
    if (_genderController.text.isEmpty) {
      FeastToast.showError(context, 'Please select your gender.');
      return;
    }
    if (_dobController.text.isEmpty) {
      FeastToast.showError(context, 'Please enter your date of birth.');
      return;
    }
    if (_passwordErrors.isNotEmpty) {
      FeastToast.showError(context, 'Password does not meet all requirements.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterIdScreen(
          formData: {
            'firstName':     _firstNameController.text.trim(),
            'middleName':    _middleNameController.text.trim(),
            'lastName':      _lastNameController.text.trim(),
            'location':      _locationController.text,
            'contactNumber': _contactController.text.trim(),
            'gender':        _genderController.text,
            'dateOfBirth':   _dobController.text,
            'email':         _emailController.text.trim(),
            'password':      _passwordController.text,
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLighterYellow,
      body: FeastBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ToggleLoginRegister with isLogin: false (Register tab highlighted)
                  const ToggleLoginRegister(isLogin: false),
                  const SizedBox(height: 24),

                  // ── First Name ──────────────────────────────────────────────
                  LabeledTextField(
                    label: 'First Name',
                    hintText: 'Juan',
                    prefixIcon: Icons.person_outline,
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words, 
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Middle Name (Optional) ──────────────────────────────────
                  LabeledTextField(
                    label: 'Middle Name (If Applicable)',
                    hintText: 'Santos',
                    prefixIcon: Icons.person_outline,
                    controller: _middleNameController,
                    textCapitalization: TextCapitalization.words, 
                  ),
                  const SizedBox(height: 16),

                  // ── Last Name ───────────────────────────────────────────────
                  LabeledTextField(
                    label: 'Last Name',
                    hintText: 'De La Cruz',
                    prefixIcon: Icons.person_outline,
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words, 
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Location ────────────────────────────────────────────────
                  LabeledTextField(
                    label: 'Location',
                    hintText: 'e.g. Almanza Dos, Las Piñas City',
                    prefixIcon: Icons.location_on_outlined,
                    controller: _locationController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Contact Number ──────────────────────────────────────────
                  LabeledTextField(
                    label: 'Contact Number',
                    hintText: '+63 XXX XXX XXXX',
                    prefixIcon: Icons.phone_outlined,
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
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

                  // ── Gender Dropdown ─────────────────────────────────────────
                  LabeledTextField(
                    label: 'Gender',
                    hintText: '-- Select --',
                    prefixIcon: Icons.favorite_border,
                    controller: _genderController,
                    type: LabeledFieldType.dropdown,
                    items: _genders,
                    onDropdownChanged: (v) =>
                        setState(() => _genderController.text = v ?? ''),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please select your gender' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Date of Birth ───────────────────────────────────────────
                  LabeledTextField(
                    label: 'Date of Birth',
                    hintText: 'MM/DD/YYYY',
                    prefixIcon: Icons.calendar_today_outlined,
                    controller: _dobController,
                    type: LabeledFieldType.datePicker,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Date of birth is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ───────────────────────────────────────────────────
                  LabeledTextField(
                    label: 'Email',
                    hintText: 'name@email.com',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Password ────────────────────────────────────────────────
                  LabeledTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    type: LabeledFieldType.password,
                    onChanged: (v) => setState(
                      () => _passwordErrors = AuthService.checkPasswordStrength(v),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      final errors = AuthService.checkPasswordStrength(v);
                      if (errors.isNotEmpty) return errors.first;
                      return null;
                    },
                  ),

                  // Live password-strength hints
                  if (_passwordErrors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ..._passwordErrors.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.cancel, size: 14, color: feastError),
                            const SizedBox(width: 6),
                            Text(
                              e,
                              style: const TextStyle(fontSize: 12, color: feastError),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Next button
                  FeastButton(
                    text: 'Next: Verify Identity',
                    onPressed: _goToIdUpload,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
