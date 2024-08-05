import 'package:fire_base_app_chat/firebase_auth_service.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'login.dart';
import 'register.dart';

/*
add hoac pub get:
firebase_core: ^3.3.0
firebase_analytics: ^11.2.1
firebase_auth: ^5.1.3
 */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      // Chuyen huong luon khi moi mo app
      home: SafeArea(
        child: HomePage(),
      ),
      routes: {
        'login': (context) => MyLogin(),
        'register': (context) => MyRegister(),
        'home': (context) => HomePage(),
      },
      onGenerateRoute: (settings) {},
    ),
  );
}

class HomePage extends StatelessWidget {

  MyFirebaseAuthService myFirebaseAuthService = MyFirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Home Page", style: TextStyle(fontSize: 30),),
            const SizedBox(height: 10,),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  myFirebaseAuthService.signOut(); // sign out
                  Navigator.pushNamed(context, 'login');
                },
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
