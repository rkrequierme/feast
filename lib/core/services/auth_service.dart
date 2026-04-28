// lib/core/services/auth_service.dart
// 
// CENTRALIZED FIREBASE AUTHENTICATION SERVICE
// All auth calls pass through here — screens stay clean.
//
// REACT.JS INTEGRATION:
// Collection: users
// Document: {uid}
// React sign-in: await signInWithEmailAndPassword(auth, email, password)
// React sign-out: await signOut(auth)
// React password reset: await sendPasswordResetEmail(auth, email)
// React email verification: await sendEmailVerification(auth.currentUser)
// Remember Me: setPersistence(auth, browserLocalPersistence)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/firestore_paths.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────────────────────────────────
  // CURRENT USER HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  // ──────────────────────────────────────────────────────────────────────────
  // SIGN IN (WITHOUT ADMIN APPROVAL FOR DEVELOPMENT)
  // ──────────────────────────────────────────────────────────────────────────

  /// Signs in with email + password.
  /// NOTE: Admin approval is temporarily disabled for development.
  /// Throws [AuthException] with user-friendly message on failure.
  Future<UserCredential> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      // Set session persistence based on "Remember Me"
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );

      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Ensure user document exists (create if missing)
      await _ensureUserDocument(cred.user!.uid, email.trim());

      // Log the sign-in action
      await _logActivity(
        uid: cred.user!.uid,
        type: 'User Authentication',
        description: 'You Logged In.',
        status: 'Success',
      );

      // Persist "remember me" flag locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);
      if (rememberMe) {
        await prefs.setString('cached_email', email.trim());
      } else {
        await prefs.remove('cached_email');
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  /// Ensures a Firestore user document exists for the given UID.
  /// Creates one with default values if missing.
  Future<void> _ensureUserDocument(String uid, String email) async {
    final docRef = _db.collection(FirestorePaths.users).doc(uid);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      // Create default user document for new registrations
      await docRef.set({
        'uid': uid,
        'email': email,
        'displayName': email.split('@').first,
        'role': 'user',
        'status': 'active',      // AUTO-APPROVED FOR DEVELOPMENT
        'isResident': false,
        'notificationsEnabled': true,
        'warningCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REGISTER (AUTO-APPROVED FOR DEVELOPMENT)
  // ──────────────────────────────────────────────────────────────────────────

  /// Creates a new Firebase Auth account and writes the user document.
  /// NOTE: Admin approval is temporarily disabled — status is 'active' immediately.
  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String? middleName,
    required String lastName,
    required String location,
    required String contactNumber,
    required String gender,
    required String dateOfBirth,
    String? legalIdUrl,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;
      final isResident = location.toLowerCase().contains('almanza dos');
      final displayName = '$firstName ${lastName}'.trim();

      // Write user document — AUTO-APPROVED (status: 'active') for development
      await _db.collection(FirestorePaths.users).doc(uid).set({
        'uid': uid,
        'email': email.trim(),
        'firstName': firstName.trim(),
        'middleName': middleName?.trim() ?? '',
        'lastName': lastName.trim(),
        'displayName': displayName,
        'location': location,
        'contactNumber': contactNumber.trim(),
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'role': 'user',
        'status': 'active',        // AUTO-APPROVED — NO ADMIN NEEDED
        'isResident': isResident,
        'legalIdUrl': legalIdUrl ?? '',
        'profilePictureUrl': '',
        'notificationsEnabled': true,
        'warningCount': 0,
        'donationRevokeCount': 0,
        'donationRevokeWeekStart': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log registration activity
      await _logActivity(
        uid: uid,
        type: 'User Authentication',
        description: 'You Registered an Account.',
        status: 'Success',
      );

      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ──────────────────────────────────────────────────────────────────────────

  /// Sends a password reset email.
  /// Always shows success to prevent account enumeration.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      // Swallow the error — always show success toast
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SIGN OUT
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _logActivity(
        uid: uid,
        type: 'User Authentication',
        description: 'You Logged Out.',
        status: 'Success',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
    await prefs.remove('cached_email');
    await _auth.signOut();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // UPDATE PASSWORD
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
      final uid = _auth.currentUser!.uid;
      await _logActivity(
        uid: uid,
        type: 'Credential Changes',
        description: 'Set New Password.',
        status: 'Success',
      );
      await _db.collection(FirestorePaths.users).doc(uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PASSWORD STRENGTH VALIDATOR
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns a list of failed requirement labels.
  static List<String> checkPasswordStrength(String password) {
    final missing = <String>[];
    if (password.length < 8) missing.add('At least 8 characters');
    if (!password.contains(RegExp(r'[A-Z]'))) missing.add('One uppercase letter');
    if (!password.contains(RegExp(r'[a-z]'))) missing.add('One lowercase letter');
    if (!password.contains(RegExp(r'[0-9]'))) missing.add('One digit');
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      missing.add('One special character');
    }
    return missing;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PHONE VALIDATOR (Philippine format)
  // ──────────────────────────────────────────────────────────────────────────

  static bool isValidPhilippinePhone(String number) {
    return RegExp(r'^\+63\s?\d{3}\s?\d{3}\s?\d{4}$').hasMatch(number.trim());
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ACTIVITY LOGGER
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _logActivity({
    required String uid,
    required String type,
    required String description,
    required String status,
  }) async {
    await _db
        .collection(FirestorePaths.userHistory(uid))
        .add({
      'type': type,
      'description': description,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ERROR MAPPER
  // ──────────────────────────────────────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Typed exception for auth errors with user-friendly messages.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
