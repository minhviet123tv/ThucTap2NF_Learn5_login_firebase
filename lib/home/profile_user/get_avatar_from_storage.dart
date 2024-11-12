import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/fire_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetAvatarFromStorage extends StatelessWidget {
  GetAvatarFromStorage({super.key, required this.uid});

  final FireStorageController fireStorageController = Get.find();
  final String uid; // uid của friend hoặc currentUser

  @override
  Widget build(BuildContext context) {
    return getAvatar();
  }

  //* Lấy và hiện ảnh avatar (lưu file trên fire storage, link được lưu ở firestore của user)
  getAvatar() {
    //I. Thêm key và ảnh random nếu chưa có 'avatar_url' cho currentUser
    // (Dùng và đặt lệnh trực tiếp ở FutureBuilder để đảm bảo lệnh được thực hiện trước khi load ảnh)
    return FutureBuilder(
      future: fireStorageController.firestore.collection('users').doc(uid).get().then(
        (documentSnapshot) async {
          if (documentSnapshot.exists) {
            if (documentSnapshot.data()!.containsKey('avatar_url') == false) {
              // set() khi dùng với merge -> Thêm 'avatar_url' nếu chưa có | Nếu có rồi thì sẽ set lại
              // Ở đây là đã kiểm tra điều kiện nên chưa có 'avatar_url' (ghi rõ lại câu lệnh từ đầu để chắc chắn đúng địa chỉ)
              fireStorageController.firestore.collection('users').doc(uid).set(
                {'avatar_url': fireStorageController.listUrlAvatar[Random().nextInt(fireStorageController.listUrlAvatar.length)]},
                SetOptions(merge: true),
              );
            }
          }
        },
      ),
      builder: (context, futureAddKey) {
        // Future này chỉ thực hiện void, không cần trả về dữ liệu nên chỉ xử lý error và waiting 😉
        if (futureAddKey.hasError) {
          return const Center(child: Text("Error"));
        }
        if (futureAddKey.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // 💪
        }

        //II. Lấy và hiển thị ảnh avatar đã lưu link trong firestore (Dùng stream để hiển thị dữ liệu thực ngay khi có ảnh)
        return StreamBuilder(
          stream: fireStorageController.firestore.collection('users').doc(uid).snapshots(),
          builder: (context, streamUserDocument) {
            if (streamUserDocument.hasError) {
              return const Center(child: Text("Error"));
            }
            if (streamUserDocument.connectionState == ConnectionState.waiting) {
              return const SizedBox(); // 💪
            }

            // Trả về ảnh khi có dữ liệu, có key và data (load ảnh từ link ảnh)
            if (streamUserDocument.hasData) {
              if (streamUserDocument.data!['avatar_url'] != null) {
                return Image.network(streamUserDocument.data!['avatar_url'], fit: BoxFit.cover);
              } else {
                return Image.asset("assets/images/hoa_nang.jpg", fit: BoxFit.cover); // ảnh mặc định ở app
              }
            }

            // Trả về mặc định khi không có dữ liệu, hoặc có dữ liệu nhưng key ảnh không có data (dự phòng)
            return Image.asset("assets/images/hoa_nang.jpg", fit: BoxFit.cover);
          },
        );
      },
    );
  }
}

//  return Image.asset("assets/images/hoa_nang.jpg", fit: BoxFit.cover);
