import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/home/profile_user/profile_user.dart';
import 'package:fire_base_app_chat/home/profile_user/wall_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Trang chứa các tab của phần chat, friend
Chú ý: Cần "with TickerProviderStateMixin" cho phần State của StatefulWidget để cài đặt cho TabController 🌈
 */

class MainProfileCurrentUser extends StatefulWidget {
  @override
  State<MainProfileCurrentUser> createState() => _MainProfileCurrentUserState();
}

class _MainProfileCurrentUserState extends State<MainProfileCurrentUser> with TickerProviderStateMixin {
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
      Tab(text: "Profile", icon: Icon(Icons.settings_suggest_rounded, color: iconTabColor)),
      Tab(text: "Wall", icon: Icon(Icons.newspaper, color: iconTabColor)), // Dùng stream để lấy số lượng request
    ];

    //II. Dữ liệu controller, index khi mới mở | (with TickerProviderStateMixin cho class State)
    tabController = TabController(length: listMenuTab.length, vsync: this, initialIndex: listMenuTab.length - 1);
    index = listMenuTab.length - 1; // Đặt sẵn vị trí khi mới mở menu này

    //III. Widget cho TabBarView, tương ứng list menu của tab
    listWidgetBody = [
      ProfileUser(),
      WallUser(),
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
                  ? "Profile"
                  : "News",
              style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
          centerTitle: false,
          leadingWidth: 0, // Khoảng cách so với đầu app bar
          backgroundColor: Colors.blue,
          actions: [
            TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab, // Độ dài đế chân
              tabs: listMenuTab,
              isScrollable: true, // Xếp tab ngang
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
          physics: const NeverScrollableScrollPhysics(), // Có cuộn được hay không
          children: listWidgetBody, // Bật tắt tính năng swipe
        ),
      ),
    );
  }
}
