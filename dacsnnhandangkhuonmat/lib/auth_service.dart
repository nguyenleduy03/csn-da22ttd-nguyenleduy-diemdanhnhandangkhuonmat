import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp(String email, String password, String name, DateTime dob, String teacherCode) async {
    try {
      // Đăng ký người dùng với email và mật khẩu
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin giảng viên vào Firestore
      await _firestore.collection('teachers').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'dob': dob, // Lưu ngày sinh
        'teacherid': teacherCode,
        'role': 'teacher',
      });

      return userCredential.user;
    } catch (e) {
      print('Error during sign up: $e');
      return null;
    }
  }


  // Đăng nhập người dùng
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Khôi phục mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent!");
    } catch (e) {
      print('Error during password reset: $e');
    }
  }
}
