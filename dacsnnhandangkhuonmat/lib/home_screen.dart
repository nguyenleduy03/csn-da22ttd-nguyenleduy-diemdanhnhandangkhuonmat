import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ClassListScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedClass; // Chứa lớp đã chọn
  late Future<List<String>> classListFuture; // Dữ liệu danh sách lớp từ Firestore

  @override
  void initState() {
    super.initState();
    // Khởi tạo Future để lấy danh sách lớp từ Firestore
    classListFuture = _getClassList();
  }

  // Hàm lấy danh sách lớp từ Firestore
  Future<List<String>> _getClassList() async {
    try {
      // Truy vấn collection "classes" từ Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('classes').get();
      // Chuyển dữ liệu từ Firestore thành danh sách các tên lớp
      return querySnapshot.docs.map((doc) => doc['classname'] as String).toList();
    } catch (e) {
      print("Lỗi khi lấy dữ liệu lớp: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  // Đăng xuất người dùng
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/auth'); // Chuyển hướng về màn hình đăng nhập
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          // Avatar hiển thị trên thanh AppBar
          PopupMenuButton<String>(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  user?.email?[0].toUpperCase() ?? '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                _viewProfile(context, user?.uid);
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Xem Hồ Sơ'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Đăng Xuất'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sử dụng FutureBuilder để lấy danh sách lớp
            FutureBuilder<List<String>>(
              future: classListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Lỗi khi tải danh sách lớp');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // Nếu có dữ liệu, hiển thị DropdownButton
                  final classes = snapshot.data!;
                  return DropdownButton<String>(
                    value: selectedClass ?? classes.first,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedClass = newValue;
                      });
                    },
                    items: classes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    isExpanded: true,
                    hint: const Text('Chọn Lớp'),
                  );
                } else {
                  return const Text('Không có lớp nào');
                }
              },
            ),
            const SizedBox(height: 20),
            // GridView cho các chức năng khác
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFunctionCard(
                    context,
                    icon: Icons.schedule,
                    label: 'Xem Lịch Dạy',
                    onPressed: () => _viewSchedule(context),
                  ),
                  _buildFunctionCard(
                    context,
                    icon: Icons.list_alt,
                    label: 'Xem Danh Sách Lớp',
                    onPressed: () => _viewClassList(context),
                  ),
                  _buildFunctionCard(
                    context,
                    icon: Icons.face,
                    label: 'Điểm Danh Khuôn Mặt',
                    onPressed: () => _faceAttendance(context),
                  ),
                  _buildFunctionCard(
                    context,
                    icon: Icons.check_circle,
                    label: 'Điểm Danh Thông Thường',
                    onPressed: () => _manualAttendance(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tạo thẻ chức năng
  Widget _buildFunctionCard(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Hàm xem hồ sơ giảng viên
  void _viewProfile(BuildContext context, String? userId) async {
    if (userId != null) {
      // Lấy thông tin giảng viên từ Firestore
      var doc = await FirebaseFirestore.instance.collection('teachers').doc(userId).get();
      if (doc.exists) {
        var data = doc.data();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Hồ Sơ Giáo Viên'),
            content: Text(
                'Email: ${data?['email'] ?? "Chưa có email"}\n'
                    'Tên: ${data?['name'] ?? "Chưa có tên"}\n'
                    'Điện thoại: ${data?['phone'] ?? "Chưa có điện thoại"}\n'
              // Thêm các trường thông tin khác nếu cần
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        // Nếu không tìm thấy thông tin giảng viên
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Lỗi'),
            content: Text('Không tìm thấy thông tin giảng viên'),
          ),
        );
      }
    }
  }

  // Hàm xem lịch dạy
  void _viewSchedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Lịch Dạy'),
        content: Text('Hiển thị lịch dạy từ Firebase'),
      ),
    );
  }

  // Hàm xem danh sách sinh viên trong lớp
  void _viewClassList(BuildContext context) {
    if (selectedClass != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClassListScreen(selectedClass: selectedClass),
        ),
      );
    } else {
      // Xử lý trường hợp khi không có lớp nào được chọn
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn lớp trước')),
      );
    }
  }

  // Hàm điểm danh bằng khuôn mặt
  void _faceAttendance(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Điểm Danh Khuôn Mặt'),
        content: Text('Điểm danh bằng khuôn mặt và lưu kết quả vào Firebase'),
      ),
    );
  }

  // Hàm điểm danh thông thường
  void _manualAttendance(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Điểm Danh Thông Thường'),
        content: Text('Điểm danh thủ công và lưu kết quả vào Firebase'),
      ),
    );
  }
}
