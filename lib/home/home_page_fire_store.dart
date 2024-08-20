import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/user_model.dart';

/*
Home page sử dụng FireStore
 */

class HomePageFireStore extends StatelessWidget {

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance; // Cloud Firebase Firestore
  UserController userController = Get.find();

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
