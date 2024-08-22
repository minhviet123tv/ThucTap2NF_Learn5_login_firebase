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

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userFriend;
  final String chatRoomId;

  ChatRoom({required this.userFriend, required this.chatRoomId});

  // Dữ liệu
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();
  UserController userController = Get.find();

  // Truy vấn chat
  // final Stream<QuerySnapshot> _chatroom = FirebaseFirestore.instance.collection("chatroom").doc(chatRoomId).snapshots();

  // Trang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(null),
        title: Text(userFriend['email'], style: const TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //I. Hiển thị các tin nhắn
            Expanded(
              child: StreamBuilder(
                // Truy vấn đến bảng chatroom theo id (hoặc tạo nếu chưa có)
                stream: firestoreController.firestore
                    .collection("chatroom")
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy('time', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Somethings went wrong"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Danh sách tin nhắn
                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: snapshot.data!.docs.length, // List bởi docs của bảng 'message' trên Cloud FireStore
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot query = snapshot.data!.docs[index]; // dữ liệu của 1 tin nhắn (message)
                      Timestamp time = query['time']; // Đổi định đạng time
                      DateTime dateTime = time.toDate();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: firestoreController.firebaseAuth.currentUser?.email == query['senBy']
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 300,
                              child: ListTile(
                                title: Text(query['senBy']), // Người gửi (Nội dung của 'senBy' trong truy vấn)
                                subtitle: SizedBox(
                                  width: 200,
                                  child: Text(
                                    "${query['message']}",
                                    softWrap: true,
                                    textAlign: TextAlign.left,
                                  ), // Tự xuống dòng
                                ),
                                trailing: Text("${dateTime.hour}:${dateTime.minute}"),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: firestoreController.firebaseAuth.currentUser?.email == query['senBy']
                                        ? Colors.blue
                                        : Colors.purpleAccent,
                                  ),
                                  borderRadius: firestoreController.firebaseAuth.currentUser?.email == query['senBy']
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
                                ), // Thời gian nhắn tin
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            //II. TextField gửi tin nhắn
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
                          // if (textMessage.text.isNotEmpty) {
                          // Hàm add to Firestore: collection: tên bảng ('message')
                          // firestoreController.firestore.collection("message").add({
                          //   'message': textMessage.text.toString().trim(),
                          //   'time': DateTime.now(),
                          //   'email': userController.firebaseAuth.currentUser?.email,
                          //   'id': "",
                          // }).then((value) {
                          //   print("ID:\n" + value.id);
                          //   // Lưu (cập nhật) tên id vừa tạo (tự động) vào nội dung bên trong
                          //   firestoreController.firestore.collection('message').doc(value.id).update({'id': value.id});
                          //   // userController.firestore.collection('message').doc(value.id).delete(); // Xoá dữ liệu của 1 id
                          // });
                          //
                          // textMessage.clear(); // clear TextField
                          // FocusScope.of(context).requestFocus(FocusNode()); // Đóng bàn phím
                          //
                          // }

                          sendMessage(context);
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

  // Gửi tin nhắn: Lưu vào firestore theo bảng 'chatroom' -> id -> bảng 'chats'
  void sendMessage(BuildContext context) async {
    if (textMessage.text.isNotEmpty) {
      await firestoreController.firestore.collection('chatroom').doc(chatRoomId).collection('chats').add({
        "senBy": firestoreController.firebaseAuth.currentUser?.email, // người gửi tin nhắn
        'message': textMessage.text,
        'time': DateTime.now(), // Còn FieldValue.serverTimestamp() là giờ theo tổng milisecond
      });
    }

    textMessage.clear(); // clear TextField
    FocusScope.of(context).requestFocus(FocusNode()); // Đóng bàn phím
  }
}
