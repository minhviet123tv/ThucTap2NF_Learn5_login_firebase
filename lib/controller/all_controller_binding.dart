import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:get/get.dart';

class AllControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
  }
}