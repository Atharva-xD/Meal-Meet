import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pirateprogrammers/volunteer/volunteer_home_page.dart';
import 'package:pirateprogrammers/login_page.dart';
import 'package:pirateprogrammers/registration_page.dart';
import 'Bank/bank_home_page.dart';
import 'Bank/bank_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        // '/': (context) =>
        //     HomeBankScreen(user: FirebaseAuth.instance.currentUser!),
        //'/': (context) => LoginPage(),
        //'/home': (context) => HomePage(),
        '/homebank': (context) =>
            HomeBankScreen(user: FirebaseAuth.instance.currentUser!),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/registration': (context) => RegistrationPage(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user != null) {
      return HomePage(); // If user is logged in, show the home page
    } else {
      return const LoginPage(); // If user is not logged in, show the login page
    }
  }
}
