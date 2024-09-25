import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/profile_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_friend/chat_friend_main.dart';
import 'chat_group/chat_group_list.dart';
import 'search_user_page.dart';

/*
Home main: Danh mục các menu ở bottom và các trang body
 */

class HomeMain extends StatefulWidget {
  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  //A. Dữ liệu
  var textStyle1 = const TextStyle(fontSize: 20, color: Colors.black);
  FirestoreController firestoreController = Get.find();

  // Thứ tự của item body và menu bottom của main
  int indexSelected = 0;
  final Color menuIconColor = Colors.black54;

  // Danh sách body tương ứng item menu bottom
  List<Widget> listWidgetBody = [
    SearchPageFireStore(),
    ChatFriendMain(),
    ChatGroup(),
    ProfileUser(),
  ];

  //D. Trang
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //I. Widget body (Không tạo AppBar chung cho tất cả các trang)
        body: Center(child: listWidgetBody[indexSelected]),

        //II. Menu Bottom Navigation bar
        bottomNavigationBar: BottomNavigationBar(
          // Thứ tự menu
          currentIndex: indexSelected,
          // Màu khi được chọn
          selectedItemColor: Colors.green,

          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: (index) {
            setState(() {
              indexSelected = index; // Cập nhật index menu, body
            });
          },

          // Danh sách icon của menu bottomNavigationBar
          items: [
            //1. Menu trang tìm kiếm bạn bè
            BottomNavigationBarItem(icon: Icon(Icons.search, color: menuIconColor), label: "Search"),
            //2. Chat với bạn bè + Thông báo số lượng tin nhắn mới và kết bạn mới
            BottomNavigationBarItem(label: "Friend", icon: streamIconChatWithFriend()),
            //3. Chat group
            BottomNavigationBarItem(icon: streamIconChatGroup(), label: "Group"),
            //4. Profile current user
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined, color: menuIconColor), label: "Account"),
          ],
        ),
      ),
    );
  }

  //I. Stream Icon Chat With Friend: Hiện số lượng kết bạn mới + số lượng tin nhắn mới
  streamIconChatWithFriend() {
    return StreamBuilder(
      //1.1 Lấy số lượng yêu cầu kết bạn hiện có trong 'request_from_friend'
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('request_from_friend')
          .snapshots(),
      builder: (context, streamFriendRequest) {
        // Luôn cần xử lý các trường hợp 'hasError' và 'waiting' nếu không có thể hay xảy ra lỗi
        if (streamFriendRequest.hasError) {
          return Icon(Icons.chat, color: menuIconColor); // Vẫn hiện icon
        }

        if (streamFriendRequest.connectionState == ConnectionState.waiting) {
          return Icon(Icons.chat, color: menuIconColor); // Vẫn hiện icon khi waiting
        }

        //1.2 Nếu có dữ liệu và có số lượng yêu cầu kết bạn gửi đến
        if (streamFriendRequest.hasData && streamFriendRequest.data!.docs.isNotEmpty) {
          //2.1 Tiếp tục lấy số lượng cuộc chat với friend chưa 'seen' trong 'chat_room_id'
          return StreamBuilder(
            stream: firestoreController.firestore
                .collection('users')
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('chat_room_id')
                .where('seen', isEqualTo: false)
                .snapshots(),
            builder: (context, streamChatRoomWithFriend) {
              if (streamChatRoomWithFriend.hasError) {
                return Icon(Icons.chat, color: menuIconColor);
              }

              if (streamChatRoomWithFriend.connectionState == ConnectionState.waiting) {
                return Icon(Icons.chat, color: menuIconColor); // Vẫn hiện icon khi waiting
              }

              //2.2 Nếu có dữ liệu và có số lượng cuộc chat chưa 'seen' -> Cộng vào số lượng với số lượng kết bạn
              if (streamChatRoomWithFriend.hasData && streamChatRoomWithFriend.data!.docs.isNotEmpty) {
                int totalNumberNewNotify = streamFriendRequest.data!.docs.length + streamChatRoomWithFriend.data!.docs.length;
                return Badge(
                  label: totalNumberNewNotify <= 0
                      ? const SizedBox()
                      : totalNumberNewNotify > 99
                          ? const Text('99+')
                          : Text(totalNumberNewNotify.toString()), // Đặt số lượng cho các trường hợp
                  backgroundColor: streamFriendRequest.data!.docs.isEmpty ? Colors.transparent : Colors.green,
                  child: Icon(Icons.chat, color: menuIconColor),
                );
              }

              //3. Trả về mình Icon với số lượng kết bạn nếu không có số lượng cuộc chat mới
              return Badge(
                label: streamFriendRequest.data!.docs.isEmpty
                    ? const SizedBox()
                    : streamFriendRequest.data!.docs.length > 99
                        ? const Text('99+')
                        : Text('${streamFriendRequest.data!.docs.length}'), // Đặt số lượng phù hợp
                backgroundColor: streamFriendRequest.data!.docs.isEmpty ? Colors.transparent : Colors.green,
                child: Icon(Icons.chat, color: menuIconColor),
              );
            },
          );
        } else {
          //4.1 Khi không có số lượng yêu cầu kết bạn -> Chỉ kiểm tra số lượng tin nhắn mới (cuộc chat chưa 'seen')
          return StreamBuilder(
            stream: firestoreController.firestore
                .collection('users')
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('chat_room_id')
                .where('seen', isEqualTo: false)
                .snapshots(),
            builder: (context, streamChatRoomWithFriend) {
              if (streamChatRoomWithFriend.hasError) {
                return Center(child: Icon(Icons.chat, color: menuIconColor));
              }

              if (streamChatRoomWithFriend.connectionState == ConnectionState.waiting) {
                return Center(child: Icon(Icons.chat, color: menuIconColor)); // Vẫn hiện icon khi waiting
              }

              //4.2 Nếu có dữ liệu và có số lượng tin nhắn mới (điều kiện cần và đủ) -> Hiển thị số lượng cuộc chat chưa 'seen'
              if (streamChatRoomWithFriend.hasData && streamChatRoomWithFriend.data!.docs.isNotEmpty) {
                return Badge(
                  label: Text(
                    streamChatRoomWithFriend.data!.docs.length > 99 ? "99+" : streamChatRoomWithFriend.data!.docs.length.toString(),
                  ),
                  // số lượng tin nhắn mới
                  backgroundColor: streamChatRoomWithFriend.data!.docs.isEmpty ? Colors.transparent : Colors.green,
                  child: Icon(Icons.chat, color: menuIconColor),
                );
              }

              //5. Nếu không có cả số lượng kết bạn mới và cả tin nhắn mới -> trả về icon không có notify
              return Icon(Icons.chat, color: menuIconColor);
            },
          );
        }
      },
    );
  }

  // Stream icon chat group
  streamIconChatGroup() {
    return StreamBuilder(
      //1.1 Truy vấn lấy những cuộc chat group có tin nhắn mới (chưa 'seen') trong danh sách 'chat_group_id' của user đang login
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('chat_group_id')
          .where('seen', isEqualTo: false)
          .snapshots(),
      builder: (context, streamListInfoGroup) {
        // Luôn cần xử lý các trường hợp 'hasError' và 'waiting' nếu không có thể hay xảy ra lỗi
        if (streamListInfoGroup.hasError) {
          return Icon(Icons.groups, color: menuIconColor); // Vẫn hiện icon khi error
        }

        if (streamListInfoGroup.connectionState == ConnectionState.waiting) {
          return Icon(Icons.groups, color: menuIconColor); // Vẫn hiện icon khi waiting
        }

        //1.2 Nếu có dữ liệu và có số lượng cuộc chat -> Lấy số lượng cuộc chat có tin mới
        if (streamListInfoGroup.hasData && streamListInfoGroup.data!.docs.isNotEmpty) {
          return Badge(
            label: Text(streamListInfoGroup.data!.docs.length > 99 ? "99+" : streamListInfoGroup.data!.docs.length.toString()),
            backgroundColor: streamListInfoGroup.data!.docs.isEmpty ? Colors.transparent : Colors.green,
            child: Icon(Icons.groups, color: menuIconColor),
          );
        }

        // Mặc định: hiện mình icon
        return Icon(Icons.groups, color: menuIconColor);
      },
    );
  }
}
