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
          title: const Text("My Profile", style: TextStyle(color: Colors.white, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
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
                    const SizedBox(height: 10),

                    //III. Button logout
                    buttonLogout(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //D.1 Info Welcome
  Widget welcomeUser() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //1. avartar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: Colors.lightGreen, borderRadius: BorderRadius.circular(1000)),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  userController.firebaseAuth.currentUser?.photoURL ??
                      "https://raw.githubusercontent.com/minhviet123tv/file/main/lotus_4.jpg",
                ),
                child: const Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(),
                ),
              ),
            ),
          ),

          //2. Email and time
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // text email
                SizedBox(
                  // width: double.infinity,
                  child: Text(
                    userController.firebaseAuth.currentUser?.email ?? "email", // email tài khoản firebase
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.left,
                  ),
                ),

                // creationTime tài khoản firebase (Định dạng giờ UTC), có thể lấy milisecond, second, ...
                Text(
                  userController.firebaseAuth.currentUser?.metadata.creationTime?.toString() ?? "creationTime",
                  style: const TextStyle(fontSize: 16),
                ),

                // lastSignInTime tài khoản firebase
                Text(
                  userController.firebaseAuth.currentUser?.metadata.lastSignInTime.toString() ?? "lastSignInTime",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//D.2 Form Update Profile
  Widget formUpdateProfile() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //1. uid
          itemProfile("UID", userController.firebaseAuth.currentUser?.uid.toString() ?? "uid", null, () {}),

          //2. Email
          itemProfile("Email", userController.firebaseAuth.currentUser?.email ?? "", null, () {}),

          //3. Phone number
          itemProfile("Phone Number", userController.firebaseAuth.currentUser?.phoneNumber ?? "", const Icon(Icons.change_circle), () {
            // Mở trang xác thực số điện thoại, trạng thái thay đổi số mới
            Get.to(() => const ConfirmPhoneNumber(
                  loadingPage: LoadingPage.changePhoneNumber,
                ));
          }),

          //4. Text password && Change password
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

          //5. Dislay name
          TextFormField(
            controller: textNewDisplayName, // Chỉ dùng controller hoặc initialValue
            decoration: InputDecoration(
              label: const Text("Display name", style: TextStyle(fontSize: 16)),
              hintText: "display name",
              suffixIcon: IconButton(
                onPressed: () {
                  // Thay đổi DisplayName
                  userController.updateMyUser(context, textNewDisplayName.text, LoadingPage.changeDisplayName);
                },
                icon: const Icon(Icons.save),
              ),
            ),
          ),

          //6. Photo URL
          TextFormField(
            controller: textNewPhotoURL,
            decoration: InputDecoration(
              label: const Text("Photo URL", style: TextStyle(fontSize: 16)),
              hintText: "photo url",
              suffixIcon: IconButton(
                onPressed: () {
                  // Thay đổi photoURL
                  userController.updateMyUser(context, textNewPhotoURL.text.trim(), LoadingPage.changePhotoURL);
                },
                icon: const Icon(Icons.save),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

//D.3 Widget Item text profile của user
  Widget itemProfile(String title, String subTitle, Icon? icon, VoidCallback? function) {
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
          icon: icon ?? const Icon(null),
        ),
      ],
    );
  }

//D.4 Button Logout
  Widget buttonLogout() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          userController.signOut(); // Sign out
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        child: const Text(
          "Logout",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
