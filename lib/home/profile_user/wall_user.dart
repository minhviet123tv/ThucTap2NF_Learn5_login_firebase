import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/fire_storage_controller.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/home/profile_user/view_one_image.dart';
import 'package:fire_base_app_chat/login/confirm_phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'get_avatar_from_storage.dart';

/*
Control profile của user
 */

class WallUser extends StatelessWidget {
  //A. Dữ liệu
  UserController userController = Get.find();
  // static const inAppBillingChannel = MethodChannel("inAppBillingPlatform"); // Billing

  // GetxController
  FirestoreController firestoreController = Get.find();
  FireStorageController fireStorageController = Get.find();

  TextEditingController textWall = TextEditingController(); // TextField cập nhật 'news_content'

  //D. Trang
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // Ẩn bàn phím khi click,
      child: Scaffold(
        body: GetBuilder<UserController>(
          builder: (controller) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //I. Info welcome user
                      welcomeUser(),
                      const SizedBox(height: 20),

                      //II. Thông tin, tin tức đăng cá nhân của currentUser
                      contentNewsFireStorage(),
                      const SizedBox(height: 10),

                      //III. Nút test mua hàng
                      // buttonShop(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //I.1 Info Welcome
  Widget welcomeUser() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //1. avartar
          GetBuilder<FireStorageController>(builder: (GetxController controller) => imageAvatar()),
          const SizedBox(height: 10),

          //2. Email and time
          emailAndTime(),
        ],
      ),
    );
  }

  //I.2 Hiển thị avatar: click ảnh để xem. Chọn icon camera để upload, thay ảnh mới
  Widget imageAvatar() {
    // Dùng ElevatedButton tạo thành nút ảnh (hay ảnh dạng nút)
    return ElevatedButton(
      onPressed: () {
        Get.to(() => ViewAvatar(uid: fireStorageController.firebaseAuth.currentUser!.uid)); // Xem ảnh avatar
      },
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(5)),
      child: SizedBox(
        width: 100, // Tạo kích thước cho khối Stack ảnh
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            //2*. Hiện loading khi upload: CircularProgressIndicator với kích thước của SizedBox (mở rộng bằng kích thước ảnh)
            if (fireStorageController.uploadTask != null)
              StreamBuilder(
                stream: fireStorageController.uploadTask?.snapshotEvents,
                builder: (context, snapshotUploadImage) {
                  if (snapshotUploadImage.hasData) {
                    //I. Chỉ số loading
                    double progressLoading =
                        snapshotUploadImage.data!.bytesTransferred * 100 / snapshotUploadImage.data!.totalBytes;
                    return SizedBox(
                      height: 100, // Bằng đường kính của ảnh
                      width: 100,
                      child: CircularProgressIndicator(
                        value: progressLoading, // Hình ảnh tiến độ % upload theo chỉ số
                        color: Colors.lightGreen[400], // màu khi loading
                        backgroundColor: Colors.grey[300], // Nền, màu khi đợi load
                        strokeWidth:
                            10, // chiều dày vòng loading (mở ra bên ngoài SizedBox, căn bằng 2*padding của ElevatedButton)
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),

            //1*.1 Ảnh avatar khi mới vào trang, khi đã upload ảnh mới xong ( Lưu trên firestore)
            // Phải kiểm tra currentUser.uid vì khi logOut sẽ null nhưng vẫn có hiện trang profile
            if (fireStorageController.imageFile == null && fireStorageController.firebaseAuth.currentUser?.uid != null)
              SizedBox(
                width: 100,
                height: 100,
                child: ClipOval(
                  child: GetAvatarFromStorage(
                    uid: fireStorageController.firebaseAuth.currentUser!.uid,
                  ),
                ),
              ),

            //1*.2 Hiện ảnh file khi chọn ảnh để upload ảnh mới (sau khi upload xong sẽ ẩn)
            if (fireStorageController.imageFile != null)
              ClipOval(
                child: Image.file(
                  File(fireStorageController.imageFile!.path),
                  // Hiện ảnh dạng dùng file do dùng XFile (lưu tạm tại app) khi có ảnh được chọn
                  width: 100, // Kích thước đường kính
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

            //3*. Text hiện chỉ số % đang load: Sẽ hiện chồng lên ảnh khi loading (đặt trên cùng)
            if (fireStorageController.uploadTask != null)
              StreamBuilder(
                stream: fireStorageController.uploadTask?.snapshotEvents,
                builder: (context, snapshotUploadImage) {
                  if (snapshotUploadImage.hasData) {
                    double progressLoading =
                        snapshotUploadImage.data!.bytesTransferred * 100 / snapshotUploadImage.data!.totalBytes;
                    return Text(
                      "${progressLoading.roundToDouble()}%", // Làm tròn
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),

            //4. Icon nút camera
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  fireStorageController.selectImageAndUpload(); // Chọn và upload ảnh avatar
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(5),
                  minimumSize: const Size(20, 20),
                  // backgroundColor: Colors.black54,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.black54, size: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  //II. Email And Time
  emailAndTime() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // text email
          Text(
            userController.firebaseAuth.currentUser?.email ?? "email", // email tài khoản firebase
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  //III. Tạo key 'news_content' nếu chưa có
  contentNewsFireStorage() {
    return FutureBuilder(
      future:
          fireStorageController.firestore.collection('users').doc(fireStorageController.firebaseAuth.currentUser?.uid).get().then(
        (documentSnapshot) async {
          if (documentSnapshot.exists) {
            if (documentSnapshot.data()!.containsKey('news_content') == false) {
              // Phải ghi rõ lại câu lệnh để chắc chắn đúng địa chỉ | set() khi dùng merge -> Thêm nếu chưa có, nếu có thì set lại
              fireStorageController.firestore.collection('users').doc(fireStorageController.firebaseAuth.currentUser?.uid).set(
                {'news_content': ""},
                SetOptions(merge: true),
              );
            }
          }
        },
      ),
      builder: (context, futureContent) {
        if (futureContent.hasError) {
          return const Center(child: Text("Error 1"));
        }
        if (futureContent.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        // Sử dụng hiển thị 'news_content'
        return contentNews();
      },
    );
  }

  //III. Content news
  contentNews() {
    return GetBuilder<FireStorageController>(
      builder: (FireStorageController controller) {
        //1. lấy dữ liệu của currentUser
        return StreamBuilder(
          stream: fireStorageController.firestore
              .collection('users')
              .doc(fireStorageController.firebaseAuth.currentUser?.uid)
              .snapshots(),
          builder: (context, streamNewsContent) {
            if (streamNewsContent.hasError) {
              return const Center(child: Text("Error 2"));
            }
            if (streamNewsContent.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }

            //2. Gán sẵn 'news_content' cho TextField
            textWall.text = streamNewsContent.data!['news_content'];

            //3. Hiển thị 'news_content' tuỳ theo sử dụng
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    //3.1 Text hiển thị nội dung bản tin
                    if (controller.pageStorageState != PageStorageState.selectTextField &&
                        streamNewsContent.data!['news_content'].isNotEmpty)
                      Card(
                        child: InkWell(
                          onTap: () {
                            controller.loadStoragePageState(PageStorageState.selectTextField);
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Text(
                                streamNewsContent.data!['news_content'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),

                    //3.2 Nút thêm nội dung nếu chưa có nội dung
                    if (controller.pageStorageState != PageStorageState.selectTextField &&
                        streamNewsContent.data!['news_content'].isEmpty)
                      IconButton(
                        onPressed: () {
                          controller.loadStoragePageState(PageStorageState.selectTextField);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      )
                  ],
                ),

                //3.3 TextField thay đổi nội dung bản tin
                if (controller.pageStorageState == PageStorageState.selectTextField)
                  Column(
                    children: [
                      // TextField
                      Card(
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: TextField(
                              controller: textWall,
                              maxLines: 10,
                              maxLength: 1000,
                              style: const TextStyle(fontSize: 16),
                              textCapitalization: TextCapitalization.characters,
                              onTap: () {}, // Sự kiện khi click vào TextField
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Hàng nút điều khiển
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Save
                          ElevatedButton(
                              onPressed: () {
                                controller.updateNewsContent(textWall.text); // Cập nhật 'news_content' và trạng thái
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              child: const Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              )),
                          const SizedBox(width: 10),

                          // Clear 'news_content'
                          ElevatedButton(
                            onPressed: () {
                              controller.deleteNewsContent(); // Xoá 'news_content' -> Thành empty
                            },
                            child: const Text("Clear"),
                          ),
                          const SizedBox(width: 10),

                          // Cancel
                          ElevatedButton(
                            onPressed: () {
                              controller.loadStoragePageState(PageStorageState.none);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }

  //IV. Tạo nút test mua hàng
  Widget buttonShop(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Clicked 1!"),
              backgroundColor: Colors.green,
            ));
          },
          child: const Text("Buy 1"),
        ),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Clicked 2!"),
              backgroundColor: Colors.green,
            ));
          },
          child: const Text("Buy 2"),
        ),

        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Clicked 3!"),
              backgroundColor: Colors.green,
            ));
          },
          child: const Text("Buy 3"),
        ),
      ],
    );
  }
}
