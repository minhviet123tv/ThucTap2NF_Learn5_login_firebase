import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Danh sách friend đã được gửi yêu cầu kết bạn bởi user đang login
          return snapshot.data!.docs.isNotEmpty
              ? ListView.builder(
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
                                Text(snapshot.data?.docs[index]['email'], style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(snapshot.data?.docs[index]['uid']),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  firestoreController.refeshRequestSendToFriend({
                                    'email': snapshot.data?.docs[index]['email'],
                                    'uid': snapshot.data?.docs[index]['uid'],
                                  });
                                },
                                icon: const Icon(Icons.change_circle_outlined),
                                style: const ButtonStyle(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  firestoreController.deleteRequestSendToFriend({
                                    'email': snapshot.data?.docs[index]['email'],
                                    'uid': snapshot.data?.docs[index]['uid'],
                                  });
                                },
                                icon: const Icon(Icons.clear),
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
}
