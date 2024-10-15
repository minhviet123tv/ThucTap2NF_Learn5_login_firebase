import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/custom_widget/card_item_friend.dart';
import 'package:fire_base_app_chat/home/chat_friend/show_profile_friend.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../profile_user/get_avatar_from_storage.dart';

/*
Danh sách yêu cầu kết bạn từ người khác
 */

class FriendRequest extends StatelessWidget {
  FriendRequest({super.key});

  FirestoreController firestoreController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FirestoreController>(
        builder: (controller) => listRequestFriend(),
      ),
    );
  }

  //I. List Request Friend
  Widget listRequestFriend() {
    return StreamBuilder(
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('request_from_friend')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamFriendRequest) {
        if (streamFriendRequest.hasError) {
          return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
        }
        if (streamFriendRequest.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Hiện thị danh sách yêu cầu kết bạn
        return streamFriendRequest.data!.docs.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: ListView.builder(
                  itemCount: streamFriendRequest.data!.docs.length,
                  itemBuilder: (context, index) {
                    return itemFriendRequest(streamFriendRequest, index);
                  },
                ),
              )
            : const Center(
                child: Text(
                  "No friend requests!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
      },
    );
  }

  // Item Friend Request
  Widget itemFriendRequest(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamFriendRequest, int index) {
    return Padding(
      padding: index == 0
          ? const EdgeInsets.only(top: 5.0)
          : index == streamFriendRequest.data!.docs.length - 1
          ? const EdgeInsets.only(bottom: 10.0)
          : const EdgeInsets.only(top: 0.0),
      child: CardItemFriend(
        uidUser: streamFriendRequest.data?.docs[index]['uid'],
        backGroundCard: Colors.grey[200],
        titleWidget: Text(streamFriendRequest.data?.docs[index]['email']),
        onTapAvatar: () {
          // Xem trang cá nhân friend
          Get.to(()=> ShowProfileFriend(userFriend: {
            'email': streamFriendRequest.data?.docs[index]['email'],
            'uid': streamFriendRequest.data?.docs[index]['uid'],
          }));
        },
        trailingIconTop: const Icon(Icons.add_circle_outline),
        onTapTrailingIconTop: () {
          // Chấp nhận kết bạn
          firestoreController.acceptRequestFriend({
            'email': streamFriendRequest.data?.docs[index]['email'],
            'uid': streamFriendRequest.data?.docs[index]['uid'],
          });
        },
        trailingIconBottom: const Icon(Icons.clear),
        onTapTrailingIconBottom: () {
          // Huỷ, từ chối kết bạn
          firestoreController.cancelRequestFriend({
            'email': streamFriendRequest.data?.docs[index]['email'],
            'uid': streamFriendRequest.data?.docs[index]['uid'],
          });
        },
      ),
    );
  }
}
