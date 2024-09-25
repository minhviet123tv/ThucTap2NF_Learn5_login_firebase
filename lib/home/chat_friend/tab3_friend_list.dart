import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../custom_widget/listtile_custom.dart';

/*
Home page sử dụng FireStore
 */

class FriendList extends StatelessWidget {
  FirestoreController firestoreController = Get.find();

  TextEditingController textSearch = TextEditingController();

  // Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: Column(
          children: [
            //I. TextField tìm kiếm user theo email
            GetBuilder<FirestoreController>(builder: (controller) => findUserFollowEmail(context)),

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
  Widget findUserFollowEmail(BuildContext context) {
    return TextField(
      controller: textSearch,
      onChanged: (value) => firestoreController.updateFollowSearchValue(context, value),
      onSubmitted: (value) => firestoreController.updateFollowSearchValue(context, value),
      decoration: InputDecoration(
        hintText: "Search from your friends list",
        contentPadding: const EdgeInsets.only(left: 8, top: 12),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (textSearch.text.isNotEmpty)
              IconButton(
                onPressed: () => firestoreController.clearSearchUser(context, textSearch),
                icon: const Icon(Icons.clear),
              ),
            IconButton(
              onPressed: () => firestoreController.updateFollowSearchValue(context, textSearch.text),
              icon: const Icon(Icons.search),
            )
          ],
        ),
      ),
    );
  }

  //II. Kết quả tìm kiếm 1 user, hiển thị nếu có kết quả tìm kiếm và có textSearch
  Widget findUserResult() {
    if (textSearch.text.isNotEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            //1. Truy vấn tất cả friend trong 'my_friends' của user đang login
            stream: firestoreController.firestore
                .collection("users")
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('my_friends')
                .where('email', isEqualTo: textSearch.text)
                .snapshots(),
            builder: (context, streamMyFriendList) {
              if (streamMyFriendList.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (streamMyFriendList.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //2. Danh sách tất cả friend (Nếu có ít nhất 1 friend)
              if (streamMyFriendList.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: streamMyFriendList.data?.docs.length, // Danh sách docs truy vấn được
                  itemBuilder: (context, index) {
                    return itemFriend(streamMyFriendList, index);
                  },
                );
              }

              //3. Trả về khi mặc định
              return Center(
                child: Text("No result by \"${textSearch.text}\"", style: const TextStyle(fontSize: 16, color: Colors.black54)),
              );
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //III. List All User Friend, hiển thị nếu không có kết quả tìm kiếm
  Widget listAllUser() {
    if (textSearch.text.isEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: StreamBuilder(
            //1. Truy vấn tất cả friend trong 'my_friends' của user đang login
            stream: firestoreController.firestore
                .collection("users")
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('my_friends')
                .orderBy('email', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              //2. Danh sách tất cả friend (Nếu có ít nhất 1 friend)
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                  itemBuilder: (context, index) {
                    return itemFriend(snapshot, index); // item
                  },
                );
              }

              //3. Thông báo mặc định các trường hợp khác
              return const Center(child: Text("No friends yet.", style: TextStyle(fontSize: 16, color: Colors.black54)));
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //IV. Item Friend
  itemFriend(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index) {
    return Padding(
      padding: index == 0
          ? const EdgeInsets.only(top: 8.0)
          : index == snapshot.data!.docs.length - 1
              ? const EdgeInsets.only(bottom: 12.0)
              : const EdgeInsets.only(top: 0.0),
      child: ListTileCustom(
        textTitle: snapshot.data?.docs[index]['email'],
        textSubTitle: snapshot.data?.docs[index]['uid'],
        iconTopTrailing: const Icon(Icons.account_circle_outlined),
        functionTopTrailingIcon: () {
          null;
        },
        iconBottomTrailing: const Icon(Icons.message_rounded),
        functionBottomTrailingIcon: () {
          firestoreController.goToChatRoomWithFriend({
            'email': snapshot.data?.docs[index]['email'],
            'uid': snapshot.data?.docs[index]['uid'],
          });
        },
        onTap: () {
          firestoreController.goToChatRoomWithFriend({
            'email': snapshot.data?.docs[index]['email'],
            'uid': snapshot.data?.docs[index]['uid'],
          });
        },
      ),
    );
  }
}
