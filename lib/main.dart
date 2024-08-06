import 'package:fire_base_app_chat/controller/all_controller_binding.dart';
import 'package:fire_base_app_chat/service/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'login/login_page.dart';
import 'service/firebase_auth_service.dart';
import 'firebase_options.dart';
import 'login/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo đã khởi tạo (cho firebase va ca Bindings)

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    GetMaterialApp(
      initialBinding: AllControllerBinding(),
      // Mo trang khi moi vao app
      // initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
      ],
      home: SafeArea(
        child: LoginPage(), // Dat HomePage se bi loi Get.argument (Khi co nhieu argument) do Flutter se tai luon phan child
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
