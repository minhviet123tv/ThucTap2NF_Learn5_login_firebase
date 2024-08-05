import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/firebase_auth_service.dart';

class HomePage extends StatelessWidget {

  // Can put 1 lan dau tien
  UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Home Page", style: TextStyle(fontSize: 30),),
            const SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  userController.myFirebaseAuthService.signOut(); // sign out
                  // Navigator.pushNamed(context, 'login');
                  Get.toNamed('/login');
                },
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
