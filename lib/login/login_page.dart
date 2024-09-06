import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_widget/text_field_login_register.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserController userController = Get.find(); // Getx controller
  TextEditingController textEmail = TextEditingController(); // TextField control

  @override
  void initState() {
    super.initState();
    // Đặt sẵn text email sau khi đăng ký thành công
    textEmail.text = userController.email.value;
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
            onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
            child: SingleChildScrollView(
              child: GetBuilder<UserController>(
                builder: (controller) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      //A. Text "My App Chat"
                      textMyApp(),

                      //B. Form Login, Signup
                      formLogInSignUp(),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  //I. text MyApp
  Widget textMyApp() {
    return Container(
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
    );
  }

  //II. form LogIn SignUp
  Widget formLogInSignUp() {
    return Container(
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
            if (userController.uiLoginState == UILoginState.signup)
              GetBuilder<UserController>(
                builder: (controller) {
                  return TextFieldLoginRegister(
                    onChanged: (value) {
                      userController.passwordConfirm.value = value; // Cập nhật giá trị
                    },
                    maxLength: null,
                    keyboardType: TextInputType.visiblePassword,
                    hintText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock),
                    obscureText: true,
                  );
                },
              ),
            const SizedBox(
              height: 10,
            ),

            //4. Button login & signup (Ghép nút)
            (userController.loadingPage != LoadingPage.signIn && userController.loadingPage != LoadingPage.signUp)
                ? GetBuilder<UserController>(
                    builder: (controller) {
                      return ElevatedButton(
                        onPressed: () {
                          if (userController.uiLoginState == UILoginState.login) {
                            userController.signInAppChat(context, LoadingPage.signIn); // Xử lý bấm LOGIN
                          } else {
                            userController.signUpAppChat(context, LoadingPage.signUp); // Xử lý khi bấm nút SIGNUP
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4201FF), //4201FFFF -> 0xFF 4201FF (chuyển đuôi FF vào đầu 0x => 0xFF)
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        child: Text(
                          userController.uiLoginState == UILoginState.login ? 'LOGIN' : 'SIGN UP',
                          style: const TextStyle(color: Colors.white, fontFamily: "KlarnaText"),
                        ),
                      );
                    },
                  )
                : const CircularProgressIndicator(),
            const SizedBox(
              height: 10,
            ),

            //5. Chuyển đổi UI sang LOGIN hoặc SIGNUP
            GetBuilder<UserController>(
              builder: (controller) {
                return TextButton(
                  onPressed: () {
                    userController.switchLoginState(); // Cập nhật giao diện
                  },
                  child: Text(
                    '${userController.uiLoginState == UILoginState.login ? 'SIGNUP' : 'LOGIN'} PAGE',
                    style: const TextStyle(
                      fontFamily: "KlarnaText",
                      color: Color(0xFF4201FF),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
