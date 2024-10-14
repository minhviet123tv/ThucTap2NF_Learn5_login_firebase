import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/custom_widget/card_item_friend.dart';
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
          title: const Text("Chat Group", style: TextStyle(color: Colors.white, fontSize: 22)),
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

  //I. Danh sách chat group của user đang login
  Widget listChatGroup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GetBuilder<FirestoreController>(
        builder: (controller) {
          return StreamBuilder(
            //1.1 Truy vấn 'users' lấy danh sách 'chat_group_id' của user đang login -> Truy vấn sang bảng 'chatgroup'
            stream: firestoreController.firestore
                .collection('users')
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('chat_group_id')
                .orderBy('last_time', descending: true) // Sắp xếp giảm theo thời gian lưu ở 'chat_group_id' mỗi user
                .snapshots(),
            builder: (context, streamChatGroupId) {
              if (streamChatGroupId.hasError) {
                return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
              }
              if (streamChatGroupId.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              //1.2 Danh sách các cuộc chat khi có dữ liệu
              if (streamChatGroupId.hasData && streamChatGroupId.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: streamChatGroupId.data?.docs.length,
                  itemBuilder: (context, index) {
                    // Widget item
                    return itemChatGroup(streamChatGroupId, index);
                  },
                );
              }

              // Thông báo nếu chưa có cuộc chat group nào
              return const Center(
                child: Text("You don't have any group chats yet.", style: TextStyle(fontSize: 16, color: Colors.black54)),
              );
            },
          );
        },
      ),
    );
  }

  //II. Item ChatGroup
  Widget itemChatGroup(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamChatGroupId, int index) {
    //1. Truy vấn FutureBuilder lên bảng chung 'chatgroup' để lấy dữ liệu của mỗi một cuộc chat
    if (streamChatGroupId.hasData && streamChatGroupId.data!.docs.isNotEmpty) {
      return FutureBuilder(
        future: firestoreController.firestore.collection('chatgroup').doc(streamChatGroupId.data!.docs[index].id).get(),
        builder: (context, futureOneChatGroup) {
          if (futureOneChatGroup.hasError) {
            return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
          }
          if (futureOneChatGroup.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }

          //2. Nếu có dữ liệu -> Trả về item (Luôn cần kiểm tra điều kiện để tránh lỗi)
          if (futureOneChatGroup.hasData) {
            // Lấy time cuối của 1 cuộc chat đã lưu ở mỗi user (định đạng để sử dụng)
            DateTime dateTime = streamChatGroupId.data?.docs[index]['last_time'].toDate();
            return CardItemFriend(
              backGroundCard: Colors.grey[100],
              onTapCard: () {
                // Vào chat group khi click
                Get.to(() => ChatGroupRoom(
                      idChatGroupRoom: streamChatGroupId.data!.docs[index].id,
                      isCreateGroup: false, // Báo trạng thái sử dụng
                    ));
              },
              titleWidget: Text(
                "${futureOneChatGroup.data?['group_name']}", // Chú ý lấy đúng stream hay future
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subTitleWidget: Text(
                futureOneChatGroup.data?['last_content'],
                style: const TextStyle(color: Colors.black),
              ),
              trailingIconTop: streamChatGroupId.data?.docs[index]['new_message'] > 0
                  ? Badge(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1),
                        child: () {
                          if (streamChatGroupId.data?.docs[index]['new_message'] > 99) {
                            return const Text('99+', style: const TextStyle(fontSize: 12, color: Colors.white));
                          } else {
                            return Text(
                              '${streamChatGroupId.data?.docs[index]['new_message']}',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            );
                          }
                        }(),
                      ),
                      backgroundColor: Colors.green,
                    )
                  : const SizedBox(height: 5),
              trailingIconBottom:
                  dateTime.minute >= 10 ? Text("${dateTime.hour}:${dateTime.minute}") : Text("${dateTime.hour}:0${dateTime.minute}"),
            );
          }

          //4. Trả về mặc định
          return const SizedBox();
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
