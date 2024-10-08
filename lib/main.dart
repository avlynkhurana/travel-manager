import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:travel_manager/firebase_options.dart';
import 'package:travel_manager/pages/home_project.dart';
import 'package:travel_manager/pages/login.dart';
import 'package:travel_manager/pages/profile_page.dart';
import 'package:travel_manager/pages/signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web, // Specify web options directly
    );
  } catch (e) {
    print('Error initializing Firebase: $e'); // Print error for debugging
    return; // Stop execution if Firebase initialization fails
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Travel Planner",
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        // '/': (context) => const AuthWrapper(),
        // '/login': (context) => const LoginPage(),
        // '/signup': (context) => const SignUpScreen(),
        // '/home': (context) => const HomeScreen(),
        // '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while checking authentication state
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Handle error state
          return Scaffold(
            body: Center(
              child: Text(
                'Something went wrong. Please try again later.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          // If the user is logged in, navigate to the home screen
          return const HomeScreen();
        } else {
          // If the user is not logged in, show the login page
          return const LoginPage();
        }
      },
    );
  }
}
