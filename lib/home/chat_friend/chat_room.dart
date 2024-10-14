import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/chat_friend/show_profile_friend.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../profile_user/get_avatar_from_storage.dart';

/*
Chat Page
 */

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userFriend;
  final String chatRoomId;

  ChatRoom({super.key, required this.userFriend, required this.chatRoomId});

  // Dữ liệu
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();
  final ScrollController _scrollController = ScrollController();

  // Trang
  @override
  Widget build(BuildContext context) {
    // Luôn cuộn đến điểm cuối của list tin nhắn khi mới mở
    WidgetsBinding.instance.addPostFrameCallback((_) => firestoreController.scrollListView(_scrollController));
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              InkWell(
                onTap: ()=> Get.to(()=> ShowProfileFriend(userFriend:userFriend,)),
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ClipOval(child: SizedBox(width: 40, height: 40, child: GetAvatarFromStorage(uid: userFriend['uid']))),
                )
              ),
              const SizedBox(width: 10),
              Text(
                userFriend['email'].toString().length > 23
                    ? '${userFriend['email'].toString().substring(0, 23)}...'
                    : userFriend['email'],
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //I. Danh sách các tin nhắn
            listMessage(),

            //II. TextField gửi tin nhắn
            textFieldMessage(context),
          ],
        ),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  //I.1 Danh sách các tin nhắn
  Widget listMessage() {
    return Expanded(
      child: StreamBuilder(
        //1.1 Stream QueryDocumentSnapshot danh sách 'message' trong bảng 'chatroom' theo id (hoặc tạo khi gửi 'message' nếu chưa có)
        stream: firestoreController.firestore
            .collection("chatroom")
            .doc(chatRoomId)
            .collection('message')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, streamListMessage) {
          // Để if riêng để xử lý cập nhật stream (có thể là như vậy)
          if (streamListMessage.hasError) {
            return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
          }
          if (streamListMessage.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          //1.2 Nếu có dữ liệu và có tin nhắn -> Hiện thị danh sách tin nhắn
          if (streamListMessage.hasData && streamListMessage.data!.docs.isNotEmpty) {
            //2. Đánh dấu 'seen' cho cuộc chat đang mở trong 'chat_room_id' của user đang login. Cuộn position đến item tin nhắn cuối
            // (Khi đang mở ChatRoom là đang hoạt động trong stream nên sẽ được xử lý luôn khi có tin nhắn mới lên firestore)
            firestoreController.seenChat(chatRoomId, _scrollController);

            //3. Danh sách tin nhắn
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: streamListMessage.data!.docs.length, // List bởi docs của bảng 'message' trên Cloud FireStore
              itemBuilder: (context, index) {
                //4. Item một tin nhắn (dữ liệu tin nhắn là một QueryDocumentSnapshot)
                return itemMessage(streamListMessage.data!.docs[index]);
              },
            );
          }

          // Trả về mặc định trống không, cả khi không có dữ liệu, hoặc có dữ liệu nhưng không có tin nhắn
          return const SizedBox();
        },
      ),
    );
  }

  //I.2 Item Message
  Widget itemMessage(QueryDocumentSnapshot query) {
    DateTime dateTime = query['time'].toDate(); // Lấy time theo định đạng
    return Column(
      crossAxisAlignment:
          firestoreController.firebaseAuth.currentUser?.email == query['sendBy'] ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Card(
          color: firestoreController.firebaseAuth.currentUser?.email == query['sendBy'] ? Colors.grey[200] : Colors.blue[100],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${query['content']}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),

        // SizedBox(
        //   width: 300,
        // Widget của item mỗi message
        // child: ListTile(
        // title: Text(
        //   query['sendBy'] ?? "",
        //   style: TextStyle(fontWeight: FontWeight.w700),
        // ),
        // Người gửi (Nội dung của 'sendBy' trong truy vấn)
        // subtitle: SizedBox(
        //   // width: 200,
        //   child: Text(
        //     "${query['content']}", // Nội dung tin nhắn
        //     softWrap: true,
        //     textAlign: TextAlign.left,
        //     style: TextStyle(color: Colors.black, fontSize: 16),
        //   ),
        // ),
        // trailing:
        //     dateTime.minute >= 10 ? Text("${dateTime.hour}:${dateTime.minute}") : Text("${dateTime.hour}:0${dateTime.minute}"),

        // shape: RoundedRectangleBorder(
        //   side: BorderSide(
        //     color: firestoreController.firebaseAuth.currentUser?.email == query['sendBy'] ? Colors.blue : Colors.purpleAccent,
        //   ),
        //   borderRadius: firestoreController.firebaseAuth.currentUser?.email == query['sendBy']
        //       ? const BorderRadius.only(
        //           topLeft: Radius.circular(20),
        //           topRight: Radius.circular(20),
        //           bottomLeft: Radius.circular(20),
        //         )
        //       : const BorderRadius.only(
        //           topLeft: Radius.circular(20),
        //           topRight: Radius.circular(20),
        //           bottomRight: Radius.circular(20),
        //         ),
        // ),
        // ),
        // ),
      ],
    );
  }

  //II. TextField gửi tin nhắn
  Widget textFieldMessage(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: textMessage,
            decoration: InputDecoration(
              filled: true,
              hintText: "Message",
              enabled: true,
              suffixIcon: IconButton(
                onPressed: () {
                  // Thực hiện chat: Lưu message của email đang login vào firestore
                  firestoreController.sendMessage(context, textMessage, chatRoomId, _scrollController, userFriend);
                },
                icon: const Icon(Icons.send, color: Colors.blue),
              ),
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
