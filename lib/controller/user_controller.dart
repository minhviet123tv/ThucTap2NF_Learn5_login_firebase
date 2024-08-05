import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../service/firebase_auth_service.dart';

class UserController extends GetxController {
  late User user;
  late MyFirebaseAuthService myFirebaseAuthService;

  @override
  void onInit() {
    super.onInit();
    myFirebaseAuthService = MyFirebaseAuthService();
  }
}