import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/home/chat/chat_room.dart';
import 'package:flutter/cupertino.dart';
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
  late Map<String, dynamic> userSearch = {}; // user tìm kiếm
  final Stream<QuerySnapshot> _users = FirebaseFirestore.instance.collection("users").snapshots();

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
            TextField(
              controller: textSearch,
              decoration: InputDecoration(
                hintText: "Search",
                suffixIcon: IconButton(
                  onPressed: () {
                    onSearch(textSearch.text);
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 10),

            //II. Kết quả tìm kiếm
            userSearch.isNotEmpty
                ? Card(
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ListTile(title: Text(userSearch['email']), trailing: const Icon(Icons.chat)))
                : const SizedBox(),

            //III. Danh sách User
            Expanded(
              child: StreamBuilder(
                stream: _users,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("hasError"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.grey[200],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          title: Text(snapshot.data?.docs[index]['email']),
                          subtitle: Text(snapshot.data?.docs[index]['uid']),
                          trailing: Icon(Icons.chat),
                          onTap: () {
                            String myUid = firestoreController.firebaseAuth.currentUser!.uid;
                            String friendUid = snapshot.data?.docs[index]['uid'];
                            String roomId = createChatRoomId(myUid, friendUid);
                            Map<String, dynamic> myFriend = {
                              'email': snapshot.data?.docs[index]['email'],
                              'uid': snapshot.data?.docs[index]['uid'],
                            };
                            Get.to(() => ChatRoom(userFriend: myFriend, chatRoomId: roomId)); // Chuyển sang chat room
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
      ),
    );
  }

  // Tìm user theo email
  void onSearch(String key) async {
    // Truy cập (get) dữ liệu theo key search và gán vào map (dùng then()) | Tìm trực tiếp nội dung trong các cột (không cần id)
    try {
      await firestoreController.firestore
          .collection('users')
          .where(
            'email',
            isEqualTo: key,
          )
          .get()
          .then((value) {
        // Trả dữ liệu về nếu có | Nếu không có dữ liệu sẽ xử lý ở catch
        if (value.docs[0].data().isNotEmpty) {
          userSearch = value.docs[0].data(); // value.docs: Là danh sách dữ liệu của bảng 'user'
        }
      });
    } catch (ex) {
      print(ex.toString());
      userSearch.clear(); // clear user tìm kiếm
    }

    // print(userMap);
    setState(() {});
  }

  // Tạo chatRoomId: Ghép 2 uid hoặc email lại thành id và để theo thứ tự chữ cái đầu bảng đứng trước
  String createChatRoomId(String email1, String email2) {
    if (email1[0].toLowerCase().codeUnits[0] > email2[0].toLowerCase().codeUnits[0]) {
      return "$email1.$email2";
    } else {
      return "$email2.$email1";
    }
  }
}
