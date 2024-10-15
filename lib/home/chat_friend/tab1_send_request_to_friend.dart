import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/chat_friend/show_profile_friend.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../custom_widget/card_item_friend.dart';
import '../profile_user/get_avatar_from_storage.dart';

/*
Danh sách friend đã được gửi yêu cầu kết bạn bởi user đang login
 */

class SendRequestToFriend extends StatelessWidget {
  SendRequestToFriend({super.key});

  FirestoreController firestoreController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: firestoreController.firestore
            .collection('users')
            .doc(firestoreController.firebaseAuth.currentUser?.uid)
            .collection('send_request_to_friend')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamSendRequest) {
          if (streamSendRequest.hasError) {
            return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
          }
          if (streamSendRequest.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Danh sách friend đã được gửi yêu cầu kết bạn bởi user đang login
          return streamSendRequest.data!.docs.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: ListView.builder(
                    itemCount: streamSendRequest.data!.docs.length,
                    itemBuilder: (context, index){
                      return itemSendRequest(streamSendRequest, index);
                    },
                  ),
              )
              : const Center(
                  child: Text(
                    "No requests have been sent yet!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
        },
      ),
    );
  }

  Widget itemSendRequest(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamSendRequest, int index) {
    return Padding(
      padding: index == 0
          ? const EdgeInsets.only(top: 5.0)
          : index == streamSendRequest.data!.docs.length - 1
          ? const EdgeInsets.only(bottom: 10.0)
          : const EdgeInsets.only(top: 0.0),
      child: CardItemFriend(
        uidUser: streamSendRequest.data?.docs[index]['uid'],
        onTapAvatar: (){
          // Xem trang cá nhân friend
          Get.to(()=> ShowProfileFriend(userFriend: {
            'email': streamSendRequest.data?.docs[index]['email'],
            'uid': streamSendRequest.data?.docs[index]['uid'],
          }));
        },
        backGroundCard: Colors.grey[200],
        titleWidget: Text(streamSendRequest.data?.docs[index]['email']),
        trailingIconTop: const Icon(Icons.change_circle_outlined),
        trailingIconBottom: const Icon(Icons.clear),
        onTapTrailingIconTop: (){
        firestoreController.refeshRequestSendToFriend({
            'email': streamSendRequest.data?.docs[index]['email'],
            'uid': streamSendRequest.data?.docs[index]['uid'],
          });
        },
        onTapTrailingIconBottom: (){
        firestoreController.deleteRequestSendToFriend({
            'email': streamSendRequest.data?.docs[index]['email'],
            'uid': streamSendRequest.data?.docs[index]['uid'],
          });
        },

      ),
    );
  }
}
