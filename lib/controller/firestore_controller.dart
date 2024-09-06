import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../home/chat/chat_room.dart';

/*
 Class GetxController thực hiện các dữ liệu và logic chung của app
 Dùng 'FirebaseAuth.instance.currentUser' để kết nối trực tiếp tài khoản user trên firebase
 Hoặc dạng 'firebaseAuth.currentUser'
 */

class FirestoreController extends GetxController {
  static FirestoreController get instance => Get.find();

  //I. Dữ liệu chung
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Cloud Firestore database
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Firebase
  final Stream<QuerySnapshot> queryListUser = FirebaseFirestore.instance.collection("users").snapshots(); // list user firestore
  late Map<String, dynamic> userSearch = {}; // user tìm kiếm
  LoadingPage loadingPage = LoadingPage.none;

  //1. Hàm cập nhật trạng thái cho enum LoadingPage
  void loadingPageState(LoadingPage loadingPage) {
    this.loadingPage = loadingPage;
    update();
  }

  //II. Hàm truy vấn firestore
  //1.1 Tìm user theo email
  void searchFriendFollowEmail(BuildContext context, String key) async {
    if (key.isEmpty) {
      update();
      return;
    }

    try {
      // Truy cập (get) dữ liệu theo key search và gán vào map (dùng then()) | Tìm trực tiếp nội dung trong các cột (không cần id)
      await firestore
          .collection('users')
          .where(
            'email',
            whereIn: [key], // Có mặt dữ liệu key
          )
          .get()
          .then((value) {
        if (value.docs[0].data().isNotEmpty) {
          // Trả dữ liệu về nếu có | Nếu không có dữ liệu sẽ xử lý ở catch
          userSearch = value.docs[0].data(); // value.docs: Là danh sách dữ liệu của bảng 'user' (với where condition)
        }
      });
    } catch (ex) {
      print(ex.toString());
      userSearch.clear(); // clear user tìm kiếm
      Get.snackbar("Notify", "\"$key\" not found");
    }

    // Đóng bàn phím và update
    FocusScope.of(context).requestFocus(FocusNode());
    update();
  }

  //1.2 Clear Search
  void clearSearch(BuildContext context, TextEditingController textSearch) {
    userSearch.clear(); // Có thể không xoá để lưu userSearch (hoặc list search nếu tạo) trước đó
    textSearch.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    update();
  }

  //2.1 Go To Chat Room
  void goToChatRoom(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, int index) {
    // Tạo id chatroom là ghép của 2 uid (Chữ cái lớn hơn đứng trước)
    String myUid = firebaseAuth.currentUser!.uid;
    String friendUid = snapshot.data?.docs[index]['uid'];
    String roomId = getRoomIdWithFriend(myUid, friendUid);

    // Tạo dữ liệu friend
    Map<String, dynamic> myFriend = {
      'email': snapshot.data?.docs[index]['email'],
      'uid': snapshot.data?.docs[index]['uid'],
    };

    // Chuyển sang chat room
    Get.to(() {
      return ChatRoom(
        userFriend: myFriend,
        chatRoomId: roomId,
      );
    });
  }

  //2.2 Go To ChatRoom With Search Friend
  void goToChatRoomWithSearchFriend() {
    // Tạo id chatroom là ghép của 2 uid (Chữ cái lớn hơn đứng trước)
    String roomId = getRoomIdWithFriend(firebaseAuth.currentUser!.uid, userSearch['uid']);

    // Chuyển sang chat room
    Get.to(() {
      return ChatRoom(
        userFriend: userSearch,
        chatRoomId: roomId,
      );
    });
  }

  //2.3 Go To ChatRoom With Search Friend
  void goToChatRoomFromListFriendChat(String friendEmail, String friendUid) {
    // Tạo id chatroom là ghép của 2 uid (Chữ cái lớn hơn đứng trước)
    String roomId = getRoomIdWithFriend(firebaseAuth.currentUser!.uid, friendUid);

    Map<String, String> userFriend = {'email': friendEmail, 'uid': friendUid};

    // Chuyển sang chat room
    Get.to(() {
      return ChatRoom(
        userFriend: userFriend,
        chatRoomId: roomId,
      );
    });
  }

  //2.4 Get RoomId With Friend
  String getRoomIdWithFriend(String myUid, String friendUid) {
    if (myUid[0].toLowerCase().codeUnits[0] >= friendUid[0].toLowerCase().codeUnits[0]) {
      return "$myUid.$friendUid";
    } else {
      return "$friendUid.$myUid";
    }
  }

  //3. Gửi tin nhắn: Lưu vào firestore theo bảng 'chatroom' -> id -> bảng 'chats'
  void sendMessage(BuildContext context, TextEditingController textMessage, String chatRoomId) async {
    if (textMessage.text.isNotEmpty) {
      // Lưu id (bên trong) nếu chưa có (mới chat, mới tạo)
      await firestore.collection("chatroom").doc(chatRoomId).get().then(
        (querySnapshot) async {
          if (!querySnapshot.exists) {
            await firestore.collection('chatroom').doc(chatRoomId).set({
              "chatroom-id": chatRoomId, // (ngang hàng, cùng cấp với danh sách 'message')
            });
          }
        },
        onError: (e) => print("Error QuerySnapshot: $e"),
      );

      // Thêm 1 message vào bên trong danh sách message
      await firestore.collection('chatroom').doc(chatRoomId).collection('message').add({
        "sendBy": firebaseAuth.currentUser?.email, // người gửi tin nhắn
        'content': textMessage.text,
        'time': DateTime.now(), // Còn FieldValue.serverTimestamp() là giờ theo tổng milisecond
      });
    }

    textMessage.clear(); // clear TextField
    FocusScope.of(context).requestFocus(FocusNode()); // Đóng bàn phím
  }
}
