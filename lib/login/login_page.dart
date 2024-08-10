import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_widget/text_field_login_register.dart';

enum UIState { signup, login }

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserController userController = Get.find(); // Getx controller
  TextEditingController textEmail = TextEditingController(); // TextField control
  late UIState _uiState = UIState.login; // Enum Login or signup state

  @override
  void initState() {
    super.initState();
    // Đặt sẵn text email sau khi đăng ký thành công
    textEmail.text = userController.email.value;
  }

  // Change switch UI State
  void _switchLoginState() {
    setState(() {
      _uiState == UIState.login ? _uiState = UIState.signup : _uiState = UIState.login;
    });
  }

  // Khung trang
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1), // position of color
            ),
          ),
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: SingleChildScrollView(
              child: widgetBodyLoginPage(context),
            ),
          ),
        ),
      ),
    );
  }

  //I. Widget body of LoginPage
  Widget widgetBodyLoginPage(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),

            //A. Text "MyShop"
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.fromLTRB(20, 10, 30, 30),
              decoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3), //x và y
                  ),
                ],
              ),
              transform: Matrix4.rotationZ(-0.11),
              child: const Text(
                "My App Chat ",
                style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),

            //B. Form Login, Signup
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3), //x và y
                  ),
                ],
              ),

              // Dùng Form để có các tính năng trao đổi với server như: autovalidateMode
              child: Form(
                child: Column(
                  children: [
                    //1. Email
                    TextFieldLoginRegister(
                      textControl: textEmail,
                      onChanged: (value) {
                        userController.email.value = value; // Cập nhật giá trị
                      },
                      maxLength: null,
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      obscureText: false,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    //2. TextField password
                    TextFieldLoginRegister(
                      onChanged: (value) {
                        userController.password.value = value; // Cập nhật giá trị
                      },
                      maxLength: null,
                      keyboardType: TextInputType.visiblePassword,
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    //3. TextField confirm password
                    if (_uiState == UIState.signup)
                      TextFieldLoginRegister(
                        onChanged: (value) {
                          userController.passwordConfirm.value = value; // Cập nhật giá trị
                        },
                        maxLength: null,
                        keyboardType: TextInputType.visiblePassword,
                        hintText: "Confirm Password",
                        prefixIcon: const Icon(Icons.lock),
                        obscureText: true,
                      ),
                    const SizedBox(
                      height: 10,
                    ),

                    //4. Button login & signup (Ghép nút)
                    (userController.loadingPage != LoadingPage.signin && userController.loadingPage != LoadingPage.signup)
                        ? ElevatedButton(
                            onPressed: () {
                              if (_uiState == UIState.login) {
                                // Xử lý bấm LOGIN
                                userController.signInAppChat(context, LoadingPage.signin);
                              } else {
                                // Xử lý khi bấm nút SIGNUP
                                userController.signUpAppChat(context, LoadingPage.signup);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4201FF), //4201FFFF -> 0xFF 4201FF (chuyển đuôi FF vào đầu 0x => 0xFF)
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                            child: Text(
                              _uiState == UIState.login ? 'LOGIN' : 'SIGN UP',
                              style: const TextStyle(color: Colors.white, fontFamily: "KlarnaText"),
                            ),
                          )
                        : const CircularProgressIndicator(),
                    const SizedBox(
                      height: 10,
                    ),

                    // Nút tạm để code
                    // ElevatedButton(
                    //   onPressed: () => Get.to(() => const ConfirmPhoneNumber()),
                    //   child: const Text("Open confirm phone number"),
                    // ),

                    //5. Chuyển đổi UI sang LOGIN hoặc SIGNUP
                    TextButton(
                      onPressed: () {
                        _switchLoginState(); // Cập nhật giao diện
                      },
                      child: Text(
                        '${_uiState == UIState.login ? 'SIGNUP' : 'LOGIN'} PAGE',
                        style: const TextStyle(
                          fontFamily: "KlarnaText",
                          color: Color(0xFF4201FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      },
    );
  }
}
