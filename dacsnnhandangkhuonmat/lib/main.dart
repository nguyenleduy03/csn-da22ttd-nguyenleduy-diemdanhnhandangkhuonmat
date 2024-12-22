import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import cấu hình Firebase
import 'auth_screen.dart'; // Import màn hình đăng nhập/đăng ký
import 'home_screen.dart'; // Import màn hình chính nếu người dùng đã đăng nhập
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'login_screen.dart';
import 'register_screen.dart';

void main() async {
  // Khởi tạo Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Dùng cấu hình Firebase đã tạo
  );

  // Kiểm tra trạng thái đăng nhập của người dùng
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Chạy ứng dụng
  runApp(MyApp(
    isLoggedIn: currentUser != null, // true nếu người dùng đã đăng nhập
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Nếu đã đăng nhập, vào màn hình chính; nếu không, vào AuthScreen
      home: isLoggedIn ? const HomeScreen() :  AuthScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth': (context) =>  AuthScreen(),
      },
    );
  }
}
