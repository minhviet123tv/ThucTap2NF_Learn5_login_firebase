import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/custom_widget/text_field_login_register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

class OtpScreen extends StatelessWidget {
  UserController userController = Get.find();
  late String textConfirmOtp = '';
  final LoadingPage loadingPage;

  OtpScreen({super.key, required this.loadingPage});

  // TextStyle của mỗi ô OtpTextField (bằng số lượng các ô)
  List<TextStyle> textStyleOTP = [
    const TextStyle(color: Colors.black, fontSize: 25),
    const TextStyle(color: Colors.black, fontSize: 25),
    const TextStyle(color: Colors.black, fontSize: 25),
    const TextStyle(color: Colors.black, fontSize: 25),
    const TextStyle(color: Colors.black, fontSize: 25),
    const TextStyle(color: Colors.black, fontSize: 25)
  ];

  // Trang widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm OTP"),
        centerTitle: true,
      ),
      body: otpScreenBody(),
    );
  }

  //I. Otp Screen Body
  otpScreenBody() {
    return GetBuilder<UserController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //I. Ảnh minh hoạ
                Image.asset('assets/images/verify_phone_number.png', width: 200),
                const SizedBox(height: 20),

                //II. Nhập mã OTP
                inputOtpTextField(),
                const SizedBox(height: 20),

                //III. Hàng nút điều khiển
                buttonControlOTP(),
              ],
            ),
          ),
        );
      },
    );
  }

  //II. Input Otp TextField
  inputOtpTextField() {
    return OtpTextField(
      numberOfFields: 6,
      styles: textStyleOTP,
      autoFocus: true,
      showFieldAsBox: false,
      borderWidth: 3.0,
      borderRadius: BorderRadius.circular(10),
      focusedBorderColor: Colors.red,
      enabledBorderColor: Colors.green,
      onSubmit: (value) {
        // Khi điền đầy các ô -> Xác thực OTP (value: giá trị toàn bộ OTP các ô của OtpTextField)
        userController.verifyOTP(value, loadingPage);
        textConfirmOtp = value; // Cập nhật mã ở UI để dùng lại
      },
    );
  }

  //III. Button Control OTP
  Widget buttonControlOTP() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //1. Gửi lại mã OTP (Xác nhận lại số điện thoại, nhận mã OTP mới)
        userController.loadingPage != LoadingPage.resendOtp
            ? ElevatedButton(
                onPressed: () {
                  userController.phoneAuthentication(LoadingPage.resendOtp);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Resend OTP', style: TextStyle(color: Colors.white)),
              )
            : const SizedBox(width: 140, height: 40, child: Center(child: CircularProgressIndicator())),

        //2. Xác nhận mã OTP (đã gửi về điện thoại)
        userController.loadingPage != loadingPage
            ? ElevatedButton(
                onPressed: () {
                  userController.verifyOTP(textConfirmOtp, loadingPage);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Confirm OTP', style: TextStyle(color: Colors.white)),
              )
            : const SizedBox(width: 140, height: 40, child: Center(child: CircularProgressIndicator())),
      ],
    );
  }
}
