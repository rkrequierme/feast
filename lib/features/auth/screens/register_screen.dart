// lib/features/auth/screens/register_screen.dart
//
// Step 1 of 2 in the registration flow.
// Collects personal details, then navigates to RegisterIdScreen.
//
// All form-field construction is now delegated to LabeledTextField, which
// replaces the four private helpers (_buildField, _buildDropdown,
// _buildDateField, _buildPasswordField) that used to live here.

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

  // One controller per field.
  final _firstNameController  = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController   = TextEditingController();
  final _locationController   = TextEditingController();
  final _contactController    = TextEditingController();
  final _genderController     = TextEditingController();
  final _dobController        = TextEditingController();
  final _emailController      = TextEditingController();
  final _passwordController   = TextEditingController();

  // Live password-strength feedback shown below the password field.
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

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goToIdUpload() {
    // Run all TextFormField validators first.
    if (!_formKey.currentState!.validate()) return;

    // Extra guards for fields not covered by TextFormField validators.
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
                  // isLogin: false → the "Register" tab is highlighted in green.
                  const ToggleLoginRegister(isLogin: false),
                  const SizedBox(height: 24),

                  // ── Name fields ─────────────────────────────────────────
                  LabeledTextField(
                    label: 'First Name',
                    hintText: 'Juan',
                    prefixIcon: Icons.person_outline,
                    controller: _firstNameController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  LabeledTextField(
                    label: 'Middle Name (If Applicable)',
                    hintText: 'Santos',
                    prefixIcon: Icons.person_outline,
                    controller: _middleNameController,
                    // Optional — no validator needed.
                  ),
                  const SizedBox(height: 16),

                  LabeledTextField(
                    label: 'Last Name',
                    hintText: 'De La Cruz',
                    prefixIcon: Icons.person_outline,
                    controller: _lastNameController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Location ────────────────────────────────────────────
                  LabeledTextField(
                    label: 'Location',
                    hintText: 'e.g. Almanza Dos, Las Piñas City',
                    prefixIcon: Icons.location_on_outlined,
                    controller: _locationController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Contact number ──────────────────────────────────────
                  LabeledTextField(
                    label: 'Contact Number',
                    hintText: '+63 XXX XXX XXXX',
                    prefixIcon: Icons.phone_outlined,
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Contact number is required';
                      if (!AuthService.isValidPhilippinePhone(v)) return 'Format: +63 XXX XXX XXXX';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Gender dropdown ─────────────────────────────────────
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

                  // ── Date of birth ───────────────────────────────────────
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

                  // ── Email ───────────────────────────────────────────────
                  LabeledTextField(
                    label: 'Email',
                    hintText: 'name@email.com',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Password ────────────────────────────────────────────
                  LabeledTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    type: LabeledFieldType.password,
                    // Update live strength errors on every keystroke.
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

                  // Live password-strength hint rows.
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
