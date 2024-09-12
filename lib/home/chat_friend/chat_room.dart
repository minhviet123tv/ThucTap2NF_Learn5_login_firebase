import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(userFriend['email'], style: const TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.blue,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //I. Danh sách các tin nhắn
            listMessage(),

            //II. TextField gửi tin nhắn
            textFieldMessage(context),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
    );
  }

  //I. Danh sách các tin nhắn
  Widget listMessage() {
    return Expanded(
      child: StreamBuilder(
        //1. Stream truy vấn danh sách 'message' trong bảng 'chatroom' theo id (hoặc tạo khi gửi 'message' nếu chưa có)
        stream: firestoreController.firestore
            .collection("chatroom")
            .doc(chatRoomId)
            .collection('message')
            .orderBy('time', descending: false) // descending: Sắp xếp giảm
            .snapshots(),
        builder: (context, snapshot) {
          // Để if riêng để xử lý cập nhật stream (có thể là như vậy)
          if (snapshot.hasError) {
            return const Center(child: Text("Somethings went wrong", style: TextStyle(fontSize: 20)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          //2. Đánh dấu cuộc chat đã được đọc cho user đang login | Cuộn, position đến item tin nhắn cuối
          // (vì khi đang mở ChatRoom là đang hoạt động trong stream nên sẽ được xử lý luôn khi có tin nhắn mới lên firestore)
          firestoreController.seenMessage(chatRoomId, userFriend, _scrollController);

          //3. Danh sách tin nhắn
          if (snapshot.hasData) {
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.docs.length, // List bởi docs của bảng 'message' trên Cloud FireStore
              itemBuilder: (context, index) {

                // Dữ liệu của 1 tin nhắn (message)
                QueryDocumentSnapshot query = snapshot.data!.docs[index];
                DateTime dateTime = query['time'].toDate(); // Lấy time theo định đạng

                // Item một tin nhắn
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: firestoreController.firebaseAuth.currentUser?.email == query['sendBy']
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 300,

                        //4. Item mỗi message
                        child: ListTile(
                          title: Text(query['sendBy'] ?? ""), // Người gửi (Nội dung của 'sendBy' trong truy vấn)
                          subtitle: SizedBox(
                            // width: 200,
                            child: Text(
                              "${query['content']}", // Nội dung tin nhắn
                              softWrap: true,
                              textAlign: TextAlign.left,
                            ),
                          ),
                          trailing: dateTime.minute >= 10
                              ? Text("${dateTime.hour}:${dateTime.minute}")
                              : Text("${dateTime.hour}:0${dateTime.minute}"), // Thời gian nhắn tin
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: firestoreController.firebaseAuth.currentUser?.email == query['sendBy']
                                  ? Colors.blue
                                  : Colors.purpleAccent,
                            ),
                            borderRadius: firestoreController.firebaseAuth.currentUser?.email == query['sendBy']
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  )
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                          ),
                        ),

                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
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
                icon: const Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
              ),
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
