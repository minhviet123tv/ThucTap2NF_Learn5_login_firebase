import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/chat_friend/show_profile_friend.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../custom_widget/card_item_friend.dart';
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
        DateTime dateTime = streamListChatRoomId.data!.docs[index]['last_time'].toDate(); // Lấy time theo định đạng

        // Widget Item: Tổng hợp các dữ liệu đã lấy được vào widget item
        return CardItemFriend(
          uidUser: streamListChatRoomId.data?.docs[index]['friend_uid'],
          backGroundCard: Colors.grey[200],
          onTapCard: () {
            firestoreController.goToChatRoomWithFriend({
              'email': streamListChatRoomId.data?.docs[index]['friend_email'],
              'uid': streamListChatRoomId.data?.docs[index]['friend_uid'],
            });
          },
          onTapAvatar: () {
            Get.to(()=> ShowProfileFriend(userFriend: {
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
        );

        // Card(
        //   color: Colors.grey[200],
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        //   child: InkWell(
        //     onTap: () {
        //       // Vào chat room khi click
        //       firestoreController.goToChatRoomWithFriend({
        //         'email': streamListChatRoomId.data?.docs[index]['friend_email'],
        //         'uid': streamListChatRoomId.data?.docs[index]['friend_uid'],
        //       });
        //     },
        //     borderRadius: BorderRadius.circular(20),
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
        //       child: Row(
        //         children: [
        //           //1. avatar
        //           InkWell(
        //             onTap: () {
        //               Get.to(() => ShowProfileFriend(userFriend: {
        //                     'email': streamListChatRoomId.data?.docs[index]['friend_email'],
        //                     'uid': streamListChatRoomId.data?.docs[index]['friend_uid'],
        //                   }));
        //             },
        //             borderRadius: BorderRadius.circular(100),
        //             child: Padding(
        //               padding: const EdgeInsets.all(4.0),
        //               child: ClipOval(
        //                 child: SizedBox(
        //                   width: 60,
        //                   height: 60,
        //                   child: GetAvatarFromStorage(uid: streamListChatRoomId.data?.docs[index]['friend_uid']),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           const SizedBox(width: 15),
        //
        //           //2. Email và tin nhắn cuối
        //           Expanded(
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Text(streamListChatRoomId.data?.docs[index]['friend_email'],
        //                     style: const TextStyle(fontWeight: FontWeight.w700)),
        //                 Text(
        //                   streamListChatRoomId.data!.docs[index]['last_content'] ?? "",
        //                   style: streamListChatRoomId.data?.docs[index]['seen']
        //                       ? const TextStyle(fontWeight: FontWeight.w400)
        //                       : const TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
        //                 )
        //               ],
        //             ),
        //           ),
        //
        //           //3. Số lượng tin nhắn mới chưa check và thời gian của tin nhắn cuối
        //           Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               //a. Số lượng tin nhắn mới (Nếu có)
        //               if (streamListChatRoomId.data?.docs[index]['new_message'] > 0)
        //                 Badge(
        //                   label: Padding(
        //                     padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1),
        //                     child: () {
        //                       if (streamListChatRoomId.data?.docs[index]['new_message'] > 99) {
        //                         return const Text(
        //                           '99+',
        //                           style: const TextStyle(fontSize: 12, color: Colors.white),
        //                         );
        //                       } else {
        //                         return Text(
        //                           '${streamListChatRoomId.data?.docs[index]['new_message']}',
        //                           style: const TextStyle(fontSize: 12, color: Colors.white),
        //                         );
        //                       }
        //                     }(),
        //                   ),
        //                   backgroundColor: Colors.green,
        //                 ),
        //               const SizedBox(height: 5),
        //
        //               //b. Thời gian (giờ) của tin nhắn cuối
        //               dateTime.minute >= 10
        //                   ? Text(
        //                       "${dateTime.hour}:${dateTime.minute}",
        //                       style: const TextStyle(fontSize: 12),
        //                     )
        //                   : Text(
        //                       "${dateTime.hour}:0${dateTime.minute}",
        //                       style: const TextStyle(fontSize: 12),
        //                     ),
        //
        //               //c. Thời gian (ngày) của tin nhắn cuối
        //               // Text("${dateTime.day}/${dateTime.month}/${dateTime.year}"),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ),
        //   )

        // ListTile(
        //   leading: ClipOval(
        //     child: SizedBox(
        //       width: 50,
        //       height: 50,
        //       child: GetAvatarFromStorage(uid: streamListChatRoomId.data?.docs[index]['friend_uid']),
        //     ),
        //   ),
        //
        //   //1. email
        //   title: Text(
        //     '${streamListChatRoomId.data?.docs[index]['friend_email'] ?? ""}', // email đã lưu trong thông tin cuộc chat
        //     style: const TextStyle(fontWeight: FontWeight.w700),
        //   ),
        //
        //   //2. Nội dung tin nhắn + Báo đã đọc tin nhắn hay chưa đọc bằng 'seen' của cuộc chat đó
        //   subtitle: Text(
        //     streamListChatRoomId.data!.docs[index]['last_content'] ?? "",
        //     style: streamListChatRoomId.data?.docs[index]['seen']
        //         ? const TextStyle(fontWeight: FontWeight.w400)
        //         : const TextStyle(fontWeight: FontWeight.w700, color: Colors.green),
        //   ),
        //
        //   //3. Thời gian của tin nhắn cuối cùng
        //   trailing: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       //a. Số lượng tin nhắn mới (Nếu có)
        //       if (streamListChatRoomId.data?.docs[index]['new_message'] > 0)
        //         Badge(
        //           label: Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1),
        //             child: () {
        //               if (streamListChatRoomId.data?.docs[index]['new_message'] > 99) {
        //                 return const Text(
        //                   '99+',
        //                   style: const TextStyle(fontSize: 12, color: Colors.white),
        //                 );
        //               } else {
        //                 return Text(
        //                   '${streamListChatRoomId.data?.docs[index]['new_message']}',
        //                   style: const TextStyle(fontSize: 12, color: Colors.white),
        //                 );
        //               }
        //             }(),
        //           ),
        //           backgroundColor: Colors.green,
        //         ),
        //       const SizedBox(height: 5),
        //
        //       //b. Thời gian (giờ) của tin nhắn cuối
        //       dateTime.minute >= 10 ? Text("${dateTime.hour}:${dateTime.minute}") : Text("${dateTime.hour}:0${dateTime.minute}"),
        //       //c. Thời gian (ngày) của tin nhắn cuối
        //       // Text("${dateTime.day}/${dateTime.month}/${dateTime.year}"),
        //     ],
        //   ),
        //
        //   //4. Vào chat room khi click item
        //   onTap: () {
        //     firestoreController.goToChatRoomWithFriend({
        //       'email': streamListChatRoomId.data?.docs[index]['friend_email'],
        //       'uid': streamListChatRoomId.data?.docs[index]['friend_uid'],
        //     });
        //   },
        // )
        // ,
        // );
      },
    );
  }
}
