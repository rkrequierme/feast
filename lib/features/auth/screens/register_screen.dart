// lib/features/auth/screens/register_screen.dart

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
  
  // Track if all fields are filled (for button state)
  bool _allFieldsFilled = false;

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    // Add listeners to check if all fields are filled
    _firstNameController.addListener(_checkAllFieldsFilled);
    _lastNameController.addListener(_checkAllFieldsFilled);
    _locationController.addListener(_checkAllFieldsFilled);
    _contactController.addListener(_checkAllFieldsFilled);
    _genderController.addListener(_checkAllFieldsFilled);
    _dobController.addListener(_checkAllFieldsFilled);
    _emailController.addListener(_checkAllFieldsFilled);
    _passwordController.addListener(_checkAllFieldsFilled);
    _passwordController.addListener(_updatePasswordErrors);
    
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAllFieldsFilled();
    });
  }

  void _checkAllFieldsFilled() {
    final firstNameFilled = _firstNameController.text.trim().isNotEmpty;
    final lastNameFilled = _lastNameController.text.trim().isNotEmpty;
    final locationFilled = _locationController.text.trim().isNotEmpty;
    final contactFilled = _contactController.text.trim().isNotEmpty;
    final genderFilled = _genderController.text.isNotEmpty;
    final dobFilled = _dobController.text.isNotEmpty;
    final emailFilled = _emailController.text.trim().isNotEmpty;
    final passwordFilled = _passwordController.text.isNotEmpty;
    
    final allFilled = firstNameFilled && lastNameFilled && locationFilled && 
                      contactFilled && genderFilled && dobFilled && 
                      emailFilled && passwordFilled;
    
    if (_allFieldsFilled != allFilled) {
      setState(() => _allFieldsFilled = allFilled);
    }
  }

  void _updatePasswordErrors() {
    setState(() {
      _passwordErrors = AuthService.checkPasswordStrength(_passwordController.text);
    });
  }

  bool _isAgeValid(String dateOfBirth) {
    if (dateOfBirth.isEmpty) return false;
    
    try {
      DateTime birthDate;
      
      // Try parsing "MM/DD/YYYY" format first
      if (dateOfBirth.contains('/')) {
        final parts = dateOfBirth.split('/');
        if (parts.length != 3) return false;
        
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        birthDate = DateTime(year, month, day);
      } 
      // Try parsing "Jan 31, 1997" format
      else if (dateOfBirth.contains(',')) {
        // Remove the comma and split
        const months = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
        };
        
        final parts = dateOfBirth.replaceAll(',', '').split(' ');
        if (parts.length != 3) return false;
        
        final monthStr = parts[0];
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        
        if (!months.containsKey(monthStr)) return false;
        
        birthDate = DateTime(year, months[monthStr]!, day);
      }
      else {
        return false;
      }
      
      final today = DateTime.now();
      
      // Check if date is in the future
      if (birthDate.isAfter(today)) {
        return false;
      }
      
      // Calculate age
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      
      return age >= 18;
    } catch (e) {
      debugPrint('Age validation error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_checkAllFieldsFilled);
    _lastNameController.removeListener(_checkAllFieldsFilled);
    _locationController.removeListener(_checkAllFieldsFilled);
    _contactController.removeListener(_checkAllFieldsFilled);
    _genderController.removeListener(_checkAllFieldsFilled);
    _dobController.removeListener(_checkAllFieldsFilled);
    _emailController.removeListener(_checkAllFieldsFilled);
    _passwordController.removeListener(_checkAllFieldsFilled);
    _passwordController.removeListener(_updatePasswordErrors);
    
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
    // Run all validators - this will show error messages if validation fails
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Extra guards with specific error messages (should already be caught by validators)
    if (_genderController.text.isEmpty) {
      FeastToast.showError(context, 'Please select your gender.');
      return;
    }
    if (_dobController.text.isEmpty) {
      FeastToast.showError(context, 'Please enter your date of birth.');
      return;
    }
    if (!_isAgeValid(_dobController.text)) {
      FeastToast.showError(context, 'You must be at least 18 years old to register.');
      return;
    }
    if (_passwordErrors.isNotEmpty) {
      FeastToast.showError(context, _passwordErrors.first);
      return;
    }

    // Validate email format again to be safe
    final email = _emailController.text.trim().toLowerCase();
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      FeastToast.showError(context, 'Please enter a valid email address.');
      return;
    }

    // Validate phone number format
    final phone = _contactController.text.trim();
    if (!AuthService.isValidPhilippinePhone(phone)) {
      FeastToast.showError(context, 'Please enter a valid Philippine phone number (+63 XXX XXX XXXX).');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterIdScreen(
          formData: {
            'firstName': _firstNameController.text.trim(),
            'middleName': _middleNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'location': _locationController.text,
            'contactNumber': _contactController.text.trim(),
            'gender': _genderController.text,
            'dateOfBirth': _dobController.text,
            'email': email,
            'password': _passwordController.text,
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
                    hintText: 'Select',
                    prefixIcon: Icons.favorite_border,
                    controller: _genderController,
                    type: LabeledFieldType.dropdown,
                    items: _genders,
                    onDropdownChanged: (v) => setState(() {
                      _genderController.text = v ?? '';
                      _checkAllFieldsFilled();
                    }),
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
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Date of birth is required';
                      }
                      
                      // First check if date is in the future
                      try {
                        DateTime birthDate;
                        
                        // Try parsing "MM/DD/YYYY" format
                        if (v.contains('/')) {
                          final parts = v.split('/');
                          if (parts.length == 3) {
                            final month = int.parse(parts[0]);
                            final day = int.parse(parts[1]);
                            final year = int.parse(parts[2]);
                            birthDate = DateTime(year, month, day);
                            
                            final today = DateTime.now();
                            if (birthDate.isAfter(today)) {
                              return 'Date cannot be in the future';
                            }
                          }
                        }
                        // Try parsing "Jan 31, 1997" format
                        else if (v.contains(',')) {
                          const months = {
                            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
                          };
                          
                          final parts = v.replaceAll(',', '').split(' ');
                          if (parts.length == 3) {
                            final monthStr = parts[0];
                            final day = int.parse(parts[1]);
                            final year = int.parse(parts[2]);
                            
                            if (months.containsKey(monthStr)) {
                              birthDate = DateTime(year, months[monthStr]!, day);
                              final today = DateTime.now();
                              if (birthDate.isAfter(today)) {
                                return 'Date cannot be in the future';
                              }
                            }
                          }
                        }
                      } catch (e) {
                        // Parse error will be caught by age validation
                      }
                      
                      if (!_isAgeValid(v)) {
                        return 'You must be at least 18 years old to register';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Email (Lowercase only) ───────────────────────────────────
                  LabeledTextField(
                    label: 'Email',
                    hintText: 'name@email.com',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: [LowerCaseTextFormatter()],
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
                    onChanged: (v) => setState(() {
                      _passwordErrors = AuthService.checkPasswordStrength(v);
                    }),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      // Don't show individual requirement errors here since they're already listed below
                      // Just return null to let the password strength list handle it
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

                  const SizedBox(height: 32),

                  // Next button (enabled when all fields are filled, even if invalid)
                  // Validation errors will prevent navigation when tapped
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _allFieldsFilled ? _goToIdUpload : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allFieldsFilled
                            ? feastGreen
                            : feastGreen.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.bold,
                          color: _allFieldsFilled
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
