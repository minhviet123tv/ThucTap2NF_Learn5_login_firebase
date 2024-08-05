import 'package:fire_base_app_chat/widget_common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_auth_service.dart';

class MyRegister extends StatefulWidget {
  @override
  State<MyRegister> createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  // Cung cap phuong thuc su dung Firebase
  MyFirebaseAuthService myFirebaseAuthService = MyFirebaseAuthService();

  // TextField control
  var textControlName = TextEditingController();
  var textControlEmail = TextEditingController();
  var textControlPassword = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textControlName.dispose();
    textControlEmail.dispose();
    textControlPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 5,
        ),
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 80),
            child: const Text(
              "Create\nAccount",
              style: TextStyle(color: Colors.white, fontSize: 33),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(right: 35, left: 35, top: MediaQuery.of(context).size.height * 0.27),
              child: Column(children: [
                TextInputRegister(
                  textControl: textControlName,
                  hintText: 'Name',
                  hideText: false,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextInputRegister(
                  textControl: textControlEmail,
                  hintText: 'Email',
                  hideText: false,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextInputRegister(
                  textControl: textControlPassword,
                  hintText: 'Password',
                  hideText: true,
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Nut thuc hien signin
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xff4c505b),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        _registerAccount(context);
                      },
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ]),
                const SizedBox(
                  height: 40,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'login');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // register account
  void _registerAccount(BuildContext context) async {
    String name = textControlName.text.toString().trim();
    String email = textControlEmail.text.toString().trim();
    String password = textControlPassword.text.toString();

    User? user = await myFirebaseAuthService.signUpWithEmailAndPassword(email, password);

    print(user.toString());

    // Thong bao ket qua
    if (user != null) {
      print("Success created User");
      Navigator.popAndPushNamed(context, 'login');
    } else {
      print('Some error happend in Register');
    }
  }
}
