import 'package:fire_base_app_chat/controller/fire_storage_controller.dart';
import 'package:fire_base_app_chat/controller/firestore_controller.dart';
import 'package:fire_base_app_chat/controller/page_state_controller.dart';
import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:get/get.dart';

/*
Class khai báo cho các GetxController
Sẽ đặt ở initialBinding của main, trong GetMaterialApp
 */

class AllControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<FirestoreController>(() => FirestoreController(), fenix: true); // Get.put(FirestoreController());
    Get.lazyPut<PageStateController>(() => PageStateController(), fenix: true);
    Get.lazyPut<FireStorageController>(()=> FireStorageController(), fenix: true);
  }
}
