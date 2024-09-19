import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/chat_friend/tab4_chat_friend_list.dart';
import 'package:fire_base_app_chat/home/chat_friend/tab1_send_request_to_friend.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'tab3_friend_list.dart';
import 'tab2_friend_request.dart';

/*
Trang chứa các tab của phần chat, friend
Chú ý: with TickerProviderStateMixin cho phần State để cài đặt cho TabController
 */

class ChatFriendMain extends StatefulWidget {
  @override
  State<ChatFriendMain> createState() => _ChatFriendMainState();
}

class _ChatFriendMainState extends State<ChatFriendMain> with TickerProviderStateMixin {
  //A. Dữ liệu
  late final TabController tabController; // Tab Controller
  late List<Tab> listMenuTab; // list menu của tab
  late List<Widget> listWidgetBody; // Danh sách body tương ứng
  Color iconTabColor = Colors.white;
  late int index;
  FirestoreController firestoreController = Get.find();

  //B. Khởi tạo
  @override
  void initState() {
    super.initState();

    //I. Khởi tạo list tab trước để lấy số lượng
    listMenuTab = [
      //1. Tab, icon những request đã gửi đi
      Tab(text: "Send request", icon: Icon(Icons.arrow_upward, color: iconTabColor)),
      //2. Tab, icon friend request + số lượng những request gửi đến
      Tab(text: "Receive request", icon: streamIconFriendRequest()), // Dùng stream để lấy số lượng request
      //3. Tab, icon danh sách bạn bè
      Tab(text: "My fiends", icon: Icon(Icons.group_rounded, color: iconTabColor)),
      //4. Tab, icon danh sách các cuộc chat + báo số lượng cuộc chat chưa check (chưa 'seen')
      Tab(text: "Chat friend list", icon: streamIconChatListWithFriend()),
    ];

    //II. Dữ liệu controller, index khi mới mở | (with TickerProviderStateMixin cho class State)
    tabController = TabController(length: listMenuTab.length, vsync: this, initialIndex: listMenuTab.length - 1);
    index = listMenuTab.length - 1; // Đặt sẵn vị trí khi mới mở menu này

    //III. Widget cho TabBarView, tương ứng list menu của tab
    listWidgetBody = [
      SendRequestToFriend(),
      FriendRequest(),
      FriendList(),
      ChatFriendList(),
    ];
  }

  //C. Làm sạch
  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  //D. Trang
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(null),
          title: Text(
              index == 0
                  ? "Sent"
                  : index == 1
                      ? "Request"
                      : index == 2
                          ? "Friends"
                          : "Chats",
              style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
          centerTitle: false,
          leadingWidth: 0, // Khoảng cách so với đầu app bar
          backgroundColor: Colors.blue,
          actions: [
            TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: listMenuTab,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 0),
              onTap: (index) {
                setState(() {
                  this.index = index;
                });
              },
            )
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: listWidgetBody,
        ),
      ),
    );
  }

  //I. Stream lấy Icon Friend Request
  Widget streamIconFriendRequest() {
    return StreamBuilder(
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('request_from_friend')
          .snapshots(),
      builder: (context, snapshot) {
        // Luôn cần xử lý các trường hợp 'hasError' và 'waiting' nếu không có thể hay xảy ra lỗi
        if (snapshot.hasError) {
          return const Center(child: Text("Error", style: TextStyle(fontSize: 20)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Icon(Icons.group_add, color: iconTabColor)); // Vẫn hiện icon khi waiting
        }

        // Icon yêu cầu kết bạn gửi đến và số lượng
        return Badge(
          label: snapshot.data!.docs.isEmpty
              ? const SizedBox()
              : snapshot.data!.docs.length > 99
                  ? const Text('99+')
                  : Text('${snapshot.data!.docs.length}'), // Đặt số lượng phù hợp
          backgroundColor: snapshot.data!.docs.isEmpty ? Colors.transparent : Colors.purpleAccent,
          child: Icon(Icons.group_add, color: iconTabColor),
        );
      },
    );
  }

  //II. Stream Icon Chat List With Friend
  Widget streamIconChatListWithFriend() {
    return StreamBuilder(
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('chat_room_id')
          .where('seen', isEqualTo: false) // Chưa 'seen'
          .snapshots(),
      builder: (context, snapshotSeen) {
        // Luôn cần xử lý các trường hợp 'hasError' và 'waiting' nếu không có thể hay xảy ra lỗi
        if (snapshotSeen.hasError) {
          return const Center(child: Text("Error", style: TextStyle(fontSize: 20)));
        }

        if (snapshotSeen.connectionState == ConnectionState.waiting) {
          return Center(child: Icon(Icons.chat_bubble_outline, color: iconTabColor)); // Vẫn hiện icon đó khi waiting
        }

        // Icon các cuộc chat với bạn bè và số lượng cuộc chat có tin nhắn mới nhưng chưa xem
        return Badge(
          label: snapshotSeen.data!.docs.isEmpty
              ? const SizedBox()
              : snapshotSeen.data!.docs.length > 99
                  ? const Text('99+')
                  : Text('${snapshotSeen.data!.docs.length}'), // Đặt số lượng phù hợp
          backgroundColor: snapshotSeen.data!.docs.isEmpty ? Colors.transparent : Colors.purpleAccent,
          child: Icon(Icons.chat_bubble_outline, color: iconTabColor),
        );
      },
    );
  }
}
