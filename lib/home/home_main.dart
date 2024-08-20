import 'package:fire_base_app_chat/home/home_page.dart';
import 'package:fire_base_app_chat/home/profile_user.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';
import 'home_page_fire_store.dart';

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

  // Thứ tự của item body và menu bottom
  int indexSelected = 0;

  // Danh sách body tương ứng item menu bottom
  List<Widget> listWidgetBody = [
    HomePageFireStore(),
    ChatPage(),
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
          currentIndex: indexSelected,
          // Thứ tự menu
          selectedItemColor: Colors.green,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: (index) {
            setState(() {
              indexSelected = index; // Cập nhật index menu
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: "Account"),
          ],
        ),
      ),
    );
  }
}
