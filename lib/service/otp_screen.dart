import 'package:fire_base_app_chat/custom_widget/text_field_login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpScreen extends StatefulWidget {
  String verificationId;

  OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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
            ElevatedButton(
                onPressed: () {
                  otpConfirm();
                },
                child: const Text('Confirm OTP')),
          ],
        ),
      ),
    );
  }

  void otpConfirm() async {
    try {
      // Xac thuc cua firebase
      PhoneAuthCredential credential = await PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: textOtp.text.toString(),
      );

      // Sau khi xac thuc thanh cong: Chuyen huong trang
      FirebaseAuth.instance.signInWithCredential(credential).then((value) {
        Get.toNamed('/home');
      });
    } catch (e) {
      print(e.toString());
      Get.snackbar("Notify", "Error");
    }
  }
}
