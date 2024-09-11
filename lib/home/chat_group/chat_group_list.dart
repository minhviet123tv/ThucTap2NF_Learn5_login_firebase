import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/chat_group/create_new_room_chat_group.dart';
import 'package:fire_base_app_chat/home/chat_group/chat_group_room.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Chat Page
 */

class ChatGroup extends StatelessWidget {
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();

  // Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(null),
          title: const Text("Chat Group", style: TextStyle(color: Colors.white, fontSize: 24)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => Get.to(() => CreateChatGroup()),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            ),
          ],
          backgroundColor: Colors.blue,
        ),
        body: listChatGroup(),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  // Danh sách các chat group của user đang login
  Widget listChatGroup() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GetBuilder<FirestoreController>(
        builder: (controller) {
          return StreamBuilder(
            //1. Truy vấn 'users' lấy danh sách 'chat_group_id' của user đang login -> Truy vấn sang bảng 'chatgroup'
            stream: firestoreController.firestore
                .collection('users')
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('chat_group_id')
                .snapshots(),
            builder: (context, snapshotId) {
              if (snapshotId.hasError) {
                return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
              }
              if (snapshotId.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Danh sách các cuộc chat, hiện text thông báo nếu chưa có cuộc chat group nào
              return snapshotId.data!.docs.isNotEmpty
                  ? ListView.builder(
                      itemCount: snapshotId.data?.docs.length,
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                          //2. Truy vấn thông tin của 'chatgroup' room theo id của stream phía trên trước đó
                          stream:
                              firestoreController.firestore.collection('chatgroup').doc(snapshotId.data?.docs[index].id).snapshots(),
                          builder: (context, snapshotGroup) {
                            if (snapshotGroup.hasError) {
                              return const Center(child: Text("Somethings went wrong!", style: TextStyle(fontSize: 20)));
                            }
                            if (snapshotGroup.connectionState == ConnectionState.waiting) {
                              return const Center(child: SizedBox());
                            }

                            //3. Hiển thị thông tin group chat và tin nhắn cuối, thời gian của tin nhắn cuối
                            return StreamBuilder(
                              stream: firestoreController.firestore
                                  .collection('chatgroup')
                                  .doc(snapshotId.data?.docs[index].id)
                                  .collection('message_chatgroup')
                                  .orderBy('time', descending: true)
                                  .snapshots(),
                              builder: (context, snapshotMessage) {
                                if (snapshotMessage.hasError) {
                                  return const Center(child: Text("Somethings went wrong!", style: TextStyle(fontSize: 20)));
                                }
                                if (snapshotMessage.connectionState == ConnectionState.waiting) {
                                  return const Center(child: Text(""));
                                }

                                // Trả về khi có data và có tin nhắn trong 'chatgroup'
                                if (snapshotMessage.data!.docs.isNotEmpty) {
                                  QueryDocumentSnapshot query = snapshotMessage.data!.docs[0]; // dữ liệu tin nhắn cuối
                                  DateTime dateTime = query['time'].toDate(); // Lấy time theo định đạng
                                  return Card(
                                    color: Colors.green[100],
                                    child: ListTile(
                                      title: Text(
                                        "${snapshotGroup.data?['groupName']}",
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(query['content'].toString()),
                                      trailing: dateTime.minute >= 10
                                          ? Text("${dateTime.hour}:${dateTime.minute}")
                                          : Text("${dateTime.hour}:0${dateTime.minute}"),

                                      //4. Vào chat group khi click (với id trong danh sách 'chat_group_id' đã truy vấn)
                                      onTap: () => Get.to(() => ChatGroupRoom(
                                            idChatGroupRoom: snapshotId.data!.docs[index].id,
                                            isCreateGroup: false,
                                          )),
                                    ),
                                  );
                                }

                                return const SizedBox();
                              },
                            );
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Text("You don't have any group chats yet.", style: TextStyle(fontSize: 16, color: Colors.black54)),
                    );
            },
          );
        },
      ),
    );
  }
}
