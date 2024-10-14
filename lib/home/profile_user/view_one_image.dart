import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'get_avatar_from_storage.dart';

class ViewAvatar extends StatelessWidget {

  ViewAvatar({super.key, required this.uid});

  final FirestoreController firestoreController = Get.find();
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: viewAvatar(context),
    );
  }

  viewAvatar(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Ảnh
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: GetAvatarFromStorage(uid: uid,),
          ),
          // Nút back
          Padding(
            padding: const EdgeInsets.only(left: 3, top: 25),
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
        ],
      ),
    );
  }
}
