import 'package:fire_base_app_chat/home/profile_user.dart';
import 'package:flutter/material.dart';

import 'chat_friend/chat_friend_main.dart';
import 'chat_group/chat_group_list.dart';
import 'search_user_page.dart';

/*
Home page
 */

class HomeMain extends StatefulWidget {
  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  //A. Dữ liệu
  var textStyle1 = const TextStyle(fontSize: 20, color: Colors.black);

  // Thứ tự của item body và menu bottom của main
  int indexSelected = 0;
  Color menuIconColor = Colors.black54;

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
        //I. Widget body
        body: Center(child: listWidgetBody[indexSelected]),

        //II. Bottom Navigation bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: indexSelected, // Thứ tự menu
          // selectedItemColor: Colors.green, // Màu khi được chọn
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          fixedColor: Colors.green,
          onTap: (index) {
            setState(() {
              indexSelected = index; // Cập nhật index menu
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.search, color: menuIconColor,), label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.chat, color: menuIconColor), label: "Friend"),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined, color: menuIconColor), label: "Group"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined, color: menuIconColor), label: "Account"),
          ],
        ),
      ),
    );
  }
}
