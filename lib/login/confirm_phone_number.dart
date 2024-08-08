import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/custom_widget/text_field_login_register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmPhoneNumber extends StatelessWidget {
  final UserController userController = Get.find();

  ConfirmPhoneNumber({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Phone Number"),
        centerTitle: true,
      ),
      body: GetBuilder<UserController>(
        builder: (controller) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFieldLoginRegister(
                      onChanged: (value) {
                        userController.phoneNumber.value = value; // Cập nhật phone number trong GetxController
                      },
                      maxLength: null,
                      keyboardType: TextInputType.phone,
                      hintText: "+84987654321",
                      prefixIcon: const SizedBox(),
                      obscureText: false,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    userController.loadingPage != LoadingPage.confirmPhone
                        ? ElevatedButton(
                            onPressed: () {
                              userController.phoneAuthentication(LoadingPage.confirmPhone); // Xác thực số điện thoại
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Verify Phone Number',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
