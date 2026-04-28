// lib/features/auth/screens/register_id_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:feast/core/core.dart';

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

  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

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
  }

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
      // Step 1: Create Firebase Auth account
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

      // Step 2: Upload encrypted ID using real UID
      final uid = cred.user!.uid;
      final idUrl = await StorageService.instance.uploadLegalId(
        _selectedIdFile!,
        uid,
      );

      // Step 3: Update Firestore doc with the encrypted ID URL
      await FirestoreService.instance.updateUserField(
        uid: uid,
        data: {'legalIdUrl': idUrl},
      );

      if (!mounted) return;
      FeastToast.showSuccess(
        context,
        'Registration submitted! Please wait for admin approval.',
      );
      
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } on Exception catch (e) {
      if (!mounted) return;
      FeastToast.showError(context, e.toString());
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const FeastLogo(height: 90),
                const SizedBox(height: 20),
                const Text(
                  'Verify Your Identity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'TitanOne',
                    fontSize: 24,
                    color: feastGreen,
                  ),
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
                GestureDetector(
                  onTap: _pickIdFile,
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedIdFile != null ? feastGreen : feastLightGreen,
                        width: 2,
                      ),
                    ),
                    child: _selectedIdFile != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedIdFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedIdFile = null;
                                    _selectedFileName = null;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: feastWarning, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file_outlined, size: 40, color: feastGreen.withAlpha(153)),
                              const SizedBox(height: 8),
                              const Text('Select File', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: feastGray)),
                              const Text('JPG, JPEG, PNG, WEBP, GIF', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: feastGray)),
                            ],
                          ),
                  ),
                ),
                if (_selectedFileName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    'Selected: $_selectedFileName',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: feastGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('List of Recognised IDs:', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13)),
                const Text(
                  '• National ID  • Philippine Passport  • Driver\'s License\n'
                  '• UMID  • PRC ID  • Voter\'s ID  • Postal ID\n'
                  '• Senior Citizen ID  • PhilHealth ID  • PWD ID  • Barangay ID',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 12),
                ),
                const SizedBox(height: 24),
                FeastCheckbox(
                  text: "I've read the terms and conditions.",
                  value: _agreedToTerms,
                  linkText: 'terms and conditions',
                  onLinkTap: () => Navigator.pushNamed(context, AppRoutes.legal),
                  onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: feastGreen))
                    : FeastButton(
                        text: 'Sign Up',
                        onPressed: _agreedToTerms ? _register : null,
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
