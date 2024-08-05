import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_auth_service.dart';
import 'widget_common.dart';

class MyLogin extends StatefulWidget {

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  MyFirebaseAuthService myFirebaseAuthService = MyFirebaseAuthService();

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xff4c505b),
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xff4c505b),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: () {
                            // Thuc hien dang nhap
                            signIn(context);
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'register');
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
    String password = textControlPassword.toString();

    User? user = await myFirebaseAuthService.signInWithEmailAndPassword(email, password);

    print(user.toString());

    if(user != null){
      // Navigator.pushNamed(context, 'home');
      print("Login OK");
    } else {
      print('Error: ${user.toString()}');
    }
  }
}
