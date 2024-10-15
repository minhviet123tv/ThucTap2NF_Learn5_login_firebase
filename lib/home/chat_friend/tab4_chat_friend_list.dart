import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/chat_friend/show_profile_friend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../custom_widget/card_item_friend.dart';
import '../../custom_widget/card_item_friend_swipe.dart';
import '../profile_user/get_avatar_from_storage.dart';

/*
Danh sách các cuộc chat của user đang login
Sắp xếp: Cuộc chat có tin nhắn mới nhất
 */

class ChatFriendList extends StatelessWidget {
  FirestoreController firestoreController = Get.find();

  //D. Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: chatListWithFriend(),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  //I.1 Chat List: hiển thị các cuộc chat theo thứ tự có tin nhắn mới nhất
  Widget chatListWithFriend() {
    return StreamBuilder(
      //1. Lấy danh sách 'chat_room_id' của current user chứa các cuộc chat và thông tin cuộc chat. Sắp xếp giảm, gần nhất sẽ ở trên
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('chat_room_id')
          .orderBy('last_time', descending: true)
          .snapshots(),
      builder: (context, streamListChatRoomId) {
        if (streamListChatRoomId.hasError) {
          return const Center(child: Text("Somethings went wrong!", style: TextStyle(fontSize: 16)));
        }
        if (streamListChatRoomId.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Load list
        }

        //2. Danh sách item các cuộc chat với friend đã từng chat (Nếu có ít nhất 1 cuộc chat, Có thể có message hoặc không)
        if (streamListChatRoomId.hasData && streamListChatRoomId.data!.docs.isNotEmpty) {
          return listChat(streamListChatRoomId);
        }

        // Trả về mặc định là thông báo không có cuộc chat nào
        return const Center(child: Text("No chat with friends.", style: TextStyle(fontSize: 16, color: Colors.black54)));
      },
    );
  }

  //I.2  Danh sách các cuộc chat với friend: Truyền danh sách id của chatroom
  Widget listChat(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamListChatRoomId) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: streamListChatRoomId.data?.docs.length,
      itemBuilder: (context, index) {
        // Widget Item: Tổng hợp các dữ liệu đã lấy được vào widget item
        return Padding(
          padding: index == streamListChatRoomId.data!.docs.length - 1
              ? const EdgeInsets.only(bottom: 10.0)
              : const EdgeInsets.only(top: 0.0),

          // Tạo swipe cho item
          child: itemFriendChat(streamListChatRoomId, index),
        );
      },
    );
  }

  itemFriendChat2(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamListChatRoomId, int index){

  }

  //I.3 Item Friend Chat
  itemFriendChat(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamListChatRoomId, int index) {
    DateTime dateTime = streamListChatRoomId.data!.docs[index]['last_time'].toDate(); // Lấy time theo định đạng
    return CardItemFriendSwipe(
      uidUser: streamListChatRoomId.data?.docs[index]['friend_uid'],
      backGroundCard: Colors.grey[200],
      onTapCard: () {
        firestoreController.goToChatRoomWithFriend({
          'email': streamListChatRoomId.data?.docs[index]['friend_email'],
          'uid': streamListChatRoomId.data?.docs[index]['friend_uid'],
        });
      },
      onTapAvatar: () {
        Get.to(() => ShowProfileFriend(userFriend: {
              'email': streamListChatRoomId.data?.docs[index]['friend_email'],
              'uid': streamListChatRoomId.data?.docs[index]['friend_uid'],
            }));
      },
      titleWidget: Text(streamListChatRoomId.data?.docs[index]['friend_email']),
      subTitleWidget: Text(
        streamListChatRoomId.data!.docs[index]['last_content'] ?? "",
        style: streamListChatRoomId.data?.docs[index]['seen']
            ? const TextStyle(fontWeight: FontWeight.w400)
            : const TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
      ),

      // Số lượng tin nhắn mới (Nếu có)
      trailingIconTop: streamListChatRoomId.data?.docs[index]['new_message'] > 0
          ? Badge(
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1),
                child: () {
                  if (streamListChatRoomId.data?.docs[index]['new_message'] > 99) {
                    return const Text(
                      '99+',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    );
                  } else {
                    return Text(
                      '${streamListChatRoomId.data?.docs[index]['new_message']}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    );
                  }
                }(),
              ),
              backgroundColor: Colors.green,
            )
          : const SizedBox(),

      // Thời gian (giờ) của tin nhắn cuối
      trailingIconBottom: dateTime.minute >= 10
          ? Text("${dateTime.hour}:${dateTime.minute}", style: const TextStyle(fontSize: 12))
          : Text("${dateTime.hour}:0${dateTime.minute}", style: const TextStyle(fontSize: 12)),
      swipeLabel: "Delete",

      // Sự kiện của item swipe (hiện tại chỉ tạo 1 item)
      onPressedSwipe: (context){
        // Xoá hiển thị trong danh sách cuộc chat
        firestoreController.deleteShowChatWithFriend(streamListChatRoomId.data?.docs[index]['friend_uid']);
      },
    ) ;
  }
}
