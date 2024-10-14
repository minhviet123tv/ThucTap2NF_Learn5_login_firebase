// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fire_base_app_chat/controller/fire_storage_controller.dart';
// import 'package:fire_base_app_chat/controller/firestore_controller.dart';
// import 'package:fire_base_app_chat/controller/user_controller.dart';
// import 'package:fire_base_app_chat/home/profile_user/view_one_image.dart';
// import 'package:fire_base_app_chat/login/confirm_phone_number.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// import 'get_avatar_from_storage.dart';
//
// /*
// Control profile của user
//  */
//
// class ProfileUser extends StatelessWidget {
//
//   //A. Dữ liệu
//   UserController userController = Get.find();
//   FirestoreController firestoreController = Get.find();
//   FireStorageController fireStorageController = Get.find();
//
//   final String friendUid;
//   final String friendEmail;
//
//   ProfileUser({super.key, required this.friendUid, required this.friendEmail});
//
//   //D. Trang
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // Ẩn bàn phím khi click,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: const Icon(null),
//           title: const Text("Friend Profile", style: TextStyle(color: Colors.white, fontSize: 24)),
//           centerTitle: true,
//           backgroundColor: Colors.blue,
//         ),
//         body: GetBuilder<UserController>(
//           builder: (controller) {
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     //I. Info welcome user
//                     welcomeUser(),
//                     const SizedBox(height: 20),
//
//                     //II. Form update profile: Gồm displayName và photoURL
//                     formUpdateProfile(),
//                     // const SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   //I.1 Info Welcome
//   Widget welcomeUser() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 15.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           //1. avartar
//           GetBuilder<FireStorageController>(builder: (GetxController controller) => imageAvatar()),
//           const SizedBox(height: 10),
//
//           //2. Email and time
//           emailAndTime(),
//         ],
//       ),
//     );
//   }
//
//   //I.2 Hiển thị avatar: click ảnh để xem. Chọn icon camera để upload, thay ảnh mới
//   Widget imageAvatar() {
//     // Dùng ElevatedButton tạo thành nút ảnh (hay ảnh dạng nút)
//     return ElevatedButton(
//       onPressed: () {
//         Get.to(()=> ViewAvatar(uid: fireStorageController.firebaseAuth.currentUser!.uid,)); // Xem ảnh avatar
//       },
//       style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(5)),
//       child: SizedBox(
//         width: 100, // Tạo kích thước cho khối Stack ảnh
//         height: 100,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             //1*.1 Ảnh avatar khi mới vào trang, khi đã upload ảnh mới xong (Trên firestore hoặc ảnh tạm nếu chưa có)
//               SizedBox(
//                 width: 100,
//                 height: 100,
//                 child: ClipOval(
//                   //1. Lấy dữ liệu document của user đang login để lấy 'avatar_url' (ở fire storage) lưu đường dẫn trong firestore
//                   child: GetAvatarFromStorage(uid: friendUid,),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //II. Email And Time
//   emailAndTime() {
//     return Container(
//       padding: const EdgeInsets.only(left: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // text email
//           SizedBox(
//             child: Text(
//               friendEmail, // email friend
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//               textAlign: TextAlign.left,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   //III. Form Update Profile
//   Widget formUpdateProfile() {
//     return Form(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           //1. Phone number
//           itemProfile("Phone Number", userController.firebaseAuth.currentUser?.phoneNumber ?? "", const Icon(Icons.change_circle), () {
//             Get.to(() => const ConfirmPhoneNumber(loadingPage: LoadingPage.changePhoneNumber));
//           }),
//         ],
//       ),
//     );
//   }
//
//   //IV. Widget Item profile của user
//   Widget itemProfile(String title, String subTitle, Icon? icon, VoidCallback? function) {
//     return icon != null
//         ? Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(fontWeight: FontWeight.w700),
//                     ),
//                     subTitle.isNotEmpty ? Text(subTitle) : const SizedBox(),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 onPressed: function,
//                 icon: icon ?? const Text(""),
//               ),
//             ],
//           )
//         : Padding(
//             padding: const EdgeInsets.only(bottom: 10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
//                       subTitle.isNotEmpty ? Text(subTitle) : const SizedBox(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }
// }
