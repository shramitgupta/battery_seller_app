import 'package:battery_service_app/Auth/Admin_auth/adminlogin.dart';
import 'package:battery_service_app/admin_homescreen/admin_homescreen.dart';
import 'package:battery_service_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (FirebaseAuth.instance.currentUser != null)
          ? const AdminHomeScreen() // UserPhoneNoLogin
          : const AdminLogin(),
    );
  }
}
