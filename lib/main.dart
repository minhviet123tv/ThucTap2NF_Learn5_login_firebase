import 'package:fire_base_app_chat/controller/all_controller_binding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'login/login_page.dart';
import 'firebase_options.dart';
import 'home/home_main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo đã khởi tạo (cho firebase va ca Bindings)

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    GetMaterialApp(
      initialBinding: AllControllerBinding(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomeMain()),
      ],
      home: SafeArea(
        // Đặt HomePage sẽ bị lỗi Get.argument (Khi gửi nhiều argument) do Flutter sẽ tải luôn phần child
        child: LoginPage(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
