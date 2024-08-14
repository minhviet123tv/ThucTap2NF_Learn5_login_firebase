import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/login/confirm_phone_number.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode()); // Ẩn bàn phím khi click
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(null),
          title: const Text(
            "My Profile",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          backgroundColor: Colors.blue,
        ),
        body: GetBuilder<UserController>(
          builder: (controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //I. Text welcome
                      Column(
                        children: [
                          Text(
                            controller.firebaseAuth.currentUser?.email ?? "email", // email tài khoản firebase
                            style: const TextStyle(fontSize: 25),
                          ),
                          Text(
                            // creationTime tài khoản firebase (Định dạng giờ UTC), có thể lấy milisecond, second, ...
                            controller.firebaseAuth.currentUser?.metadata.creationTime?.toString() ?? "creationTime",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            // lastSignInTime tài khoản firebase
                            controller.firebaseAuth.currentUser?.metadata.lastSignInTime.toString() ?? "lastSignInTime",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.signOut(); // Sign out
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Text(
                                "Logout",
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                      //II. Form update profile: Gồm displayName và photoURL
                      Form(
                        child: Column(
                          children: [
                            //1. Email
                            itemProfile("Email", controller.firebaseAuth.currentUser?.email ?? "", () {}),
                            //2. Phone number
                            // if (controller.loadingPage != LoadingPage.changePhoneNumber)
                            itemProfile("Phone Number", controller.firebaseAuth.currentUser?.phoneNumber ?? "", () {
                              // Mở trang xác thực số điện thoại, trạng thái thay đổi số mới
                              Get.to(() => const ConfirmPhoneNumber(loadingPage: LoadingPage.changePhoneNumber,));
                            }),
                            //3. Text password && Change password
                            if (controller.loadingPage != LoadingPage.changePassword)
                              itemProfile("Password", "", () {
                                controller.loadingPageState(LoadingPage.changePassword);
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
                                        controller.updateMyUser(context, textNewPassword.text, LoadingPage.changePassword);
                                      },
                                      icon: const Icon(Icons.save)),
                                ),
                              ),

                            //3. Dislay name
                            TextFormField(
                              // initialValue: controller.firebaseAuth.currentUser?.displayName ?? "", // Lấy trực tiếp từ firebase
                              controller: textNewDisplayName,
                              decoration: InputDecoration(
                                label: const Text("Display name", style: TextStyle(fontSize: 16)),
                                hintText: "display name",
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    // Thay đổi DisplayName
                                    controller.updateMyUser(context, textNewDisplayName.text, LoadingPage.changeDisplayName);
                                  },
                                  icon: const Icon(Icons.save),
                                ),
                              ),
                            ),

                            //4. Photo URL
                            TextFormField(
                              // initialValue: controller.firebaseAuth.currentUser?.photoURL ?? "", // Lấy trực tiếp từ firebase
                              controller: textNewPhotoURL,
                              decoration: InputDecoration(
                                label: const Text("Photo URL", style: TextStyle(fontSize: 16)),
                                hintText: "photo url",
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    // Thay đổi photoURL
                                    controller.updateMyUser(context, textNewPhotoURL.text.trim(), LoadingPage.changePhotoURL);
                                  },
                                  icon: const Icon(Icons.save),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
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

  //D.1 Widget Item text profile của user
  Widget itemProfile(String title, String subTitle, VoidCallback? function) {
    return Row(
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
          icon: const Icon(Icons.change_circle),
        ),
      ],
    );
  }
}
