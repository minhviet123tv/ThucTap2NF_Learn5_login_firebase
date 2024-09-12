import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Danh sách các cuộc chat của user đang login
 */

class ChatFriendList extends StatelessWidget {
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();

  // Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: chatList(),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  // Chat List
  Widget chatList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //I. Hiển thị các cuộc chat
        Expanded(
          child: StreamBuilder(
            //1. Truy vấn danh sách 'chat_room_id' của user đang login -> sau đó lấy id để truy vấn trong bảng 'chatroom' chung
            stream: firestoreController.firestore
                .collection('users')
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('chat_room_id')
                .orderBy('last_time', descending: true) // Sắp xếp giảm, gần nhất sẽ ở trên
                .snapshots(),
            builder: (context, streamListChatRoomId) {
              if (streamListChatRoomId.hasError) {
                return const Center(child: Text("Somethings went wrong!", style: TextStyle(fontSize: 16)));
              }
              if (streamListChatRoomId.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              //2. Nếu có ít nhất 1 cuộc chat (Có thể có message hoặc không) -> Hiện danh sách item cuộc chat với friend đã từng chat
              if (streamListChatRoomId.hasData && streamListChatRoomId.data!.docs.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: streamListChatRoomId.data?.docs.length,
                  itemBuilder: (context, index) {
                    // a. Item thông tin cuộc chat với friend
                    return Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

                      //b. Dùng Future lấy email của friend
                      child: FutureBuilder(
                        future: firestoreController.firestore
                            .collection('users')
                            .doc(streamListChatRoomId.data?.docs[index]['friend_uid'])
                            .get(),
                        builder: (context, futureFriendEmail) {
                          if (futureFriendEmail.hasError) {
                            return const Center(child: Text("Somethings went wrong!", style: TextStyle(fontSize: 16)));
                          }
                          if (futureFriendEmail.connectionState == ConnectionState.waiting) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            )); // Load item
                          }

                          //c. Lấy thông tin message cuối gần nhất trong danh sách 'message' của cuộc chat với friend
                          if(futureFriendEmail.hasData){
                            return StreamBuilder(
                              stream: firestoreController.firestore
                                  .collection('chatroom')
                                  .doc(streamListChatRoomId.data?.docs[index].id)
                                  .collection('message')
                                  .orderBy('time', descending: true)
                                  .snapshots(),
                              builder: (context, streamMessage) {
                                if (streamMessage.hasError) {
                                  return const Center(child: Text("Somethings went wrong!", style: TextStyle(fontSize: 16)));
                                }
                                if (streamMessage.connectionState == ConnectionState.waiting) {
                                  return const Center(child: SizedBox()); // Để trống khi load mình message
                                }

                                //d. Thông tin tóm tắt cuộc chat, khi có dữ liệu và có danh sách tin nhắn
                                if (streamMessage.hasData && streamMessage.data!.docs.isNotEmpty) {
                                  // Dữ liệu tin nhắn cuối
                                  QueryDocumentSnapshot query = streamMessage.data!.docs[0];
                                  DateTime dateTime = query['time'].toDate(); // Lấy time theo định đạng

                                  return ListTile(
                                    title: Text(
                                      '${futureFriendEmail.data?['email']}',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),

                                    // Báo đã đọc tin nhắn hay chưa đọc bằng 'seen' của cuộc chat này
                                    subtitle: Text(
                                      query['content'],
                                      style: streamListChatRoomId.data?.docs[index]['seen']
                                          ? const TextStyle(fontWeight: FontWeight.w400)
                                          : const TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
                                    ),
                                    trailing: dateTime.minute >= 10
                                        ? Text("${dateTime.hour}:${dateTime.minute}")
                                        : Text("${dateTime.hour}:0${dateTime.minute}"),
                                    onTap: () {
                                      firestoreController.goToChatRoomWithFriend({
                                        'email': futureFriendEmail.data?['email'],
                                        'uid': streamListChatRoomId.data?.docs[index]['friend_uid'],
                                      }); // vào ChatRoom
                                    },
                                  );
                                }

                                // Trả về mặc định là trống
                                return const Center(child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text("No chat with friends.", style: TextStyle(fontSize: 16),),
                                ));
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    );
                  },
                );
              }

              return const Center(
                child: Text("No chat with friends.", style: TextStyle(fontSize: 16, color: Colors.black54)),
              );
            },
          ),
        ),
      ],
    );
  }
}