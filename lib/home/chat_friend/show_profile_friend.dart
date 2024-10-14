import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/fire_storage_controller.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/home/profile_user/view_one_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../profile_user/get_avatar_from_storage.dart';

/*
Control profile của user
 */

class ShowProfileFriend extends StatelessWidget {
  //A. Dữ liệu
  UserController userController = Get.find();

  // GetxController
  FirestoreController firestoreController = Get.find();
  FireStorageController fireStorageController = Get.find();

  // Khởi tạo
  final Map<String, dynamic> userFriend;

  ShowProfileFriend({super.key, required this.userFriend});

  //D. Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // Ẩn bàn phím khi click,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Stack(
              children: [
                // Nút back
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black12,
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //I. Info user
                        const SizedBox(height: 30),
                        welcomeUser(),
                        const SizedBox(height: 20),

                        //II. Thông tin, tin tức đăng cá nhân
                        contentNewsFireStorage(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //I.1 Info Welcome
  Widget welcomeUser() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //1. avartar
          GetBuilder<FireStorageController>(builder: (GetxController controller) => imageAvatar()),
          const SizedBox(height: 10),

          //2. Email and time
          emailAndTime(),
        ],
      ),
    );
  }

  //I.2 Hiển thị avatar: click ảnh để xem. Chọn icon camera để upload, thay ảnh mới
  Widget imageAvatar() {
    // Dùng ElevatedButton tạo thành nút ảnh (hay ảnh dạng nút)
    return ElevatedButton(
      onPressed: () {
        Get.to(() => ViewAvatar(uid: userFriend['uid'])); // Xem ảnh avatar
      },
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(5)),
      child: SizedBox(
        width: 100, // Tạo kích thước cho khối Stack ảnh
        height: 100,
        child: ClipOval(
          child: GetAvatarFromStorage(uid: userFriend['uid']),
        ),
      ),
    );
  }

  //II. Email And Time
  emailAndTime() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        userFriend['email'], // email tài khoản firebase
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        textAlign: TextAlign.left,
      ),
    );
  }

  //III. Hiển thị 'news_content'
  contentNewsFireStorage() {
    //1. Tạo key 'news_content' nếu chưa có
    return FutureBuilder(
      future: fireStorageController.firestore.collection('users').doc(userFriend['uid']).get().then(
        (documentSnapshot) async {
          if (documentSnapshot.exists) {
            if (documentSnapshot.data()!.containsKey('news_content') == false) {
              fireStorageController.firestore.collection('users').doc(userFriend['uid']).set(
                {'news_content': ""},
                SetOptions(merge: true),
              );
            }
          }
        },
      ),
      builder: (context, futureContent) {
        if (futureContent.hasError) {
          return const Center(child: Text("Error 1"));
        }
        if (futureContent.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        //2. Hiển thị 'news_content' khi có nội dung
        return contentNews();
      },
    );
  }

  //III. Content news
  contentNews() {
    return GetBuilder<FireStorageController>(
      builder: (FireStorageController controller) {
        //1. lấy dữ liệu
        return StreamBuilder(
          stream: fireStorageController.firestore.collection('users').doc(userFriend['uid']).snapshots(),
          builder: (context, streamNewsContent) {
            if (streamNewsContent.hasError) {
              return const Center(child: Text("Error 2"));
            }
            if (streamNewsContent.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }

            //2. Hiển thị 'news_content'
            return streamNewsContent.data!['news_content'].toString().isNotEmpty
                ? Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Text(
                          streamNewsContent.data!['news_content'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                : const SizedBox();
          },
        );
      },
    );
  }
}
