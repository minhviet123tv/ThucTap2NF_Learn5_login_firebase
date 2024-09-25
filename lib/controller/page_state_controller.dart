import 'package:get/get.dart';

/*
Tạo thêm quản lý trạng thái để tách cập nhật với GetxController khác
 */

class PageStateController extends GetxController{
  static PageStateController get instance => Get.find(); // Sử dụng trực tiếp

  late PageState pageState = PageState.none;

  // Load page state
  void loadPageState(PageState pageState){
    this.pageState = pageState;
    update();
  }

}

enum PageState {none, search}