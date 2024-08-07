import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:fire_base_app_chat/custom_widget/text_field_login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  String verificationId;

  OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  UserController userController = Get.find();

  TextEditingController textOtp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Screen"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFieldLoginRegister(
              textControl: textOtp,
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

                //1. Xác nhận lại số điện thoại, gửi lại mã OTP
                ElevatedButton(
                  onPressed: () {
                    userController.phoneAuthentication(userController.phoneNumber.toString().trim());
                  },
                  child: const Text('Repeat OTP'),
                ),

                //2. Xác nhận mã OTP đã gửi về điện thoại
                ElevatedButton(
                  onPressed: () async {
                    controlOTP();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Confirm OTP', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý xác nhận mã OTP: (Nếu để số điện thoại thử nghiệm trên firebase thì sẽ dùng mã đã lưu mà không nhận OTP gửi về)
  void controlOTP() async {
    bool otpSuccess = await userController.verifyOTP(userController.verificationId.value, textOtp.text.toString());
    if(otpSuccess){
      // Hành động khi xác nhận thành công -> Chuyển về màn login
      Get.toNamed('/login'); // arguments: {'email': userController.email.value,}
    } else {
      // Thông báo nếu xác nhận thất bại
      Get.snackbar("Error", "OTP invalid", backgroundColor: Colors.green[300]);
    }
  }
}
