import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../lib/controller/user_controller.dart';
import 'widget_common.dart';

class MyLogin extends StatefulWidget {
  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  UserController userController = Get.find();

  // TextField control
  var textControlEmail = TextEditingController();
  var textControlPassword = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textControlEmail.dispose();
    textControlPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 80),
            child: const Text(
              "Welcome\nBack",
              style: TextStyle(color: Colors.white, fontSize: 33),
            ),
          ),
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(right: 35, left: 35, top: MediaQuery.of(context).size.height * 0.5),
                child: Column(children: [
                  TextInputLogin(
                    textControl: textControlEmail,
                    hintText: 'Email',
                    hideText: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextInputLogin(
                    textControl: textControlPassword,
                    hintText: 'Password',
                    hideText: true,
                  ),
                  const SizedBox(
                    height: 40,
                  ),

                  // Button Sign In
                  ElevatedButton(
                      onPressed: () {
                        // Thuc hien dang nhap
                        signIn(context);
                      },
                      child: const Text("Sign In", style: TextStyle(fontSize: 20),)
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    TextButton(
                      onPressed: () {
                        // Navigator.pushNamed(context, 'register');
                        Get.toNamed('/register');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          color: Color(0xff4c505b),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          color: Color(0xff4c505b),
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // Thuc hien dang nhap
  void signIn(BuildContext context) async {
    String email = textControlEmail.text.toString().trim();
    String password = textControlPassword.text.toString();

    User? user = await userController.myFirebaseAuthService.signInWithEmailAndPassword(email, password);

    if (user != null) {
      Get.toNamed('/home');
      print("Login OK");
    } else {
      print('Error: ${user.toString()}');
    }
  }
}
