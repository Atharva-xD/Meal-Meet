import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pirateprogrammers/volunteer/volunteer_home_page.dart';
import 'package:pirateprogrammers/Bank/bank_home_page.dart';
import 'package:pirateprogrammers/registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorMessage;
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              obscureText: _isObscured,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _errorMessage = null;
                });
                try {
                  final UserCredential userCredential =
                      await _auth.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                  final uid = userCredential.user!.uid;
                  final role = await _fetchUserRole(uid);
                  if (role == 'Volunteer') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else if (role == 'Foodbank') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeBankScreen(user: FirebaseAuth.instance.currentUser!)),
                    );
                  } else {
                    setState(() {
                      _errorMessage = 'Invalid credentials. Please try again.';
                    });
                  }
                } catch (e) {
                  print('Error: $e');
                  setState(() {
                    _errorMessage = 'Invalid credentials. Please try again.';
                  });
                }
              },
              child: const Text('Login'),
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate to registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: const Text('Create New Account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _fetchUserRole(String uid) async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot['role'];
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
    return null;
  }
}
