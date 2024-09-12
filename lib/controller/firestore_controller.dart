import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../home/chat_group/chat_group_room.dart';
import '../home/chat_friend/chat_room.dart';

/*
 Class GetxController thực hiện các dữ liệu và logic chung của app
 Dùng 'FirebaseAuth.instance.currentUser' để kết nối trực tiếp tài khoản user trên firebase
 Hoặc dạng 'firebaseAuth.currentUser'
 */

class FirestoreController extends GetxController {
  static FirestoreController get instance => Get.find();

  //I. Dữ liệu chung
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Cloud Firestore database
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Firebase | Không thể tạo sẵn currentUser
  late List<Map<String, dynamic>> listUserCreateGroupChat = [];

  //I. Hàm truy vấn firestore
  //1.1 Clear Search: Xoá kết quả tìm kiếm user và thay đổi trạng thái PageState
  void clearSearchUser(BuildContext context, TextEditingController textSearch) {
    textSearch.clear();
    FocusScope.of(context).requestFocus(FocusNode());
    update();
  }

  //1.2 Cập nhật theo giá trị của textField -> Cập nhật hiển thị theo tình trạng của value
  void updateFollowSearchValue(BuildContext context, String value) {
    if (value.isEmpty) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    update();
  }

  //1.3 Back cho trang Crate chat group: Xoá kết quả tìm kiếm user và thay đổi trạng thái PageState
  void backAndClearForCreateGroupChat() {
    listUserCreateGroupChat.clear();
    Get.back();
  }

