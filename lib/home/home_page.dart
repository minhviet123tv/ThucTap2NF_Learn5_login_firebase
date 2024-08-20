import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';

/*
Home page
 */

class HomePage extends StatelessWidget {
  // Truy vấn theo tên dữ liệu trên RealTime Database Firebase (Dạng nút của mô hình dữ liệu tree)
  final DatabaseReference dataFromRealtimeDatabase = FirebaseDatabase.instance.ref('RealTimeQuery');

  // TextField Controller
  TextEditingController textAge = TextEditingController();
  TextEditingController textCountry = TextEditingController();
  TextEditingController textName = TextEditingController();

  // Trang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(null),
        title: const Text("Home page", style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // FocusManager.instance.primaryFocus?.unfocus
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text("Home Page"),),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
    );
  }
}
