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
      // Auth-aware routing: always start at splash which decides where to go
      home: const _AuthGate(),
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

/// Listens to Firebase Auth state and routes accordingly.
/// - Not signed in → LoginScreen
/// - Signed in but account is pending/banned → shows friendly message
/// - Signed in & active → HomeScreen
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

        // Logged in — check Firestore user doc for approval status
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
            final status = data['status'] as String? ?? 'pending';

            switch (status) {
              case 'active':
                return const HomeScreen();
              case 'banned':
                // Sign them out and show a message
                FirebaseAuth.instance.signOut();
                return const _StatusScreen(
                  message:
                      'Your account has been banned. Contact the Barangay for assistance.',
                  icon: Icons.block,
                );
              case 'pending':
              default:
                FirebaseAuth.instance.signOut();
                return const _StatusScreen(
                  message:
                      'Your account is awaiting admin approval. You will be notified once it is activated.',
                  icon: Icons.hourglass_top,
                );
            }
          },
        );
      },
    );
  }
}

/// Simple informational screen shown for pending/banned users.
class _StatusScreen extends StatelessWidget {
  final String message;
  final IconData icon;
  const _StatusScreen({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: feastLighterYellow,
      body: FeastBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FeastLogo(height: 100),
                const SizedBox(height: 32),
                Icon(icon, size: 64, color: feastGreen),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    color: feastBlack,
                  ),
                ),
                const SizedBox(height: 32),
                FeastButton(
                  text: 'Back to Login',
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ■■ REACT.JS INTEGRATION NOTE ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
// Collection : users
// Document  : {uid}
// Fields    : status ('pending'|'active'|'banned'), role ('user'|'admin')
// React use : onAuthStateChanged(auth, async (user) => {
//               if (!user) { redirect('/login'); return; }
//               const snap = await getDoc(doc(db,'users',user.uid));
//               if (snap.data().status !== 'active') { signOut(auth); }
//               else { redirect('/home'); }
//             });
// ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
