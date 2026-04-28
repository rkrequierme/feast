// lib/core/services/auth_service.dart
//
// Centralised Firebase Authentication service.
// All auth calls pass through here so screens stay clean.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feast/core/core.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Current user helpers ───────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Sign In ────────────────────────────────────────────────────────────

  /// Signs in with email + password.
  /// Throws [AuthException] with a user-friendly message on failure.
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

      // Verify account status before allowing entry
      final userDoc = await _db
          .collection(FirestorePaths.users)
          .doc(cred.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw AuthException('Account not found. Please register first.');
      }

      final status = userDoc.data()?['status'] as String? ?? 'pending';
      if (status == 'pending') {
        await _auth.signOut();
        throw AuthException(
          'Your account is awaiting admin approval. Please wait for confirmation.',
        );
      }
      if (status == 'banned') {
        await _auth.signOut();
        throw AuthException(
          'Your account has been banned. Contact the Barangay for assistance.',
        );
      }

      // Log the sign-in action to activity_logs
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
    }
  }

  // ─── Register ───────────────────────────────────────────────────────────

  /// Creates a new Firebase Auth account and writes the user document.
  /// Status is set to 'pending' until an admin approves it.
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
    String? legalIdUrl, // encrypted & uploaded before calling this
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;
      final isResident = location.toLowerCase().contains('almanza dos');

      // Write user document — status is 'pending' until admin approves
      await _db.collection(FirestorePaths.users).doc(uid).set({
        'uid': uid,
        'email': email.trim(),
        'firstName': firstName.trim(),
        'middleName': middleName?.trim() ?? '',
        'lastName': lastName.trim(),
        'displayName': '${firstName.trim()} ${lastName.trim()}',
        'location': location,
        'contactNumber': contactNumber.trim(),
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'role': 'user', // 'user' | 'admin'
        'status': 'pending', // 'pending' | 'active' | 'banned'
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
        status: 'Pending',
      );

      // Sign out — user must wait for admin approval
      await _auth.signOut();

      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  // ─── Forgot Password ────────────────────────────────────────────────────

  /// Sends a password reset email.
  /// Always shows success to prevent account enumeration.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      // Swallow the error — always show success toast
    }
  }

  // ─── Sign Out ───────────────────────────────────────────────────────────

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
    await _auth.signOut();
  }

  // ─── Update Password ────────────────────────────────────────────────────

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

  // ─── Password Strength Validator ────────────────────────────────────────

  /// Returns a list of failed requirement labels.
  static List<String> checkPasswordStrength(String password) {
    final missing = <String>[];
    if (password.length < 8) missing.add('At least 8 characters');
    if (!password.contains(RegExp(r'[A-Z]'))) missing.add('One uppercase letter');
    if (!password.contains(RegExp(r'[a-z]'))) missing.add('One lowercase letter');
    if (!password.contains(RegExp(r'[0-9]'))) missing.add('One digit');
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
      missing.add('One special character');
    return missing;
  }

  // ─── Phone Validator ────────────────────────────────────────────────────

  /// Philippine phone format: +63 XXX XXX XXXX
  static bool isValidPhilippinePhone(String number) {
    return RegExp(r'^\+63\s?\d{3}\s?\d{3}\s?\d{4}$').hasMatch(number.trim());
  }

  // ─── Activity Logger ────────────────────────────────────────────────────

  Future<void> _logActivity({
    required String uid,
    required String type,
    required String description,
    required String status,
  }) async {
    await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('activity_logs')
        .add({
      'type': type,
      'description': description,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ─── Error Mapper ────────────────────────────────────────────────────────

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

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : users
// Document  : {uid}
// Fields    : uid, email, firstName, lastName, displayName, location,
//             contactNumber, gender, dateOfBirth, role, status,
//             isResident, legalIdUrl, profilePictureUrl,
//             notificationsEnabled, warningCount, createdAt, updatedAt
// Sub-coll  : activity_logs — type, description, status, timestamp
//
// React sign-in:
//   import { signInWithEmailAndPassword, setPersistence,
//            browserLocalPersistence, browserSessionPersistence } from 'firebase/auth';
//   await setPersistence(auth, rememberMe
//     ? browserLocalPersistence : browserSessionPersistence);
//   const cred = await signInWithEmailAndPassword(auth, email, password);
//   const snap = await getDoc(doc(db, 'users', cred.user.uid));
//   if (snap.data().status !== 'active') { await signOut(auth); }
//
// React register:
//   const cred = await createUserWithEmailAndPassword(auth, email, pass);
//   await setDoc(doc(db, 'users', cred.user.uid), { ...userData, status: 'pending' });
//   await signOut(auth); // Wait for admin approval
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
