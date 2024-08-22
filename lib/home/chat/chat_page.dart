import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/home/chat/display_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Chat Page
 */

class ChatPage extends StatelessWidget {
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();
  UserController userController = Get.find();

  // Trang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(null),
        title: const Text("Chat page", style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DisplayMessage(email: userController.firebaseAuth.currentUser?.email ?? ""),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: textMessage,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: "Message",
                      enabled: true,

                      // Thực hiện chat: Lưu message của email đang login vào firestore
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (textMessage.text.isNotEmpty) {
                            // Hàm add to Firestore: collection: tên bảng ('messenger')
                            firestoreController.firestore.collection("message").add({
                              'message': textMessage.text.toString().trim(),
                              'time': DateTime.now(),
                              'email': userController.firebaseAuth.currentUser?.email,
                              'id': "",
                            }).then((value) {
                              print("ID:\n" + value.id);
                              // Lưu (cập nhật) tên id vừa tạo (tự động) vào nội dung bên trong
                              firestoreController.firestore.collection('message').doc(value.id).update({'id': value.id});
                              // userController.firestore.collection('message').doc(value.id).delete(); // Xoá dữ liệu của 1 id
                            });

                            textMessage.clear(); // clear TextField
                            FocusScope.of(context).requestFocus(FocusNode()); // Đóng bàn phím
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                      fillColor: Colors.white,
                    ),
                    // validator: (value) {
                    //   print("validator: $value");
                    //   return null;
                    // },
                    // onSaved: (value) {
                    //   textMessage.text = value!;
                    // },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
    );
  }
}
