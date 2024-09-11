import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
Home page sử dụng FireStore
 */

class SearchPageFireStore extends StatelessWidget {
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
          title: const Text("Search Users", style: TextStyle(color: Colors.white, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            //I. TextField tìm kiếm user theo email
            GetBuilder<FirestoreController>(builder: (controller) => textFieldFindUserFollowEmail(context)),
            const SizedBox(height: 10),

            //II. Kết quả tìm kiếm
            GetBuilder<FirestoreController>(builder: (controller) => findUserResult()),

            //III. Danh sách User
            GetBuilder<FirestoreController>(
              builder: (controller) => listAllUser(),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  //I. TextField tìm kiếm user theo email
  Widget textFieldFindUserFollowEmail(BuildContext context) {
    return TextField(
      controller: textSearch,
      onChanged: (value) => firestoreController.updateFollowSearchValue(context, value),
      onSubmitted: (value) => firestoreController.updateFollowSearchValue(context, value),
      decoration: InputDecoration(
        hintText: "Search",
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
            // Truy vấn tất cả user (trừ user đang login)
            stream: firestoreController.firestore
                .collection("users")
                .where(
                  'email',
                  isNotEqualTo: firestoreController.firebaseAuth.currentUser?.email,
                  isEqualTo: textSearch.text,
                )
                .orderBy('email', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Danh sách tất cả user
              return snapshot.data!.docs.isNotEmpty
                  ? ListView.builder(
                      itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: itemFriend(snapshot, index),
                        );
                      },
                    )
                  : Center(
                      child: Text("No result by \"${textSearch.text}\"", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    );
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //III. List All User, hiển thị nếu không có kết quả tìm kiếm
  Widget listAllUser() {
    if (textSearch.text.isEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            // Truy vấn tất cả user (trừ user đang login)
            stream: firestoreController.firestore
                .collection("users")
                .where('email', isNotEqualTo: firestoreController.firebaseAuth.currentUser?.email)
                .orderBy('email', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Danh sách tất cả user
              return snapshot.data!.docs.isNotEmpty
                  ? ListView.builder(
                      itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: itemFriend(snapshot, index),
                        );
                      },
                    )
                  : const Center(child: Text("No users yet", style: TextStyle(fontSize: 16, color: Colors.grey)));
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //IV. Item friend, thể hiện mối quan hệ bạn bè bằng icon
  Widget itemFriend(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, int index) {
    return StreamBuilder(
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('my_friends')
          .where('uid', isEqualTo: snapshot.data!.docs[index]['uid'])
          .snapshots(),
      builder: (context, snapshotFriend) {
        if (snapshotFriend.hasError) {
          return const Center(child: Text("hasError: Somethings went wrong"));
        }
        if (snapshotFriend.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox());
        }

        //I. Nếu là bạn bè, có dữ liệu trong bảng my_friends
        if (snapshotFriend.data!.docs.isNotEmpty) {
          return ListTile(
            onTap: () {
              firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
            },
            title: Text(snapshot.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
            subtitle: Text(snapshot.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
            trailing: IconButton(
              onPressed: () {
                firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
              },
              icon: const Icon(Icons.group, color: Colors.green),
            ),
          );
        } else {
          //II. Nếu là quan hệ 'đã gửi yêu cầu kết bạn' đến friend này
          return StreamBuilder(
            stream: firestoreController.firestore
                .collection('users')
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('send_request_to_friend')
                .where('uid', isEqualTo: snapshot.data!.docs[index]['uid'])
                .snapshots(),
            builder: (context, snapshotSendRequest) {
              if (snapshotSendRequest.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (snapshotSendRequest.connectionState == ConnectionState.waiting) {
                return const Center(child: SizedBox());
              }

              if (snapshotSendRequest.data!.docs.isNotEmpty) {
                return ListTile(
                  onTap: () {
                    // firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
                  },
                  title: Text(snapshot.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
                  subtitle: Text(snapshot.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
                  trailing: IconButton(
                    onPressed: () {
                      // firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom
                    },
                    icon: const Icon(Icons.arrow_upward, color: Colors.green),
                  ),
                );
              } else {
                //III. Nếu là quan hệ 'được gửi yêu cầu kết bạn' từ người này
                return StreamBuilder(
                  stream: firestoreController.firestore
                      .collection('users')
                      .doc(firestoreController.firebaseAuth.currentUser?.uid)
                      .collection('request_from_friend')
                      .where('uid', isEqualTo: snapshot.data!.docs[index]['uid'])
                      .snapshots(),
                  builder: (context, snapshotReceive) {
                    if (snapshotReceive.hasError) {
                      return const Center(child: Text("hasError: Somethings went wrong"));
                    }
                    if (snapshotReceive.connectionState == ConnectionState.waiting) {
                      return const Center(child: SizedBox());
                    }
                    if (snapshotReceive.data!.docs.isNotEmpty) {
                      return ListTile(
                          onTap: () {
                            // firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom
                          },
                          title: Text(snapshot.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
                          subtitle: Text(snapshot.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
                          trailing: IconButton(
                            onPressed: () {
                              // firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
                            },
                            icon: const Icon(Icons.arrow_downward, color: Colors.green),
                          ));
                    } else {
                      //IV. Nếu không, chưa có quan hệ gì
                      return ListTile(
                          onTap: () {
                            // firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom
                          },
                          title: Text(snapshot.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
                          subtitle: Text(snapshot.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
                          trailing: IconButton(
                            onPressed: () {
                              firestoreController.sendRequestFriend({
                                'email': snapshot.data?.docs[index]['email'],
                                'uid': snapshot.data?.docs[index]['uid'],
                              });
                            },
                            icon: const Icon(Icons.group_add),
                          ));
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}
