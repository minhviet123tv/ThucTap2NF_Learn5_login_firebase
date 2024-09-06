import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Danh sách yêu cầu kết bạn từ người khác
 */

class FriendRequest extends StatelessWidget {
  FriendRequest({super.key});

  FirestoreController firestoreController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: firestoreController.firestore
            .collection('users')
            .doc(firestoreController.firebaseAuth.currentUser?.uid)
            .collection('request_from_friend').orderBy('time', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hiện thị danh sách yêu cầu kết bạn
          return snapshot.data!.docs.isNotEmpty ? ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => Card(
              color: Colors.grey[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(snapshot.data?.docs[index]['email']),
                          Text(snapshot.data?.docs[index]['uid']),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Chấp nhận kết bạn
                            firestoreController.acceptRequestFriend({
                              'email': snapshot.data?.docs[index]['email'],
                              'uid': snapshot.data?.docs[index]['uid'],
                            });
                          },
                          icon: const Icon(Icons.add),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Thu gọn padding
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Huỷ, từ chối kết bạn
                            firestoreController.cancelRequestFriend({
                              'email': snapshot.data?.docs[index]['email'],
                              'uid': snapshot.data?.docs[index]['uid'],
                            });
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ) : const Center(child: Text("No friend requests!", style: TextStyle(fontSize: 16, color: Colors.grey),),);
        },
      ),
    );
  }
}
