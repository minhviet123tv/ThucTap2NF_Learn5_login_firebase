import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmPhoneNumber extends StatefulWidget {

  final LoadingPage loadingPage; // Trạng thái khi sử dụng trang

  const ConfirmPhoneNumber({super.key, required this.loadingPage});

  @override
  State<ConfirmPhoneNumber> createState() => _ConfirmPhoneNumberState();
}

class _ConfirmPhoneNumberState extends State<ConfirmPhoneNumber> {
  UserController userController = Get.find();
  TextEditingController textCountryCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    textCountryCode.text = "+84";
    userController.countryCode.value = textCountryCode.text;
  }

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //1. Ảnh minh hoạ
                      Image.asset(
                        'assets/images/verify_phone_number.png',
                        width: 250,
                      ),
                      const SizedBox(height: 20),

                      //2. Ô nhập số điện thoại
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.green),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 40,

                              //country code
                              child: TextField(
                                controller: textCountryCode,
                                onChanged: (value) {
                                  controller.countryCode.value = value; // Cập nhật countryCode cho GetxController
                                },
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "+84",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const VerticalDivider(color: Colors.green),
                            const SizedBox(width: 10),

                            // phone number
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  userController.phoneNumber.value = value;
                                },
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "phone number",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      //3. Nút bấm xác nhận, thực hiện xác thực số điện thoại -> Chuyển đến xác nhận OTP
                      controller.loadingPage != widget.loadingPage
                          ? ElevatedButton(
                              onPressed: () {
                                controller.phoneAuthentication(widget.loadingPage); // Xác thực -> Xác nhận OTP
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text('Verify', style: TextStyle(fontSize: 20, color: Colors.white)),
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
