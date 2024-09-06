import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Chat Page
 */

class ChatPage extends StatelessWidget {
  TextEditingController textMessage = TextEditingController();
  FirestoreController firestoreController = Get.find();
  UserController userController = Get.find();

  // Trang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(null),
        title: const Text("Chat List", style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
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

                  //2. Danh sách friend đã từng chat (Những cuộc chat có uid của user đang login)
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Card(
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: FutureBuilder(
                            future: getUserFriend(
                              // Lấy user của bạn chat cho mỗi item (Dùng 'chatroom-id' lưu bên trong hoặc docs[index].id)
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
                                    firestoreController.goToChatRoomFromListFriendChat(
                                      friendUserSnapshot.data!['email']!,
                                      friendUserSnapshot.data!['uid']!,
                                    ); // vào ChatRoom
                                  },
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
    );
  }

  // Lấy user của bạn chat thông qua 2 uid và my uid
  Future<Map<String, String>> getUserFriend(String twoUid, String myUid) async {
    String uid1 = twoUid.split('.')[0];
    String uid2 = twoUid.split('.')[1];
    if (myUid == uid1) {
      return await getUserFromUid(uid2);
    } else {
      return await getUserFromUid(uid1);
    }
  }

  // Lấy thông tin 1 user theo uid trong bảng 'users'
  Future<Map<String, String>> getUserFromUid(String uid) async {
    Map<String, String> user = {};
    await firestoreController.firestore.collection('users').doc(uid).get().then((value) {
      // print( "uid:" + value['uid'] + "\nemail:" + value['email']);
      user = {"email": value['email'], "uid": value['uid']};
      return user;
    });

    return user;
  }
}
