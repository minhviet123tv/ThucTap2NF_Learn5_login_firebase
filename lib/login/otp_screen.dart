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
            child: Column(
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
                    //1. Xác nhận lại số điện thoại: Gửi lại mã OTP (Có thể có cập nhật lại verificationId bên trong hàm)
                    ElevatedButton(
                      onPressed: () {
                        controller.phoneAuthentication(LoadingPage.confirmPhone);
                        print("Clicked Resend OTP");
                      },
                      child: const Text('Resend OTP'),
                    ),

                    //2. Xử lý xác nhận mã OTP đã gửi về điện thoại
                    controller.loadingPage != LoadingPage.confirmOtp
                        ? ElevatedButton(
                            onPressed: () {
                              controller.controlOTP(textConfirmOtp.text.toString().trim(), LoadingPage.confirmOtp);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Confirm OTP',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : const SizedBox(width: 140, child: Center(child: CircularProgressIndicator())),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
