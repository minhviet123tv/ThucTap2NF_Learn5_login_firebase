import 'package:fire_base_app_chat/controller/page_state_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/firestore_controller.dart';

class CreateChatGroup extends StatefulWidget {
  CreateChatGroup({super.key});

  @override
  State<CreateChatGroup> createState() => _CreateChatGroupState();
}

class _CreateChatGroupState extends State<CreateChatGroup> {
  TextEditingController textGroupName = TextEditingController();

  TextEditingController textSearchFriend = TextEditingController();

  FirestoreController firestoreController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              firestoreController.backAndClearForCreateGroupChat();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text("Create Chat Group"),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //I. Create Group Name
              textFieldGroupName(),

              //II. TextField tìm kiếm user theo email
              GetBuilder<FirestoreController>(builder: (controller) => textFieldFindUserFollowEmail(context)),

              //III. Kết quả tìm kiếm
              findUserResult(),
              //IV. Danh sách User
              listUser(),
              //V. Button Create Group Chat
              const SizedBox(height: 5),
              buttonCreateGroupChat(),
              // const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  //I. TextField Group Name
  Widget textFieldGroupName() {
    return TextField(
      controller: textGroupName,
      decoration: const InputDecoration(
        hintText: "Group name",
        contentPadding: EdgeInsets.only(left: 8),
      ),
    );
  }

  //II. TextField tìm kiếm trong danh sách friend theo email
  Widget textFieldFindUserFollowEmail(BuildContext context) {
    return TextField(
      controller: textSearchFriend,
      onChanged: (value) => firestoreController.updateFollowSearchValueCreateGroup(context, value),
      onSubmitted: (value) => firestoreController.updateFollowSearchValueCreateGroup(
        context,
        value,
      ),
      decoration: InputDecoration(
        hintText: "Search through my friends list",
        contentPadding: const EdgeInsets.only(left: 8, top: 12),
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (textSearchFriend.text.isNotEmpty)
              IconButton(
                onPressed: () => firestoreController.clearSearchUser(context, textSearchFriend),
                icon: const Icon(Icons.clear),
              ),
            IconButton(
              onPressed: () => firestoreController.updateFollowSearchValueCreateGroup(
                context,
                textSearchFriend.text,
              ),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }

  //III. Kết quả tìm kiếm 1 user trong danh sách friend: Hiển thị theo PageStateController
  Widget findUserResult() {
    return GetBuilder<PageStateController>(
      builder: (controller) {
        if (controller.pageState == PageState.search) {
          return Expanded(
            child: StreamBuilder(
              //1. Kết quả tìm trong danh sách friend theo key (dùng where)
              stream: firestoreController.firestore
                  .collection("users")
                  .doc(firestoreController.firebaseAuth.currentUser?.uid)
                  .collection('my_friends')
                  .where('email', isEqualTo: textSearchFriend.text)
                  .orderBy('email', descending: false)
                  .snapshots(),
              builder: (context, streamMyFriend) {
                if (streamMyFriend.hasError) {
                  return const Center(child: Text("hasError: Somethings went wrong"));
                }
                if (streamMyFriend.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                //2. Hiển thị danh sách user nếu có
                return streamMyFriend.data!.docs.isNotEmpty
                    ? ListView.builder(
                        itemCount: streamMyFriend.data?.docs.length, // Danh sách docs truy vấn được
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              title: Text(streamMyFriend.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
                              subtitle: Text(streamMyFriend.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
                              // Check xem đã có trong danh sách tạm tạo group chưa (cho user từ firebase)
                              // hiển thị UI theo FirestoreController (khác so với của cả list là theo PageStateController)
                              trailing: GetBuilder<FirestoreController>(
                                builder: (controller) {
                                  return firestoreController.checkUserInCreateGroupList({
                                    'email': streamMyFriend.data?.docs[index]['email'],
                                    'uid': streamMyFriend.data?.docs[index]['uid'],
                                  })
                                      ? IconButton(
                                          onPressed: () {
                                            firestoreController.removeUserFromListCreateGroupChat({
                                              'email': streamMyFriend.data?.docs[index]['email'],
                                              'uid': streamMyFriend.data?.docs[index]['uid'],
                                            });
                                          },
                                          icon: const Icon(Icons.check),
                                        ) // Nút báo đã có trong list, click sẽ remove khỏi list
                                      : IconButton(
                                          onPressed: () {
                                            firestoreController.addUserToListCreateGroupChat({
                                              'email': streamMyFriend.data?.docs[index]['email'],
                                              'uid': streamMyFriend.data?.docs[index]['uid'],
                                            }); //
                                          },
                                          icon: const Icon(Icons.add),
                                        );
                                },
                              ), // Nút báo chưa có trong list, click sẽ add vào list
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text("No result by \"${textSearchFriend.text}\"",
                            style: const TextStyle(fontSize: 16, color: Colors.grey)));
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  //IV. List Friend, hiển thị theo PageStateController (khi không tìm kiếm, trạng thái none)
  Widget listUser() {
    return GetBuilder<PageStateController>(
      builder: (controller) {
        if (controller.pageState == PageState.none) {
          return Expanded(
            child: StreamBuilder(
              //1. Danh sách tất cả Friend của user đang login
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

                //2. Hiển thị danh sách user nếu có
                return snapshot.data!.docs.isNotEmpty
                    ? ListView.builder(
                        itemCount: snapshot.data?.docs.length, // Danh sách docs truy vấn được
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              title: Text(snapshot.data?.docs[index]['email']), // Truy vấn 'email' của user trên firestore
                              subtitle: Text(snapshot.data?.docs[index]['uid']), // Truy vấn 'uid' của user trên firestore
                              // Check xem đã có trong danh sách tạo group chưa (danh sách tạm thời)
                              trailing: GetBuilder<FirestoreController>(
                                builder: (controller) {
                                  return firestoreController.checkUserInCreateGroupList({
                                    'email': snapshot.data?.docs[index]['email'],
                                    'uid': snapshot.data?.docs[index]['uid'],
                                  })
                                      ? IconButton(
                                          onPressed: () {
                                            firestoreController.removeUserFromListCreateGroupChat({
                                              'email': snapshot.data?.docs[index]['email'],
                                              'uid': snapshot.data?.docs[index]['uid'],
                                            });
                                          },
                                          icon: const Icon(Icons.check),
                                        ) // Nút báo đã có trong list, click sẽ remove khỏi list
                                      : IconButton(
                                          onPressed: () {
                                            firestoreController.addUserToListCreateGroupChat({
                                              'email': snapshot.data?.docs[index]['email'],
                                              'uid': snapshot.data?.docs[index]['uid'],
                                            }); //
                                          },
                                          icon: const Icon(Icons.add),
                                        );
                                },
                              ), // Nút báo chưa có trong list, click sẽ add vào list
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No friends yet",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  //V. Button Create Group Chat
  Widget buttonCreateGroupChat() {
    return ElevatedButton(
      onPressed: () {
        // Tạo chat group, thêm danh sách user đã chọn
        firestoreController.createGroupChat(textGroupName.text.trim());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        minimumSize: const Size.fromHeight(50),
      ),
      child: const Text("Create group", style: TextStyle(color: Colors.white)),
    );
  }
}
