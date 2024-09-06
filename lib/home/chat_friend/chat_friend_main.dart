import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/chat_friend/chat_friend_list.dart';
import 'package:fire_base_app_chat/home/chat_friend/send_request_to_friend.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'friend_list.dart';
import 'friend_request.dart';

/*
Home page
 */

class ChatFriendMain extends StatefulWidget {
  @override
  State<ChatFriendMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<ChatFriendMain> with TickerProviderStateMixin {
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
    //1. Khai báo list menu của tab trước để lấy length
    listMenuTab = [
      Tab(text: "Tab 1", icon: Icon(Icons.arrow_upward, color: iconTabColor)),
      Tab(text: "Tab 2", icon: Icon(Icons.group_add, color: iconTabColor)),
      Tab(text: "Tab 3", icon: Icon(Icons.group_rounded, color: iconTabColor)),
      Tab(text: "Tab 4", icon: Icon(Icons.chat_bubble_outline, color: iconTabColor)),
    ];
    //2. Dữ liệu controller, index khi mới mở | (with TickerProviderStateMixin cho class)
    tabController = TabController(length: listMenuTab.length, vsync: this, initialIndex: 3);
    index = 3;
    //3. Widget cho TabBarView, tương ứng list menu của tab
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
          leadingWidth: 0,
          backgroundColor: Colors.blue,
          actions: [
            TabBar(
              controller: tabController,
              tabs: listMenuTab,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontSize: 0),
              // labelPadding: EdgeInsets.symmetric(horizontal: 16),
              onTap: (index) {
                setState(() {
                  this.index = index;
                });
              },
            )
          ],
        ),
        //I. Widget body
        body: TabBarView(
          controller: tabController,
          children: listWidgetBody,
        ),
      ),
    );
  }
}
