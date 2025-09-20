import 'package:fire_base_app_chat/controller/all_controller_binding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

Future<void> main() async {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: const Text("In app purchase"),
          backgroundColor: Colors.blue,
        ),
        body: ElevatedButton(onPressed: () {}, child: const Text("Button")),
      )),
    );
  }
}
