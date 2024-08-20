import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/home/chat/display_messenger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Chat Page
 */

class ChatPage extends StatelessWidget {
  TextEditingController textMessage = TextEditingController();
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
            const Expanded(child: DisplayMessenger()),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: textMessage,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: "Messenger",
                      enabled: true,
                      // contentPadding: const EdgeInsets.only(left: 15, bottom: 8, top: 8),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (textMessage.text.isNotEmpty) {
                            // Thêm vào nút dữ liệu messenger
                            userController.firestore.collection("Messenger").doc().set({
                              'messenger': textMessage.text.toString().trim(),
                              'time': DateTime.now(),
                              'name' : "",
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                      fillColor: Colors.white,
                    ),
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
