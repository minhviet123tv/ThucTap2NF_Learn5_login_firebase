import 'dart:io';

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

class ProfileUser extends StatefulWidget {
  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  //A. Dữ liệu
  UserController userController = Get.find(); // GetxController
  FirestoreController firestoreController = Get.find();
  FireStorageController fireStorageController = Get.find();

  // TextField controller
  TextEditingController textNewPassword = TextEditingController();
  TextEditingController textNewDisplayName = TextEditingController();
  TextEditingController textNewPhotoURL = TextEditingController();

  //B. init
  @override
  void initState() {
    super.initState();
    // Tạo giá trị ban đầu cho TextField
    textNewDisplayName.text = userController.firebaseAuth.currentUser?.displayName ?? "";
    textNewPhotoURL.text = userController.firebaseAuth.currentUser?.photoURL ?? "";
  }

  //C. Dispose
  @override
  void dispose() {
    super.dispose();
    textNewDisplayName.dispose();
    textNewPhotoURL.dispose();
    textNewPassword.dispose();
  }

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //I. Info welcome user
                    welcomeUser(),
                    const SizedBox(height: 20),

                    //II. Form update profile: Gồm displayName và photoURL
                    formUpdateProfile(),
                    // const SizedBox(height: 10),

                    //III. Button logout
                    buttonLogout(),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
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
                    double progressLoading = snapshotUploadImage.data!.bytesTransferred * 100 / snapshotUploadImage.data!.totalBytes;
                    return SizedBox(
                      height: 100, // Bằng đường kính của ảnh
                      width: 100,
                      child: CircularProgressIndicator(
                        value: progressLoading, // Hình ảnh tiến độ % upload theo chỉ số
                        color: Colors.lightGreen[400], // màu khi loading
                        backgroundColor: Colors.grey[300], // Nền, màu khi đợi load
                        strokeWidth: 10, // chiều dày vòng loading (mở ra bên ngoài SizedBox, căn bằng 2*padding của ElevatedButton)
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
                    double progressLoading = snapshotUploadImage.data!.bytesTransferred * 100 / snapshotUploadImage.data!.totalBytes;
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

          // creationTime tài khoản firebase (Định dạng giờ UTC), có thể lấy milisecond, second, ...
          // Text(
          //   userController.firebaseAuth.currentUser?.metadata.creationTime?.toString() ?? "creationTime",
          //   style: const TextStyle(fontSize: 16),
          // ),

          // lastSignInTime tài khoản firebase
          // Text(
          //   userController.firebaseAuth.currentUser?.metadata.lastSignInTime.toString() ?? "lastSignInTime",
          //   style: const TextStyle(fontSize: 16),
          // ),
        ],
      ),
    );
  }

  //III. Form Update Profile
  Widget formUpdateProfile() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //1. uid
          // itemProfile("UID", userController.firebaseAuth.currentUser?.uid.toString() ?? "uid", null, null),

          //2. Email
          // itemProfile("Email", userController.firebaseAuth.currentUser?.email ?? "", null, null),

          //3. Phone number
          itemProfile("Phone Number", userController.firebaseAuth.currentUser?.phoneNumber ?? "", const Icon(Icons.change_circle), () {
            Get.to(() => const ConfirmPhoneNumber(loadingPage: LoadingPage.changePhoneNumber));
          }),

          //4. Dislay name
          // TextFormField(
          //   controller: textNewDisplayName, // Chỉ dùng controller hoặc initialValue
          //   decoration: InputDecoration(
          //     label: const Text("Name", style: TextStyle(fontSize: 16)),
          //     hintText: "name",
          //     suffixIcon: IconButton(
          //       onPressed: () {
          //         // Thay đổi DisplayName
          //         userController.updateMyUser(context, textNewDisplayName.text, LoadingPage.changeDisplayName);
          //       },
          //       icon: const Icon(Icons.save),
          //     ),
          //   ),
          // ),

          //5. Text password và TextField Change password
          if (userController.loadingPage != LoadingPage.changePassword)
            itemProfile("Password", "", const Icon(Icons.change_circle), () {
              userController.loadingPageState(LoadingPage.changePassword);
            })
          else
            TextFormField(
              controller: textNewPassword,
              autofocus: false,
              decoration: InputDecoration(
                label: const Text("New password", style: TextStyle(fontSize: 16)),
                hintText: "new password",
                suffixIcon: IconButton(
                    onPressed: () {
                      // Thay đổi password
                      userController.updateMyUser(context, textNewPassword.text, LoadingPage.changePassword);
                    },
                    icon: const Icon(Icons.save)),
              ),
            ),

          //6. Photo URL
          // TextFormField(
          //   controller: textNewPhotoURL,
          //   decoration: InputDecoration(
          //     label: const Text("Photo URL", style: TextStyle(fontSize: 16)),
          //     hintText: "photo url",
          //     suffixIcon: IconButton(
          //       onPressed: () {
          //         // Thay đổi photoURL
          //         userController.updateMyUser(context, textNewPhotoURL.text.trim(), LoadingPage.changePhotoURL);
          //       },
          //       icon: const Icon(Icons.save),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  //IV. Widget Item profile của user
  Widget itemProfile(String title, String subTitle, Icon? icon, VoidCallback? function) {
    return icon != null
        ? Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subTitle.isNotEmpty ? Text(subTitle) : const SizedBox(),
                  ],
                ),
              ),
              IconButton(
                onPressed: function,
                icon: icon ?? const Text(""),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subTitle.isNotEmpty ? Text(subTitle) : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  //V. Button Logout
  Widget buttonLogout() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          userController.signOut(); // Sign out
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: const Text(
          "Logout",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
