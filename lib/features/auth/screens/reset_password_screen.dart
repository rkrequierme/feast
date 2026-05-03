// lib/features/auth/screens/reset_password_screen.dart

import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _confirmedChange = false;
  bool _isLoading = false;
  bool _isFormValid = false;
  List<String> _passwordErrors = [];

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_validateForm);
    _newPasswordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final currentPasswordValid = _currentPasswordController.text.isNotEmpty;
    final newPasswordValid = _newPasswordController.text.isNotEmpty;
    final confirmPasswordValid = _confirmPasswordController.text.isNotEmpty;
    final passwordsMatch = _newPasswordController.text == _confirmPasswordController.text;
    final passwordStrong = _passwordErrors.isEmpty;
    final isValid = currentPasswordValid && newPasswordValid && confirmPasswordValid && 
                    passwordsMatch && passwordStrong && _confirmedChange;
    
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_validateForm);
    _newPasswordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_confirmedChange) {
      FeastToast.showError(context, 'Please confirm you want to change your password.');
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      FeastToast.showError(context, 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Update password with current password for re-authentication
      await AuthService.instance.updatePassword(
        _newPasswordController.text,
        currentPassword: _currentPasswordController.text,
      );
      
      if (!mounted) return;
      
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: feastSuccess, size: 32),
              SizedBox(width: 12),
              Text(
                'Password Changed',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your password has been successfully changed. Please use your new password to log in.',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to settings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: feastGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, 'Failed to change password. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLighterYellow,
      body: FeastBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const FeastLogo(height: 100),
                const SizedBox(height: 16),
                const FeastTagline(
                  'F.E.A.S.T.',
                  fontSize: 32,
                  textColor: Colors.white,
                  strokeColor: feastBlue,
                  strokeWidth: 8,
                  fontFamily: 'Ultra',
                ),
                const SizedBox(height: 8),
                const FeastTagline(
                  'Charity Management System',
                  fontSize: 20,
                  strokeWidth: 8,
                ),
                const SizedBox(height: 32),
                
                BottomFormBackground(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 48),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FeastTagline(
                            'Set New Password',
                            fontSize: 24,
                            fontFamily: 'TitanOne',
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'For security, please enter your current password, then your new password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: feastGray,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          

                          // Current Password Field
                          LabeledTextField(
                            label: 'Current Password',
                            hintText: 'Enter your current password',
                            prefixIcon: Icons.lock_outline,
                            controller: _currentPasswordController,
                            type: LabeledFieldType.password,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Current password is required';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),

                          // New Password Field
                          LabeledTextField(
                            label: 'New Password',
                            hintText: 'Enter your new password',
                            prefixIcon: Icons.lock_outline,
                            controller: _newPasswordController,
                            type: LabeledFieldType.password,
                            onChanged: (v) => setState(() {
                              _passwordErrors = AuthService.checkPasswordStrength(v);
                              _validateForm();
                            }),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'New password is required';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Password strength indicator
                          if (_newPasswordController.text.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _passwordErrors.isEmpty
                                    ? feastSuccess.withOpacity(0.1)
                                    : feastError.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _passwordErrors.isEmpty
                                        ? Icons.check_circle
                                        : Icons.info_outline,
                                    size: 18,
                                    color: _passwordErrors.isEmpty
                                        ? feastSuccess
                                        : feastError,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _passwordErrors.isEmpty
                                          ? 'Strong password!'
                                          : '${_passwordErrors.length} requirement${_passwordErrors.length == 1 ? '' : 's'} needed',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _passwordErrors.isEmpty
                                            ? feastSuccess
                                            : feastError,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Password requirements list
                          if (_passwordErrors.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: feastLightYellow.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Password Requirements:',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: feastBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ..._passwordErrors.map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: feastError,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: feastError,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          LabeledTextField(
                            label: 'Confirm New Password',
                            hintText: 'Confirm your new password',
                            prefixIcon: Icons.lock_outline,
                            controller: _confirmPasswordController,
                            type: LabeledFieldType.password,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (v != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          
                          // Password match indicator
                          if (_confirmPasswordController.text.isNotEmpty &&
                              _newPasswordController.text.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _newPasswordController.text == _confirmPasswordController.text
                                    ? feastSuccess.withOpacity(0.1)
                                    : feastError.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _newPasswordController.text == _confirmPasswordController.text
                                        ? Icons.check_circle
                                        : Icons.error_outline,
                                    size: 18,
                                    color: _newPasswordController.text == _confirmPasswordController.text
                                        ? feastSuccess
                                        : feastError,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _newPasswordController.text == _confirmPasswordController.text
                                        ? 'Passwords match'
                                        : 'Passwords do not match',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _newPasswordController.text == _confirmPasswordController.text
                                          ? feastSuccess
                                          : feastError,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // Confirmation Checkbox
                          FeastCheckbox(
                            text: "Yes, I'm sure. Change my password.",
                            value: _confirmedChange,
                            linkColor: feastBlue,
                            onChanged: (val) => setState(() {
                              _confirmedChange = val ?? false;
                              _validateForm();
                            }),
                          ),
                          
                          const SizedBox(height: 32),

                          // Change Password Button
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(color: feastGreen),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isFormValid ? _changePassword : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isFormValid
                                          ? feastGreen
                                          : feastGreen.withOpacity(0.5),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      'Change Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.bold,
                                        color: _isFormValid
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                          
                          const SizedBox(height: 20),

                          // Cancel Link
                          FeastLink(
                            text: 'Cancel',
                            alignment: Alignment.center,
                            color: feastBlue,
                            onPressed: () => Navigator.pop(context),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
