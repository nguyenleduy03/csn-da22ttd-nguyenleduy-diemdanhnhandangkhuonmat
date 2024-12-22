import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassListScreen extends StatelessWidget {
  final String? selectedClass; // Nhận lớp đã chọn từ màn hình trước

  const ClassListScreen({Key? key, this.selectedClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedClass == null || selectedClass!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Danh Sách Sinh Viên'),
        ),
        body: const Center(child: Text('Không có lớp được chọn')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Sinh Viên - $selectedClass'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllData(selectedClass!), // Lấy tất cả dữ liệu từ Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          } else {
            final allData = snapshot.data!;
            return ListView.builder(
              itemCount: allData.length,
              itemBuilder: (context, index) {
                final data = allData[index];
                return ListTile(
                  title: Text('Dữ liệu: ${data['name'] ?? 'Không có tên'}'),
                  subtitle: Text('ID: ${data['id'] ?? 'Không có ID'}'),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Hàm để lấy tất cả dữ liệu từ Firestore
  Future<List<Map<String, dynamic>>> _getAllData(String className) async {
    try {
      // Truy cập vào document lớp học trong collection "classes"
      DocumentReference classDocRef = FirebaseFirestore.instance
          .collection('classes')
          .doc(className);  // Document của lớp học có ID là className

      // Kiểm tra xem document lớp có tồn tại không
      DocumentSnapshot classDocSnapshot = await classDocRef.get();
      if (!classDocSnapshot.exists) {
        print("Không tìm thấy lớp học với ID: $className");
        return [];  // Trả về danh sách trống nếu lớp không tồn tại
      }

      // Truy cập vào subcollection "students" của lớp
      CollectionReference studentsRef = classDocRef.collection('students');
      QuerySnapshot querySnapshot = await studentsRef.get();

      // Nếu subcollection không có dữ liệu
      if (querySnapshot.docs.isEmpty) {
        print("Không có sinh viên trong subcollection 'students' của lớp $className.");
        return [];  // Trả về danh sách trống nếu không có sinh viên
      }

      // Lấy tất cả dữ liệu từ subcollection và trả về danh sách
      List<Map<String, dynamic>> allData = [];
      for (var doc in querySnapshot.docs) {
        allData.add(doc.data() as Map<String, dynamic>);
      }

      return allData;  // Trả về tất cả dữ liệu dưới dạng danh sách Map
    } catch (e) {
      print("Lỗi khi lấy dữ liệu từ Firestore: $e");
      return [];  // Trả về danh sách trống nếu có lỗi
    }
  }
}