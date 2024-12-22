import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _teacherCodeController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signUp() async {
    String name = _nameController.text;
    DateTime? dob = _getDateFromString(_dobController.text);
    String teacherCode = _teacherCodeController.text;

    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid date of birth!')),
      );
      return;
    }

    User? user = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
      name,
      dob,
      teacherCode,
    );
    if (user != null) {
      Navigator.pop(context);  // Quay lại màn hình login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed. Please try again!')),
      );
    }
  }

  DateTime? _getDateFromString(String dateString) {
    try {
      List<String> parts = dateString.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _dobController,
              decoration: InputDecoration(labelText: 'Date of Birth (dd/MM/yyyy)'),
            ),
            TextField(
              controller: _teacherCodeController,
              decoration: InputDecoration(labelText: 'Teacher Code'),
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
