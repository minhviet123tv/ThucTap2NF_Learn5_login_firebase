import 'package:fire_base_app_chat/controller/all_controller_binding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

import 'login/login_page.dart';
import 'firebase_options.dart';
import 'home/home_main.dart';

Future<void> main() async {

  // Khởi tạo cho Firebase và Bindings
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    GetMaterialApp(
      initialBinding: AllControllerBinding(), // All binding cho GetxController
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomeMain()),
      ],
      home: SafeArea(child: LoginPage()), // (Cần tránh lỗi Get.argument khi chưa có dữ liệu)
      debugShowCheckedModeBanner: false,
    ),
  );
}

