import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/user_model.dart';

/*
Home page sử dụng FireStore
 */

class HomePageFireStore extends StatefulWidget {
  @override
  State<HomePageFireStore> createState() => _HomePageFireStoreState();
}

class _HomePageFireStoreState extends State<HomePageFireStore> {
  FirestoreController firestoreController = Get.find();
  TextEditingController textSearch = TextEditingController();

  // Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(null),
          title: const Text("Home page FireStore", style: TextStyle(color: Colors.white, fontSize: 24)),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            //I. TextField tìm kiếm user theo email
            GetBuilder<FirestoreController>(builder: (controller) => findUserFollowEmail()),
            const SizedBox(height: 10),

            //II. Kết quả tìm kiếm
            GetBuilder<FirestoreController>(builder: (controller) => findUserResult()),

            //III. Danh sách User
            GetBuilder<FirestoreController>(builder: (controller) => listAllUser()),
          ],
        ),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  //I. TextField tìm kiếm user theo email
  Widget findUserFollowEmail() {
    return TextField(
      controller: textSearch,
      onChanged: (value) {
        firestoreController.update(); // update cho nút clear
      },
      decoration: InputDecoration(
        hintText: "Search",
        contentPadding: const EdgeInsets.only(left: 8, top: 12),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (textSearch.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  firestoreController.clearSearch(context, textSearch); // clear cả TextField và userSearch
                },
                icon: const Icon(Icons.clear),
              ),
            IconButton(
              onPressed: () {
                firestoreController.searchFriendFollowEmail(context, textSearch.text); // Tìm userSearch theo key
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
      ),
    );
  }

  //II. Kết quả tìm kiếm 1 user, hiển thị nếu có kết quả tìm kiếm và có textSearch
  Widget findUserResult() {
    if (firestoreController.userSearch.isNotEmpty && textSearch.text.isNotEmpty) {
      return Card(
        color: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          title: Text(firestoreController.userSearch['email']),
          trailing: const Icon(Icons.chat),
          onTap: () => firestoreController.goToChatRoomWithSearchFriend(), // Vào chatroom
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //III. List All User, hiển thị nếu không có kết quả tìm kiếm
  Widget listAllUser() {
    if (firestoreController.userSearch.isEmpty || textSearch.text.isEmpty) {
      return Expanded(
        child: StreamBuilder(
          stream: firestoreController.queryListUser,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("hasError"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Danh sách tất cả user
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    title: Text(snapshot.data?.docs[index]['email']),
                    subtitle: Text(snapshot.data?.docs[index]['uid']),
                    onTap: () {
                      firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom
                    },
                  ),
                );
              },
            );
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
