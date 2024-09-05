import 'package:fire_base_app_chat/home/home_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

/*
TextField chuyên nhập mã OTP
flutter_otp_text_field: ^1.1.3+2
https://pub.dev/packages/flutter_otp_text_field
 */

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Examples"),
        ),
        body: Column(
          children: [
            OtpTextField(
              numberOfFields: 5,
              borderColor: const Color(0xFF512DA8),
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(10),
              // Viền hộp
              onCodeChanged: (String code) {
                //handle validation or checks here
              },
              //runs when every textfield is filled
              onSubmit: (String verificationCode) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Verification Code"),
                        content: Text('Code entered is $verificationCode'),
                      );
                    });
              }, // end onSubmit
            ),
            OtpTextField(
              numberOfFields: 5,
              // Số lượng number bằng số lượng TextStyle
              borderColor: accentPurpleColor,
              focusedBorderColor: accentPurpleColor,
              styles: const [
                TextStyle(
                  color: Colors.green,
                  fontSize: 25,
                ),
                TextStyle(
                  color: Colors.red,
                  fontSize: 25,
                ),
                TextStyle(
                  color: Colors.brown,
                  fontSize: 25,
                ),
                TextStyle(
                  color: Colors.grey,
                  fontSize: 25,
                ),
                TextStyle(
                  color: Colors.blue,
                  fontSize: 25,
                )
              ],
              showFieldAsBox: false,
              // Hiện hộp cho từng số
              borderWidth: 6.0,
              // Chiều rộng của thanh đế, hộp
              borderRadius: BorderRadius.circular(5),
              // Viền hộp
              onCodeChanged: (String code) {
                // Chạy khi mã được nhập vào | xử lý xác thực hoặc kiểm tra tại đây nếu cần
              },
              onSubmit: (String verificationCode) {
                // Chạy khi mọi trường văn bản được điền đầy | runs when every textfield is filled
              },
            ),
          ],
        ),
      ),
    );
  }

  void nav(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeMain()));
  }
}

const Color accentPurpleColor = Color(0xFF6A53A1);
const Color accentPinkColor = Color(0xFFF99BBD);
const Color accentDarkGreenColor = Color(0xFF115C49);
const Color accentYellowColor = Color(0xFFFFB612);
const Color accentOrangeColor = Color(0xFFEA7A3B);
