import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:feast/core/core.dart';
import 'package:feast/features/features.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialise local push notifications
  await NotificationService.instance.init();

  runApp(const FeastApp());
}

class FeastApp extends StatelessWidget {
  const FeastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F.E.A.S.T.',
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

/// Listens to Firebase Auth state and routes accordingly.
/// For development: all authenticated users go directly to HomeScreen.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still waiting for the auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        // Not logged in
        if (user == null) {
          return const LoginScreen();
        }

        // Logged in — go directly to HomeScreen (admin approval skipped for dev)
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(FirestorePaths.users)
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              // Doc not yet created — show splash while waiting
              return const SplashScreen();
            }

            final data = userSnap.data!.data() as Map<String, dynamic>;
            final role = data['role'] as String? ?? 'user';
            final isAdmin = role == 'admin';

            // Any authenticated user (including admin) goes to HomeScreen
            return HomeScreen(isAdmin: isAdmin);
          },
        );
      },
    );
  }
}

// REACT.JS INTEGRATION NOTE
// =========================
// Auth state monitoring in React:
//
// import { onAuthStateChanged } from 'firebase/auth';
//
// onAuthStateChanged(auth, async (user) => {
//   if (!user) {
//     redirect('/login');
//     return;
//   }
//   const userDoc = await getDoc(doc(db, 'users', user.uid));
//   const role = userDoc.data()?.role;
//   // Redirect based on role
//   if (role === 'admin') redirect('/admin');
//   else redirect('/home');
// });
