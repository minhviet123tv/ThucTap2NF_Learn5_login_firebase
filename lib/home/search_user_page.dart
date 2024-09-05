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
      onChanged: (value) => firestoreController.updateValueSearch(value),
      onSubmitted: (value) => firestoreController.updateValueSearch(value),
      decoration: InputDecoration(
        hintText: "Search",
        contentPadding: const EdgeInsets.only(left: 8, top: 12),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (textSearch.text.isNotEmpty)
              IconButton(
                onPressed: () => firestoreController.clearSearch(context, textSearch, PageState.none),
                icon: const Icon(Icons.clear),
              ),
            IconButton(
              onPressed: () => firestoreController.updateValueSearch(textSearch.text),
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
                  isGreaterThanOrEqualTo: textSearch.text,
                  isNotEqualTo: firestoreController.firebaseAuth.currentUser?.email,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Danh sách tất cả user
              return ListView.builder(
                itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: FutureBuilder(
                      future: firestoreController.checkIsFriend({
                        'email': snapshot.data?.docs[index]['email'],
                        'uid': snapshot.data?.docs[index]['uid'],
                      }),
                      builder: (context, snapshotCheck) {
                        if (snapshotCheck.hasError) {
                          return const Center(child: Text("hasError: Somethings went wrong"));
                        }
                        if (snapshotCheck.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Hiển thị icon tương ứng mối quan hệ
                        return ListTile(
                          onTap: () {
                            if (snapshotCheck.data == true) {
                              firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
                            }
                          },
                          title: Text(snapshot.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
                          subtitle: Text(snapshot.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
                          trailing: snapshotCheck.data == false
                              ? IconButton(
                                  onPressed: () {
                                    firestoreController.sendRequestFriend({
                                      'email': snapshot.data?.docs[index]['email'],
                                      'uid': snapshot.data?.docs[index]['uid'],
                                    });
                                  },
                                  icon: const Icon(Icons.group_add),
                                )
                              : IconButton(
                                  onPressed: () {
                                    firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
                                  },
                                  icon: const Icon(
                                    Icons.group,
                                    color: Colors.green,
                                  )),
                        );
                      },
                    ),
                  );
                },
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
              return ListView.builder(
                itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: FutureBuilder(
                      future: firestoreController.checkIsFriend({
                        'email': snapshot.data?.docs[index]['email'],
                        'uid': snapshot.data?.docs[index]['uid'],
                      }),
                      builder: (context, snapshotCheck) {
                        if (snapshotCheck.hasError) {
                          return const Center(child: Text("hasError: Somethings went wrong"));
                        }
                        if (snapshotCheck.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Hiển thị icon tương ứng mối quan hệ
                        return ListTile(
                          onTap: () {
                            if (snapshotCheck.data == true) {
                              firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
                            }
                          },
                          title: Text(snapshot.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
                          subtitle: Text(snapshot.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
                          trailing: snapshotCheck.data == false
                              ? IconButton(
                                  onPressed: () {
                                    firestoreController.sendRequestFriend({
                                      'email': snapshot.data?.docs[index]['email'],
                                      'uid': snapshot.data?.docs[index]['uid'],
                                    });
                                  },
                                  icon: const Icon(Icons.group_add),
                                )
                              : IconButton(
                                  onPressed: () {
                                    firestoreController.goToChatRoom(snapshot, index); // vào ChatRoom cùng với user được click
                                  },
                                  icon: const Icon(
                                    Icons.group,
                                    color: Colors.green,
                                  )),
                        );
                      },
                    ),
                  );
                },
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
