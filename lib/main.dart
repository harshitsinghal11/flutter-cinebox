import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart'; // Import Home Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CineboxApp());
}

class CineboxApp extends StatelessWidget {
  const CineboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinebox',
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: Colors.transparent,
      ),

      // AUTH GUARD: This checks user status on every app launch (including F5 refresh)
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. If waiting for connection, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            );
          }

          // 2. If we have a user data, go to Home
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // 3. Otherwise, go to Login
          return const LoginScreen();
        },
      ),
    );
  }
}