  //2.1 Go To Chat Room
  void goToChatRoom(AsyncSnapshot<QuerySnapshot<Object?>> snapshot, int index) {
    // Tạo id chatroom là ghép của 2 user uid (Chữ cái lớn hơn đứng trước)
    String friendUid = snapshot.data?.docs[index]['uid'];
    String roomId = getRoomIdWithFriend(firebaseAuth.currentUser!.uid, friendUid);

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

  //2.3 Go To ChatRoom With Search Friend
  void goToChatRoomWithFriend(Map<String, dynamic> userFriend) {
    // Tạo id chatroom là ghép của 2 uid (Chữ cái lớn hơn đứng trước)
    String roomId = getRoomIdWithFriend(firebaseAuth.currentUser!.uid, userFriend['uid']);

    // Đánh dấu là đã đọc tin nhắn cuối của cuộc chat này cho user đang login

    // Chuyển sang chat room
    Get.to(() {
      return ChatRoom(
        userFriend: userFriend,
        chatRoomId: roomId,
      );
    });
  }

  //2.4 Get RoomId With Friend: Tạo id với cách sắp xếp theo chữ cái đầu
  String getRoomIdWithFriend(String myUid, String friendUid) {
    if (myUid[0].toLowerCase().codeUnits[0] >= friendUid[0].toLowerCase().codeUnits[0]) {
      return "$myUid.$friendUid";
    } else {
      return "$friendUid.$myUid";
    }
  }

  //2.5 Lấy user của bạn chat thông qua 2 uid (là id của chatroom) và my uid
  Future<Map<String, String>> getUserFriendFollowTwoUid(String twoUid, String myUid) async {
    String uid1 = twoUid.split('.')[0];
    String uid2 = twoUid.split('.')[1];
    if (myUid == uid1) {
      return await getUserFromUid(uid2);
    } else {
      return await getUserFromUid(uid1);
    }
  }

  //2.6 Lấy thông tin 1 user theo uid trong bảng 'users'
  Future<Map<String, String>> getUserFromUid(String uid) async {
    Map<String, String> user = {};
    await firestore.collection('users').doc(uid).get().then((value) {
      user = {"email": value['email'], "uid": value['uid']};
      return user;
    });

    return user;
  }

  //3.1 Gửi tin nhắn: Lưu chatRoomId vào 'chat_room_id' của user và friend, sau đó lưu vào bảng 'chatroom'
  void sendMessage(BuildContext context, TextEditingController textMessage, String chatRoomId, ScrollController scrollController,
      Map<String, dynamic> userFriend) async {
    if (textMessage.text.isNotEmpty) {
      try {

        // Tạo cố đinh 1 thời gian chung | Thời gian của máy ảo có thể sai lệch tạo nên thứ tự chưa chuẩn, nếu dùng máy thật thì không bị sai
        DateTime timeNow = DateTime.now();

        //I.1 Thêm thông tin vào bảng 'chat_room_id' của user đang login
        await firestore.collection('users').doc(firebaseAuth.currentUser?.uid).collection('chat_room_id').doc(chatRoomId).set({
          'friend_uid': userFriend['uid'],
          'last_time': timeNow, // Dùng để sắp xếp thứ tự danh sách cuộc chat gần nhất của user đang login
          'seen': true, // Update, báo rằng đã đọc tin nhắn mới nhất của cuộc chat (bên user đang login)
        });

        //I.2 Thêm thông tin vào bảng 'chat_room_id' của friend
        await firestore.collection('users').doc(userFriend['uid']).collection('chat_room_id').doc(chatRoomId).set({
          'friend_uid': firebaseAuth.currentUser?.uid,
          'last_time': timeNow, // Dùng để sắp xếp thứ tự danh sách cuộc chat của friend
          'seen': false, // Update, báo rằng chưa đọc tin nhắn mới nhất của cả cuộc chat (bên friend)
        });

        //II.1 Lưu vào bảng 'chatroom' chung: Thêm vào danh sách 'message' tin mới nhất
        await firestore.collection('chatroom').doc(chatRoomId).collection('message').add({
          "sendBy": firebaseAuth.currentUser?.email, // người gửi tin nhắn, xác định xem ai là người nhắn nội dung này
          'content': textMessage.text, // Nội dung tin nhắn
          'time': timeNow, // Còn FieldValue.serverTimestamp() là giờ theo tổng milisecond
        });

        //II.2 Update bảng 'chatroom' chung: Cập nhật thời gian sử dụng mới nhất của 'chatroom' này (cùng cấp nhưng khác 'message')
        await firestore.collection('chatroom').doc(chatRoomId).set({
          "chatroom_id": chatRoomId,
          'last_time': timeNow, // Còn FieldValue.serverTimestamp() là giờ theo tổng milisecond
        });
      } catch (ex) {
        print(ex);
      }
    }

    scrollListView(scrollController); // Cuộn đến tin mới nhất
    textMessage.clear(); // clear TextField
    FocusScope.of(context).requestFocus(FocusNode()); // Đóng bàn phím
  }

  //3.2 Đánh dấu đã xem cho cuộc chat: Cập nhật thông tin 'last_time', 'seen' cuộc chat đó cho user đang login
  void seenMessage(String chatRoomId, Map<String, dynamic> userFriend, ScrollController scrollController) async {
    try {
      // Cập nhật cho 'chat_room_id' của user đang login (Do khi gửi friend sẽ đánh dấu cho seen là false)
      await firestore.collection('users').doc(firebaseAuth.currentUser?.uid).collection('chat_room_id').doc(chatRoomId).update({
        'friend_uid': userFriend['uid'],
        'last_time': DateTime.now(), // Dùng để sắp xếp thứ tự danh sách cuộc chat gần nhất của user đang login
        'seen': true, // Update, báo rằng đã đọc tin nhắn mới nhất của cuộc chat (bên user đang login)
      });
    } catch (ex) {
      print(ex);
    }

    // Cuộn đến điểm cuối cho list tin nhắn
    scrollListView(scrollController);
  }


  //4. Check user in create list (So sánh bằng mapEquals)
  bool checkUserInCreateGroupList(Map<String, dynamic> user) {
    bool exist = false;
    listUserCreateGroupChat.forEach((element) {
      if (mapEquals(element, user)) {
        exist = true;
      }
    });
    return exist;
  }

  //5.1 add user
  void addUserToListCreateGroupChat(Map<String, dynamic> userMap) {
    listUserCreateGroupChat.add(userMap);
    update();
  }

  //5.2 remove user
  void removeUserFromListCreateGroupChat(Map<String, dynamic> userMap) {
    // Xoá một đối tượng cụ thể, đối tượng map phải dùng mapEquals
    listUserCreateGroupChat.removeWhere((element) => mapEquals(element, userMap));
    update();
  }

  //6. Create group chat: Lưu id user vào 'chatgroup' và lưu id của chatgroup vào cho các user (khi tìm room chỉ việc lấy id)
  Future<void> createGroupChat(String groupName) async {
    // Kiểm tra tên group
    if (groupName.isEmpty) {
      Get.snackbar("Notify", "Please enter Group name!", backgroundColor: Colors.grey[300]);
      return;
    }

    String idChatGroupRoom = '';
    try {
      // Tạo một chatgroup với id tự động (rồi lấy id đó để tạo danh sách bên trong)
      await firestore.collection('chatgroup').add({
        'groupName': groupName,
        'time': DateTime.now(),
      }).then((value) async {
        // Thêm cả user đang login vào trước khi tạo group chính thức
        listUserCreateGroupChat.add({
          'email': firebaseAuth.currentUser?.email,
          'uid': firebaseAuth.currentUser?.uid,
        });

        // Thêm danh sách user đã chọn vào danh sách trên firestore, dùng uid của user đó làm id của danh sách user
        listUserCreateGroupChat.forEach((element) async {
          // value: Là select ngay sau khi vừa add của dữ liệu vừa mới thêm vào bảng 'chatgroup' (có value.id và dữ liệu vừa thêm)
          value.collection('users_group').doc(element['uid']).set({
            'email': element['email'],
            'uid': element['uid'],
          });
        });

        // Lấy về id của ChatGroupRoom vừa tạo
        idChatGroupRoom = value.id;
      });

      // Lưu id của Chat Group vào danh sách 'chat_group_id' của các user trong Group đó (có thể tạo cột request)
      listUserCreateGroupChat.forEach((element) async {
        await firestore.collection('users').doc(element['uid']).collection('chat_group_id').doc(idChatGroupRoom).set({
          'id_group': idChatGroupRoom,
        });
      });

      // Xử lý sau khi tạo xong 1 'chatgroup' mới
      listUserCreateGroupChat.clear(); // Xoá lưu list vừa thêm
      update(); // Cập nhật cho màn hình danh sách chat group
      Get.to(() => ChatGroupRoom(
            idChatGroupRoom: idChatGroupRoom,
            isCreateGroup: true,
          )); // Đến Chat Group Room
    } catch (ex) {
      print(ex.toString());
    }
  }

  //7.1 Gửi tin nhắn: Lưu vào firestore theo bảng 'chatgroup' -> id -> bảng 'message_chatgroup'
  void sendMessageChatGroup(
      BuildContext context, TextEditingController textMessage, String idChatGroup, ScrollController scrollController) async {
    // Nếu text message trống thì không làm gì và tạm dừng
    if (textMessage.text.isEmpty) {
      return;
    }

    // Thêm 1 message vào bên trong danh sách message
    if (textMessage.text.isNotEmpty) {
      await firestore.collection('chatgroup').doc(idChatGroup).collection('message_chatgroup').add({
        "sendBy": firebaseAuth.currentUser?.email, // người gửi tin nhắn
        'content': textMessage.text,
        'time': DateTime.now(), // Còn FieldValue.serverTimestamp() là giờ theo tổng milisecond
      }).then((onValue) {
        scrollListView(scrollController); // Cuộn scroll tin nhắn
      });
    }

    textMessage.clear(); // clear TextField
    FocusScope.of(context).requestFocus(FocusNode()); // Đóng bàn phím
  }

  //7.2 Cuộn scroll đến điểm cuối của ListView danh sách các tin nhắn sau khi gửi xong message
  void scrollListView(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1), curve: Curves.elasticOut); // fastOutSlowIn
    } else {
      // Hẹn giờ thực hiện hàm nếu chưa nhận được danh sách cần scroll
      Timer(const Duration(milliseconds: 400), () => scrollListView(scrollController));
    }
  }

  //8.1 Gửi yêu cầu kết bạn đến friend (theo uid, dùng uid làm id request)
  void sendRequestFriend(Map<String, dynamic> friend) async {
    // Kiểm tra xem đã đang yêu cầu kết bạn chưa (1 điều kiện: Có trong danh sách 'send_request_to_friend' của user đang login)
    try {
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser?.uid)
          .collection('send_request_to_friend')
          .where('uid', isEqualTo: friend['uid'])
          .get()
          .then((querySnapshot) async {
        // Xử lý khi đã tồn tại request tới friend: Thông báo và dừng logic xử lý
        if (querySnapshot.docs.isNotEmpty) {
          Get.snackbar("Notify", "This request has been sent.", backgroundColor: Colors.grey[300]);
        }
        // Xử lý khi chưa tồn tại request này
        else {
          // Thêm uid của friend được yêu cầu vào danh sách 'send_request_to_friend' của user đang login
          await firestore
              .collection('users')
              .doc(firebaseAuth.currentUser?.uid)
              .collection('send_request_to_friend')
              .doc(friend['uid'])
              .set({
            'email': friend['email'],
            'uid': friend['uid'],
            'time': DateTime.now(),
          });

          // Thêm thông tin, uid của user đang login vào danh sách 'request_from_friend' của friend được yêu cầu
          await firestore
              .collection('users')
              .doc(friend['uid'])
              .collection('request_from_friend')
              .doc(firebaseAuth.currentUser?.uid)
              .set({
            'email': firebaseAuth.currentUser?.email,
            'uid': firebaseAuth.currentUser?.uid,
            'time': DateTime.now(),
          });
        }
      });
    } catch (ex) {
      print(ex);
    }
  }

  //8.2 Chấp nhận yêu cầu kết bạn: Thêm vào danh sách bạn bè, xoá trong danh sách yêu cầu của cả 2
  void acceptRequestFriend(Map<String, dynamic> friend) async {
    try {
      //a.1 Thêm cho danh sách 'my_friends' của user đang login, dùng uid để làm id cho 'my_friends'
      await firestore.collection('users').doc(firebaseAuth.currentUser?.uid).collection('my_friends').doc(friend['uid']).set(friend);
      //a.2 Thêm cho danh sách 'my_friends' của friend
      await firestore.collection('users').doc(friend['uid']).collection('my_friends').doc(firebaseAuth.currentUser?.uid).set({
        'email': firebaseAuth.currentUser?.email,
        'uid': firebaseAuth.currentUser?.uid,
      });

      //b.1 Xoá yêu cầu kết bạn trong 'request_from_friend' của user đang login (đã dùng uid của friend để làm uid)
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser?.uid)
          .collection('request_from_friend')
          .doc(friend['uid'])
          .delete();
      //b.2 Xoá yêu cầu kết bạn trong 'send_request_to_friend' của friend đến user đang login (đã dùng uid của user đang login làm uid)
      await firestore
          .collection('users')
          .doc(friend['uid'])
          .collection('send_request_to_friend')
          .doc(firebaseAuth.currentUser?.uid)
          .delete();
    } catch (ex) {
      print(ex);
    }
  }

  //8.3 Từ chối yêu cầu kết bạn của người khác: xoá trong các danh sách yêu cầu của cả 2
  void cancelRequestFriend(Map<String, dynamic> friend) async {
    try {
      //a. Xoá yêu cầu kết bạn trong 'request_from_friend' của user đang login (đã dùng uid của friend để làm uid)
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser?.uid)
          .collection('request_from_friend')
          .doc(friend['uid'])
          .delete();
      //b. Xoá yêu cầu kết bạn trong 'send_request_to_friend' của friend đến user đang login (đã dùng uid của user đang login làm uid)
      await firestore
          .collection('users')
          .doc(friend['uid'])
          .collection('send_request_to_friend')
          .doc(firebaseAuth.currentUser?.uid)
          .delete();
    } catch (ex) {
      print(ex);
    }
  }

  //8.4 Xoá yêu cầu kết bạn đã gửi đi: xoá trong các danh sách yêu cầu của cả 2
  void deleteRequestSendToFriend(Map<String, dynamic> friend) async {
    try {
      //1. Xoá yêu cầu kết bạn trong 'send_request_to_friend' của user đang login đến friend
      // (Đã dùng uid của friend làm id của bảng 'send_request_to_friend' lúc tạo request)
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser?.uid)
          .collection('send_request_to_friend')
          .doc(friend['uid'])
          .delete();

      //2. Xoá yêu cầu kết bạn trong 'request_from_friend' của friend (có id là của user đang login)
      await firestore
          .collection('users')
          .doc(friend['uid'])
          .collection('request_from_friend')
          .doc(firebaseAuth.currentUser?.uid)
          .delete();
    } catch (ex) {
      print(ex);
    }
  }

  //8.5 Cập nhật lại yêu cầu kết bạn đã gửi đi: Làm mới thời gian của yêu cầu của friend để đưa lên trên. Ngoài ra có thể tạo message khi yêu cầu
  void refeshRequestSendToFriend(Map<String, dynamic> friend) async {
    try {
      // Cập nhật lại thời gian cho fiend
      await firestore.collection('users').doc(friend['uid']).collection('request_from_friend').doc(firebaseAuth.currentUser?.uid).set({
        'email': firebaseAuth.currentUser?.email,
        'uid': firebaseAuth.currentUser?.uid,
        'time': DateTime.now(),
      });

      // Cập nhật lại thời gian cho user đang login
      await firestore
          .collection('users')
          .doc(firebaseAuth.currentUser?.uid)
          .collection('send_request_to_friend')
          .doc(friend['uid'])
          .set({
        'email': friend['email'],
        'uid': friend['uid'],
        'time': DateTime.now(),
      });
    } catch (ex) {
      print(ex);
    }
  }
}
