import 'package:fire_base_app_chat/controller/all_controller_binding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'service/firebase_auth_service.dart';
import 'firebase_options.dart';
import 'login/home_page.dart';
import 'login/sign_in.dart';
import 'login/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo đã khởi tạo (cho firebase va ca Bindings)

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    GetMaterialApp(
      initialBinding: AllControllerBinding(),
      initialRoute: '/login',
      // Mo trang khi moi vao app
      getPages: [
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/login', page: () => MyLogin()),
        GetPage(name: '/register', page: () => MyRegister())
      ],
      home: SafeArea(
        child: HomePage(),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
