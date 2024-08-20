import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/login/confirm_phone_number.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Control profile của user
 */

class ProfileUser extends StatefulWidget {
  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  //A. Dữ liệu
  UserController userController = Get.find(); // GetxController

  // TextField controller
  TextEditingController textNewPassword = TextEditingController();
  TextEditingController textNewDisplayName = TextEditingController();
  TextEditingController textNewPhotoURL = TextEditingController();

  //B. init
  @override
  void initState() {
    super.initState();
    // Tạo giá trị ban đầu cho TextField
    textNewDisplayName.text = userController.firebaseAuth.currentUser?.displayName ?? "";
    textNewPhotoURL.text = userController.firebaseAuth.currentUser?.photoURL ?? "";
  }

  //C. Dispose
  @override
  void dispose() {
    super.dispose();
    textNewDisplayName.dispose();
    textNewPhotoURL.dispose();
    textNewPassword.dispose();
  }

  //D. Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode()); // Ẩn bàn phím khi click
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(null),
          title: const Text("My Profile", style: TextStyle(color: Colors.white, fontSize: 24)),
          backgroundColor: Colors.blue,
        ),
        body: GetBuilder<UserController>(
          builder: (controller) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: Text("Profile", style: TextStyle(fontSize: 20),))
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
