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
      body: Column(
        children: [
          TextFieldLoginRegister(
              textControl: textOtp,
              maxLength: null,
              keyboardType: TextInputType.phone,
              hintText: "OTP",
              prefixIcon: const SizedBox(),
              obscureText: false),
          ElevatedButton(
              onPressed: () {
                otpConfirm();
              },
              child: const Text('Confirm OTP')),
        ],
      ),
    );
  }

  void otpConfirm() async {
    try {
      PhoneAuthCredential credential =
          await PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: textOtp.text.toString());
      FirebaseAuth.instance.signInWithCredential(credential).then((value){
        Navigator.pop(context);
      });
    } catch (e) {
      print(e.toString());
      Get.snackbar("Notify", "Error");
    }
  }
}
