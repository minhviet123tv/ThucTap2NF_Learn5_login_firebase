import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Chat Page
 */

class ChatGroupRoom extends StatelessWidget {
  final String idChatGroupRoom;
  bool isCreateGroup;

  ChatGroupRoom({super.key, required this.idChatGroupRoom, required this.isCreateGroup});

  // Dữ liệu
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();
  final ScrollController _scrollController = ScrollController();

  // Trang
  @override
  Widget build(BuildContext context) {
    // Luôn cuộn đến điểm cuối của list tin nhắn khi mới mở
    WidgetsBinding.instance.addPostFrameCallback((_) => firestoreController.scrollListView(_scrollController));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            isCreateGroup ? Get.toNamed('/home') : Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('chatgroup').doc(idChatGroupRoom).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data['groupName'], style: const TextStyle(color: Colors.white, fontSize: 20));
            } else {
              return const SizedBox();
            }
          },
        ),
        backgroundColor: Colors.green,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              //I. Danh sách các tin nhắn
              listMessage(),

              //II. TextField gửi tin nhắn
              textFieldMessage(context),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, // Đẩy bottom sheet, TextField lên khi có bàn phím
    );
  }

  //I. Danh sách các tin nhắn
  Widget listMessage() {
    return StreamBuilder(
      // Stream truy vấn danh sách 'message' trong bảng 'chatroom' theo id (hoặc tạo nếu chưa có)
      stream: firestoreController.firestore
          .collection("chatgroup")
          .doc(idChatGroupRoom)
          .collection('message_chatgroup')
          .orderBy('time', descending: false) // descending: Sắp xếp giảm
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Danh sách tin nhắn
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height * 0.84 // Màn hình dọc thì 84%
                : MediaQuery.of(context).size.height * 0.66, // Màn hình ngang thì 66%
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              reverse: false,
              itemCount: snapshot.data!.docs.length,
              // List (bởi docs) của bảng 'message_chatgroup'
              itemBuilder: (context, index) {
                QueryDocumentSnapshot query = snapshot.data!.docs[index]; // dữ liệu của 1 tin nhắn theo thứ tự index
                DateTime dateTime = query['time'].toDate(); // Lấy time theo định đạng
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    // Sắp xếp vị trí hiển thị của message theo user đang login
                    crossAxisAlignment: firestoreController.firebaseAuth.currentUser?.email == query['sendBy']
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      // Item message
                      SizedBox(
                        width: 300,
                        child: ListTile(
                          title: Text(query['sendBy'] ?? ""), // Người gửi (Nội dung của 'sendBy' trong truy vấn)
                          subtitle: SizedBox(
                            // width: 200,
                            child: Text(
                              "${query['content']}", // Nội dung tin nhắn
                              softWrap: true,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          trailing: dateTime.minute >= 10
                              ? Text("${dateTime.hour}:${dateTime.minute}")
                              : Text("${dateTime.hour}:0${dateTime.minute}"), // Thời gian nhắn tin
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: firestoreController.firebaseAuth.currentUser?.email == query['sendBy']
                                  ? Colors.blue
                                  : Colors.purpleAccent,
                            ),
                            borderRadius: firestoreController.firebaseAuth.currentUser?.email == query['sendBy']
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  )
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox(
          height: 15,
        );
      },
    );
  }

  //II. TextField gửi tin nhắn
  Widget textFieldMessage(BuildContext context) {
    return TextFormField(
      controller: textMessage,
      autofocus: false,
      decoration: InputDecoration(
        filled: true, // Không trong suốt
        hintText: "Message",
        enabled: true,
        suffixIcon: IconButton(
          onPressed: () {
            // Lưu message của user đang login vào firestore
            firestoreController.sendMessageChatGroup(context, textMessage, idChatGroupRoom, _scrollController);
          },
          icon: const Icon(Icons.send, color: Colors.blue),
        ),
        fillColor: Colors.white,
      ),
    );
  }
}
