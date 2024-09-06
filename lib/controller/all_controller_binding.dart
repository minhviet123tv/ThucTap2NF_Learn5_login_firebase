import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:get/get.dart';

class AllControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<FirestoreController>(()=> FirestoreController(), fenix: true); // Get.put(FirestoreController());
  }
}