import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this is generated correctly
import 'staff.dart'; // Your full UI logic

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp(connectionStatus: '',));
}

/// Root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key, required String connectionStatus});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Firestore App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: StaffFormPage(), // Starts with the staff form
    );
  }
}
