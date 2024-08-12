import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode()); // Ẩn bàn phím khi click
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
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
                          const Text(
                            "Welcome to Home Page",
                            style: TextStyle(fontSize: 30),
                          ),
                          Text(
                            controller.firebaseAuth.currentUser?.email ?? "email", // email tài khoản firebase
                            style: const TextStyle(fontSize: 25),
                          ),
                          Text(
                            controller.password.value, // Lưu ở địa phương
                            style: const TextStyle(fontSize: 25),
                          ),
                          Text(
                            controller.firebaseAuth.currentUser?.displayName ?? " displayName", // displayName tài khoản firebase
                            style: const TextStyle(fontSize: 25),
                          ),
                          Text(
                            controller.firebaseAuth.currentUser?.photoURL ?? "photo URL", // photoURL tài khoản firebase
                            style: const TextStyle(fontSize: 25),
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
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: const Text("Email"),
                                    subtitle: Text(controller.firebaseAuth.currentUser?.email ?? ""),
                                  ),
                                ),
                                IconButton(onPressed: () {}, icon: const Icon(Icons.change_circle)),
                              ],
                            ),

                            //2. Phone number
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: const Text("Phone Number"),
                                    subtitle: Text(controller.firebaseAuth.currentUser?.phoneNumber ?? ""),
                                  ),
                                ),
                                IconButton(onPressed: () {}, icon: const Icon(Icons.change_circle)),
                              ],
                            ),

                            // password
                            Row(
                              children: [
                                const Expanded(
                                  child: ListTile(
                                    title: Text("Password"),
                                  ),
                                ),
                                IconButton(onPressed: () {}, icon: const Icon(Icons.change_circle)),
                              ],
                            ),

                            //3. Dislay name
                            TextFormField(
                              initialValue: controller.firebaseAuth.currentUser?.displayName ?? "",
                              onChanged: (value) => controller.displayName.value = value, // Cập nhật displayName trong GetxController
                              decoration: const InputDecoration(
                                label: Text(
                                  "Display name",
                                  style: TextStyle(fontSize: 16),
                                ),
                                hintText: "display name",
                              ),
                            ),

                            //4. Photo URL
                            TextFormField(
                              initialValue: controller.firebaseAuth.currentUser?.photoURL ?? "",
                              onChanged: (value) => controller.photoURL.value = value, // Cập nhật photoURL trong GetxController
                              decoration: const InputDecoration(
                                label: Text("Photo URL", style: TextStyle(fontSize: 16)),
                                hintText: "photo url",
                              ),
                            ),
                            const SizedBox(height: 15),

                            //5. Button update
                            controller.loadingPage != LoadingPage.updateProfile
                                ? Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.updateProfile(LoadingPage.updateProfile); // Thực hiện update
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Text(
                                        "Update",
                                        style: TextStyle(fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : const CircularProgressIndicator(),
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
}
