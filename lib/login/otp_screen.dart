import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/custom_widget/text_field_login_register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpScreen extends StatefulWidget {
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  TextEditingController textConfirmOtp = TextEditingController(); // TextField control

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Screen"),
        centerTitle: true,
      ),
      body: GetBuilder<UserController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: controller.loadingPage != LoadingPage.otp
                ? Column(
                    children: [
                      TextFieldLoginRegister(
                        textControl: textConfirmOtp,
                        maxLength: null,
                        keyboardType: TextInputType.phone,
                        hintText: "OTP",
                        prefixIcon: const SizedBox(),
                        obscureText: false,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //1. Xác nhận lại số điện thoại: Gửi lại mã OTP, cập nhật lại verificationId (bên trong hàm)
                          ElevatedButton(
                            onPressed: () {
                              controller.phoneAuthentication(controller.phoneNumber.toString().trim());
                            },
                            child: const Text('Resend OTP'),
                          ),

                          //2. Xử lý xác nhận mã OTP đã gửi về điện thoại
                          ElevatedButton(
                            onPressed: () {
                              controller.controlOTP(textConfirmOtp.text.toString().trim(), LoadingPage.otp);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Confirm OTP',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Confirm OTP!")
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
