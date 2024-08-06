import 'package:fire_base_app_chat/custom_widget/text_field_login_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/otp_screen.dart';

class ConfirmPhoneNumber extends StatefulWidget {
  ConfirmPhoneNumber({
    super.key,
  });

  @override
  State<ConfirmPhoneNumber> createState() => _ConfirmPhoneNumberState();
}

class _ConfirmPhoneNumberState extends State<ConfirmPhoneNumber> {
  TextEditingController textPhoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Phone Number"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFieldLoginRegister(
                  textControl: textPhoneNumber,
                  maxLength: null,
                  keyboardType: TextInputType.phone,
                  hintText: "+840987654321",
                  prefixIcon: const SizedBox(),
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    phoneAuthentication();
                  },
                  child: const Text('Verify Phone Number'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //III. Confirm phone number
  void phoneAuthentication() async {

    await FirebaseAuth.instance.verifyPhoneNumber(
      verificationCompleted: (PhoneAuthCredential credential) {
        Get.snackbar("Notify", 'Confirm Phone Number Success!', backgroundColor: Colors.purpleAccent);
      },
      verificationFailed: (FirebaseAuthException exception) {},
      codeSent: (String verificationId, int? resendtoken) {
        // Chuyen huong khi co ma xac thuc
        Get.to(() => OtpScreen(
              verificationId: verificationId,
            ));
      },
      codeAutoRetrievalTimeout: (String verificationid) {},
      phoneNumber: textPhoneNumber.text.toString().trim(),
    );
  }
}
