import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Chat Page
 */

class ChatFriendList extends StatelessWidget {
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();

  // Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: chatList(),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  // Chat List
  Widget chatList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //I. Hiển thị các tin nhắn
        Expanded(
          child: StreamBuilder(
            //1. Truy vấn danh sách id của bảng 'chatroom'
            stream: firestoreController.firestore.collection('chatroom').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              //2. Danh sách cuộc chat với friend đã từng chat (Có uid của user đang login) nếu có
              return snapshot.data!.docs.isNotEmpty ? ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: FutureBuilder(
                      // Lấy user của bạn chat cho mỗi item (Dùng 'chatroom-id' lưu bên trong hoặc docs[index].id)
                      future: firestoreController.getUserFriendFollowTwoUid(
                        snapshot.data!.docs[index]['chatroom-id'], firestoreController.firebaseAuth.currentUser!.uid,
                      ),
                      builder: (context, friendUserSnapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20),));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (friendUserSnapshot.hasData) {
                          return ListTile(
                            title: Text('${friendUserSnapshot.data?['email']}'),
                            subtitle: Text('${friendUserSnapshot.data?['uid']}'),
                            onTap: () {
                              firestoreController.goToChatRoomFromWithFriend({
                                'email': friendUserSnapshot.data?['email'],
                                'uid': friendUserSnapshot.data?['uid']
                              }); // vào ChatRoom
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  );
                },
              ) : const Center(child: Text("No chat with friends.", style: TextStyle(fontSize: 16, color: Colors.black54),),);
            },
          ),
        ),
      ],
    );
  }

}
