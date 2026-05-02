// lib/features/auth/screens/register_id_screen.dart
//
// Step 2 of 2: Legal ID upload with client-side encryption.
// Users upload an image of their valid ID before completing registration.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// Legal ID encryption in React (admin side only):
//   - The key and IV should NEVER be exposed in client-side React code
//   - Use a Cloud Function to decrypt IDs: admin.firestore().collection('users').doc(uid)
//   - Storage path: legal_ids/{uid}/{uuid}.enc
//   - Admin decrypts using AES-256-CBC with server-held key

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/legal/widgets/terms_conditions_dialog.dart';

class RegisterIdScreen extends StatefulWidget {
  final Map<String, String> formData;
  const RegisterIdScreen({super.key, required this.formData});

  @override
  State<RegisterIdScreen> createState() => _RegisterIdScreenState();
}

class _RegisterIdScreenState extends State<RegisterIdScreen> {
  File? _selectedIdFile;
  String? _selectedFileName;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _isFormValid = false;

  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

  @override
  void initState() {
    super.initState();
    _validateForm();
  }

  void _validateForm() {
    final isValid = _selectedIdFile != null && _agreedToTerms;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // File Picker - Images Only
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _pickIdFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext = (file.extension ?? '').toLowerCase();

    if (!_allowedExtensions.contains(ext)) {
      if (!mounted) return;
      FeastToast.showError(
        context,
        'Invalid file type. Only JPG, JPEG, PNG, WEBP, and GIF are accepted.',
      );
      return;
    }

    setState(() {
      _selectedIdFile = File(file.path!);
      _selectedFileName = file.name;
    });
    _validateForm();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Register - Create Account + Upload Encrypted ID
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _register() async {
    if (_selectedIdFile == null) {
      FeastToast.showError(context, 'Please upload your legal ID.');
      return;
    }
    if (!_agreedToTerms) {
      FeastToast.showError(context, 'Please read and accept the Terms & Conditions.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await AuthService.instance.register(
        email: widget.formData['email']!,
        password: widget.formData['password']!,
        firstName: widget.formData['firstName']!,
        middleName: widget.formData['middleName'],
        lastName: widget.formData['lastName']!,
        location: widget.formData['location']!,
        contactNumber: widget.formData['contactNumber']!,
        gender: widget.formData['gender']!,
        dateOfBirth: widget.formData['dateOfBirth']!,
        legalIdUrl: null,
      );

      final uid = cred.user!.uid;
      final idUrl = await StorageService.instance.uploadLegalId(
        _selectedIdFile!,
        uid,
      );

      await FirestoreService.instance.updateUserField(
        uid: uid,
        data: {'legalIdUrl': idUrl},
      );

      if (!mounted) return;
      FeastToast.showSuccess(
        context,
        'Registration successful! You can now log in.',
      );

      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.message);
    } on StorageException catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.message);
    } catch (e) {
      if (!mounted) return;
      debugPrint('Unexpected registration error: $e');
      FeastToast.showError(context, 'Registration failed. Please check your internet connection and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLighterYellow,
      body: FeastBackground(
        padding: const EdgeInsets.only(bottom: 20),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const FeastLogo(height: 120),
                const SizedBox(height: 16),
                
                // ── Header with FeastTagline ─────────────────────────────────
                const FeastTagline(
                  'Verify Your Identity',
                  fontSize: 28,
                  textColor: Colors.white,
                  strokeColor: feastGreen,
                  strokeWidth: 8,
                  fontFamily: 'TitanOne',
                ),
                const SizedBox(height: 12),
                
                const Text(
                  'App access requires you to upload your ID. '
                  'Regulatory standards help us keep the platform safe. '
                  "Don't worry, your data will remain private and protected.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: feastGray),
                ),
                const SizedBox(height: 24),

                // ── ID Upload Area ───────────────────────────────────────────
                GestureDetector(
                  onTap: _pickIdFile,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedIdFile != null ? feastGreen : feastLightGreen,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _selectedIdFile != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _selectedIdFile!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Dark overlay for better text visibility
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                              ),
                              // Change photo button
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: feastGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Change Photo',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: feastGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Remove button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedIdFile = null;
                                    _selectedFileName = null;
                                    _validateForm();
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: feastError,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: feastGreen.withOpacity(0.7),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to Upload Your ID',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: feastGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'JPG, JPEG, PNG, WEBP, GIF',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: feastGray,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                if (_selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: feastSuccess,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: $_selectedFileName',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              color: feastGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Recognized IDs List ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: feastLightYellow.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 18,
                            color: feastGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Accepted IDs',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: feastGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• National ID  • Philippine Passport  • Driver\'s License\n'
                        '• UMID  • PRC ID  • Voter\'s ID  • Postal ID\n'
                        '• Senior Citizen ID  • PhilHealth ID  • PWD ID  • Barangay ID',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Terms & Conditions Checkbox ───────────────────────────────
                FeastCheckbox(
                  text: "I've read the terms and conditions.",
                  value: _agreedToTerms,
                  linkText: 'terms and conditions',
                  linkColor: feastBlue,
                  onLinkTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => TermsConditionsDialog(
                        onAccept: () {
                          // Check the checkbox when "I Understand" is clicked
                          setState(() {
                            _agreedToTerms = true;
                            _validateForm();
                          });
                        },
                        onDecline: () {
                          // Uncheck the checkbox when "Decline" or Close (X) is clicked
                          setState(() {
                            _agreedToTerms = false;
                            _validateForm();
                          });
                        },
                      ),
                    );
                  },
                  onChanged: (val) => setState(() {
                    _agreedToTerms = val ?? false;
                    _validateForm();
                  }),
                ),

                const SizedBox(height: 24),

                // ── Sign Up Button ────────────────────────────────────────────
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: feastGreen),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isFormValid ? _register : null,
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
                            'Sign Up',
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
