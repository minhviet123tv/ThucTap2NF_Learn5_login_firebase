import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../service/firebase_auth_service.dart';

class UserController extends GetxController {
  late AccountLogin accountLogin;
  late MyFirebaseAuthService myFirebaseAuthService; // Cac phuong thuc login firebase, de trong class khac cho gon

  @override
  void onInit() {
    super.onInit();
    myFirebaseAuthService = MyFirebaseAuthService();
  }
}

class AccountLogin {
  String email;
  String password;

  AccountLogin(this.email, this.password);
}