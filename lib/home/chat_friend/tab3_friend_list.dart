import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            // Truy vấn tất cả friend trong 'my_friends' của user đang login
            stream: firestoreController.firestore
                .collection("users")
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('my_friends')
                .where('email', isGreaterThanOrEqualTo: textSearch.text)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Danh sách tất cả friend
              return snapshot.data!.docs.isNotEmpty
                  ? ListView.builder(
                      itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                      itemBuilder: (context, index) {
                        return InkWell(
                          // Go to chat room with friend
                          onTap: () => firestoreController.goToChatRoomWithFriend({
                            'email': snapshot.data?.docs[index]['email'],
                            'uid': snapshot.data?.docs[index]['uid'],
                          }),
                          child: Card(
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data?.docs[index]['email'],
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        Text(snapshot.data?.docs[index]['uid']),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.account_circle_outlined),
                                        style: const ButtonStyle(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Go to chat room
                                          firestoreController.goToChatRoomWithFriend({
                                            'email': snapshot.data?.docs[index]['email'],
                                            'uid': snapshot.data?.docs[index]['uid'],
                                          });
                                        },
                                        icon: const Icon(Icons.message_rounded),
                                        style: const ButtonStyle(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No result by \"${textSearch.text}\"",
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
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
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            // Truy vấn tất cả friend trong 'my_friends' của user đang login
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Danh sách tất cả friend
              return snapshot.data!.docs.isNotEmpty
                  ? ListView.builder(
                      itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                      itemBuilder: (context, index) {
                        return InkWell(
                          // Go to chat room with friend
                          onTap: () => firestoreController.goToChatRoomWithFriend({
                            'email': snapshot.data?.docs[index]['email'],
                            'uid': snapshot.data?.docs[index]['uid'],
                          }),
                          child: Card(
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data?.docs[index]['email'],
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        Text(snapshot.data?.docs[index]['uid']),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.account_circle_outlined),
                                        style: const ButtonStyle(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Go to chat room
                                          firestoreController.goToChatRoomWithFriend({
                                            'email': snapshot.data?.docs[index]['email'],
                                            'uid': snapshot.data?.docs[index]['uid'],
                                          });
                                        },
                                        icon: const Icon(Icons.message_rounded),
                                        style: const ButtonStyle(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No friends yet.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
