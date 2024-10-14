import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_widget/card_item_friend.dart';
import 'chat_friend/show_profile_friend.dart';

/*
Home page sử dụng FireStore
 */

class SearchPageFireStore extends StatelessWidget {
  FirestoreController firestoreController = Get.find();

  TextEditingController textSearch = TextEditingController();
  Color? backgroundCard = Colors.grey[200];

  // Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(null),
          title: const Text("Search Users", style: TextStyle(color: Colors.white, fontSize: 22)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            //I. TextField tìm kiếm user theo email
            GetBuilder<FirestoreController>(builder: (controller) => textFieldFindUserFollowEmail(context)),

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
        hintText: "Search email",
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
        child: StreamBuilder(
          //1. Truy vấn tìm kiếm danh sách user (trừ user đang login)
          stream: firestoreController.firestore
              .collection("users")
              .where('email', isNotEqualTo: firestoreController.firebaseAuth.currentUser?.email, isEqualTo: textSearch.text)
              .orderBy('email', descending: false)
              .snapshots(),
          builder: (context, streamSearchListUser) {
            if (streamSearchListUser.hasError) {
              return const Center(child: Text("hasError: Somethings went wrong"));
            }
            if (streamSearchListUser.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            //2. Danh sách tất cả user
            return streamSearchListUser.data!.docs.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: streamSearchListUser.data?.docs.length, // Danh sách docs truy vấn được
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: itemFriend(streamSearchListUser, index),
                      );
                    },
                  )
                : Center(
                    child: Text("No result by \"${textSearch.text}\"", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  );
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //III. List All User, hiển thị khi không tìm kiếm -> Chú ý tách trường hợp, không nên lồng vào nhau sẽ phức tạp
  Widget listAllUser() {
    if (textSearch.text.isEmpty) {
      return Expanded(
        child: StreamBuilder(
          //1. Truy vấn tất cả user (trừ user đang login) - Chưa paging
          stream: firestoreController.firestore
              .collection("users")
              .where('email', isNotEqualTo: firestoreController.firebaseAuth.currentUser?.email)
              .orderBy('email', descending: false)
              // .limit(5) // Xếp sẵn hiện số lượng nhất định
              .snapshots(),
          builder: (context, streamListAllUser) {
            if (streamListAllUser.hasError) {
              return const Center(child: Text("hasError: Somethings went wrong"));
            }
            if (streamListAllUser.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            //2. Danh sách tất cả user (Có data trả về và danh sách không trống, đề phòng có data nhưng không có danh sách)
            if (streamListAllUser.hasData && streamListAllUser.data!.docs.isNotEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: streamListAllUser.data?.docs.length, // Danh sách docs truy vấn được
                itemBuilder: (context, index) {
                  return itemFriend(streamListAllUser, index);
                },
              );
            }

            //3. Trả về mặc định là thông báo nếu không nằm trong các trường hợp trên
            return const Center(child: Text("No users yet", style: TextStyle(fontSize: 16, color: Colors.grey)));
          },
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  //IV. Item friend, thể hiện mối quan hệ bạn bè bằng icon
  Widget itemFriend(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamListUser, int index) {
    //1.1 Tìm user trong stream list truyền vào xem có trong danh sách bạn bè 'my_friends' chưa (của user đang login)
    return StreamBuilder(
      stream: firestoreController.firestore
          .collection('users')
          .doc(firestoreController.firebaseAuth.currentUser?.uid)
          .collection('my_friends')
          .where('uid', isEqualTo: streamListUser.data!.docs[index]['uid'])
          .snapshots(),
      builder: (context, streamCheckFriend) {
        if (streamCheckFriend.hasError) {
          return const Center(child: Text("hasError: Somethings went wrong"));
        }
        if (streamCheckFriend.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox());
        }

        //1.2 Nếu có trong danh sách bạn bè (có trong bảng 'my_friends') -> Hiện item có icon bạn bè
        if (streamCheckFriend.hasData && streamCheckFriend.data!.docs.isNotEmpty) {
          return CardItemFriend(
            uidUser: streamListUser.data?.docs[index]['uid'],
            backGroundCard: backgroundCard,
            onTapCard: () {
              firestoreController.goToChatRoom(streamListUser, index); // vào ChatRoom cùng với user được click
            },
            onTapAvatar: () {
              Get.to(() => ShowProfileFriend(userFriend: {
                    'email': streamListUser.data?.docs[index]['email'],
                    'uid': streamListUser.data?.docs[index]['uid'],
                  }));
            },
            titleWidget: Text(streamListUser.data?.docs[index]['email']),
            trailingIconTop: const Icon(Icons.group, color: Colors.green),
          );
        } else {
          //2.1 Nếu chưa phải là bạn bè -> tìm quan hệ 'đã gửi yêu cầu kết bạn' đến friend này
          return StreamBuilder(
            stream: firestoreController.firestore
                .collection('users')
                .doc(firestoreController.firebaseAuth.currentUser?.uid)
                .collection('send_request_to_friend')
                .where('uid', isEqualTo: streamListUser.data!.docs[index]['uid'])
                .snapshots(),
            builder: (context, streamSendRequest) {
              if (streamSendRequest.hasError) {
                return const Center(child: Text("hasError: Somethings went wrong"));
              }
              if (streamSendRequest.connectionState == ConnectionState.waiting) {
                return const Center(child: SizedBox());
              }

              //2.2 Nếu đúng là có quan hệ 'send_request_to_friend' -> Hiện item và icon
              if (streamSendRequest.data!.docs.isNotEmpty) {
                return CardItemFriend(
                  uidUser: streamListUser.data?.docs[index]['uid'],
                  backGroundCard: backgroundCard,
                  onTapAvatar: () {
                    Get.to(() => ShowProfileFriend(userFriend: {
                          'email': streamListUser.data?.docs[index]['email'],
                          'uid': streamListUser.data?.docs[index]['uid'],
                        }));
                  },
                  titleWidget: Text(streamListUser.data?.docs[index]['email']),
                  trailingIconTop: const Icon(Icons.arrow_upward, color: Colors.green),
                );
              } else {
                //3.1 Tìm trong mối quan hệ 'được gửi yêu cầu kết bạn' từ người này
                return StreamBuilder(
                  stream: firestoreController.firestore
                      .collection('users')
                      .doc(firestoreController.firebaseAuth.currentUser?.uid)
                      .collection('request_from_friend')
                      .where('uid', isEqualTo: streamListUser.data!.docs[index]['uid'])
                      .snapshots(),
                  builder: (context, streamReceiveRequest) {
                    if (streamReceiveRequest.hasError) {
                      return const Center(child: Text("hasError: Somethings went wrong"));
                    }
                    if (streamReceiveRequest.connectionState == ConnectionState.waiting) {
                      return const Center(child: SizedBox());
                    }

                    //3.2 Nếu đúng là 'được gửi yêu cầu kết bạn' từ người này -> Hiện item, icon
                    if (streamReceiveRequest.data!.docs.isNotEmpty) {
                      return CardItemFriend(
                        uidUser: streamListUser.data?.docs[index]['uid'],
                        backGroundCard: backgroundCard,
                        onTapAvatar: () {
                          Get.to(() => ShowProfileFriend(userFriend: {
                                'email': streamListUser.data?.docs[index]['email'],
                                'uid': streamListUser.data?.docs[index]['uid'],
                              }));
                        },
                        titleWidget: Text(streamListUser.data?.docs[index]['email']),
                        trailingIconTop: const Icon(Icons.arrow_downward, color: Colors.green),
                      );
                    } else {
                      //4. Nếu không phải các trường hợp trên thì chưa có quan hệ gì -> Hiện thông tin, icon yêu cầu kết bạn
                      return CardItemFriend(
                        uidUser: streamListUser.data?.docs[index]['uid'],
                        backGroundCard: backgroundCard,
                        onTapAvatar: () {
                          Get.to(() => ShowProfileFriend(userFriend: {
                                'email': streamListUser.data?.docs[index]['email'],
                                'uid': streamListUser.data?.docs[index]['uid'],
                              }));
                        },
                        titleWidget: Text(streamListUser.data?.docs[index]['email']),
                        trailingIconTop: const Icon(Icons.group_add),
                        onTapTrailingIconTop: () {
                          firestoreController.sendRequestFriend({
                            'email': streamListUser.data?.docs[index]['email'],
                            'uid': streamListUser.data?.docs[index]['uid'],
                          });
                        },
                      );
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
