import 'package:fire_base_app_chat/controller/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../custom_widget/text_field_login_register.dart';
import 'confirm_phone_number.dart';

enum LoginState { signup, login }

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Getx controller
  UserController userController = Get.find();

  // TextField control
  TextEditingController textEmail = TextEditingController();

  // Enum Login or signup state
  LoginState _loginState = LoginState.login;

  @override
  void initState() {
    super.initState();
    // Khởi tạo theo GetxController để đặt sẵn email sau khi đăng ký thành công
    textEmail.text = userController.email.value;
  }

  // Change AuthMode _authMode
  void _switchLoginState() {
    setState(() {
      _loginState == LoginState.login ? _loginState = LoginState.signup : _loginState = LoginState.login;
    });
  }

  // Khung
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

  /*
  UI
   */

  //I. Widget body of LoginPage
  Widget widgetBodyLoginPage(BuildContext context) {
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
              )
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
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), color: Colors.white),

          //Dùng Form để có các tính năng trao đổi với server như: autovalidateMode
          child: Form(
            child: Column(
              children: [
                //1. Email
                TextFieldLoginRegister(
                  textControl: textEmail,
                  onChanged: (value) {
                    userController.email.value = value;
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

                //2. Password
                TextFieldLoginRegister(
                  onChanged: (value) {
                    userController.password.value = value;
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

                //3. Confirm password
                if (_loginState == LoginState.signup)
                  TextFieldLoginRegister(
                    onChanged: (value) {
                      userController.passwordConfirm.value = value;
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

                //4. Button login & signup
                ElevatedButton(
                  onPressed: () {
                    if (_loginState == LoginState.login) {
                      // Xử lý bấm LOGIN
                      signInAppChat(context);
                    } else {
                      // Xử lý khi bấm nút SIGNUP
                      signUpAppChat(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4201FF), //4201FFFF -> 0xFF 4201FF (chuyển đuôi FF vào đầu 0x => 0xFF)
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  child: Text(
                    _loginState == LoginState.login ? 'LOGIN' : 'SIGN UP',
                    style: const TextStyle(color: Colors.white, fontFamily: "KlarnaText"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                //5. TextButton chuyển đổi trạng thái LOGIN hoặc SIGNUP
                TextButton(
                  onPressed: () {
                    _switchLoginState();
                  },
                  child: Text(
                    '${_loginState == LoginState.login ? 'SIGNUP' : 'LOGIN'} PAGE',
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
  }

  /*
  LOGIC
   */

  //I. Sign In
  void signInAppChat(BuildContext context) async {
    //Kiểm tra cấu trúc Email nếu đúng
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(userController.email.value);

    // Sign In
    if (emailValid && userController.password.value.length >= 6) {
      String email = userController.email.value.toString().trim();
      String password = userController.password.value.toString();

      // Sign in with firebase method in GetxController
      User? user = await userController.signInWithEmailAndPassword(email, password);

      // Go to home page
      if (user != null) {
        // userController.accountLogin = AccountLogin(email, password); // Save to GetxController
        Get.toNamed('/home', arguments: {'email': email, 'password': password});
      } else {
        print('Error: ${user.toString()}');
      }
    } else {
      // Notify if structural error
      String notify = "";

      if (emailValid) {
        notify += "Email ok! ";
      } else {
        notify += "Email not ok! ";
      }

      if (userController.password.value.length < 6) {
        notify += "Password not ok! ";
      } else {
        notify += "Password ok!";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notify)));
    }
  }

  //II. Sign Up
  void signUpAppChat(BuildContext context) async {
    //Kiểm tra cấu trúc Email nếu đúng
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(userController.email.value);

    // Sign Up
    if (emailValid &&
        userController.password.value.length >= 6 &&
        userController.password.value == userController.passwordConfirm.value) {
      String email = userController.email.value.toString().trim();
      String password = userController.password.value.toString();

      // Sign Up with firebase method in GetxController
      User? user = await userController.signUpWithEmailAndPassword(email, password);

      // Sau khi dang ky Email thanh cong
      if (user != null) {
        // Chuyen den trang xac thuc dien thoai
        // Get.to(()=> ConfirmPhoneNumber());
        Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmPhoneNumber()));
      } else {
        print('Some error happend in Sign Up');
        // There has been a Notify that Email exist in MyFirebaseAuthService class
      }
    } else {
      // Notify error
      String notify = "";

      if (emailValid) {
        notify += "Email ok! ";
      } else {
        notify += "Email not ok! ";
      }

      if (userController.password.value.length < 6) {
        notify += "Password not ok! ";
      } else {
        notify += "Password ok! ";
      }

      if (userController.password.value != userController.passwordConfirm.value) {
        notify += "Password not same! ";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notify)));
    }
  }
}
