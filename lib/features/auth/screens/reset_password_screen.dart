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
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _confirmedChange = false;
  bool _isLoading = false;
  List<String> _passwordErrors = [];

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_confirmedChange) {
      FeastToast.showError(
          context, 'Please confirm you want to change your password.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      FeastToast.showError(context, 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Logic for updating the password
      await AuthService.instance.updatePassword(_newPasswordController.text);
      if (!mounted) return;
      FeastToast.showSuccess(context, 'Password changed successfully!');
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLighterYellow,
      body: FeastBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 80, bottom: 40),
                        child: Column(
                          children: [
                            FeastLogo(height: 120),
                            FeastTagline(
                              'Welcome To The F.E.A.S.T.\nCharity Management System!',
                            ),
                          ],
                        ),
                      ),
                      BottomFormBackground(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Set New Password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'TitanOne',
                                  fontSize: 22,
                                  color: feastGreen,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // New Password
                              LabeledTextField(
                                label: 'New Password',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                controller: _newPasswordController,
                                type: LabeledFieldType.password,
                                onChanged: (v) => setState(() {
                                  _passwordErrors =
                                      AuthService.checkPasswordStrength(v);
                                }),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Required';
                                  }
                                  final errors =
                                      AuthService.checkPasswordStrength(v);
                                  if (errors.isNotEmpty) return errors.first;
                                  return null;
                                },
                              ),
                              if (_passwordErrors.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                ..._passwordErrors.map((e) => Text(
                                      '• $e',
                                      style: const TextStyle(
                                          fontSize: 11, color: feastError),
                                    )),
                              ],
                              const SizedBox(height: 16),

                              // Confirm Password
                              LabeledTextField(
                                label: 'Confirm New Password',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                controller: _confirmPasswordController,
                                type: LabeledFieldType.password,
                                validator: (v) {
                                  if (v != _newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              FeastCheckbox(
                                text: "Yes, I'm sure. Change my password.",
                                value: _confirmedChange,
                                onChanged: (val) => setState(
                                    () => _confirmedChange = val ?? false),
                              ),
                              const SizedBox(height: 24),

                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: feastGreen))
                                  : FeastButton(
                                      text: 'Change Password',
                                      onPressed: _changePassword,
                                    ),
                              const SizedBox(height: 16),

                              FeastLink(
                                text: 'Cancel',
                                alignment: Alignment.center,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
