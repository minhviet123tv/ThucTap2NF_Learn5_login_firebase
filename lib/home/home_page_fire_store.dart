import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';

/*
Home page sử dụng FireStore
 */

class HomePageFireStore extends StatelessWidget {
  // Trang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(null),
        title: const Text("Home page FireStore", style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue,
      ),
      body: const Center(child: Text("Home page FireStore", style: TextStyle(fontSize: 20),)),
      resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
    );
  }
}
