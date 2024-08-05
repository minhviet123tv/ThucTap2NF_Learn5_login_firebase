import 'package:flutter/material.dart';

//I. TextField in login page
class TextInputLogin extends StatefulWidget {
  TextEditingController textControl = TextEditingController();
  late String hintText = "";
  bool hideText;

  TextInputLogin({super.key, required this.textControl, required this.hintText, required this.hideText});

  @override
  State<TextInputLogin> createState() => _TextInputLoginState();
}

class _TextInputLoginState extends State<TextInputLogin> {

  bool showButtonClear = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textControl,
      obscureText: widget.hideText,
      onChanged: (value) {
        if (value.toString().trim().isNotEmpty) {
          setState(() {
            showButtonClear = true;
          });
        } else {
          setState(() {
            showButtonClear = false;
          });
        }
      },
      decoration: InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        suffixIcon: showButtonClear
            ? IconButton(
                onPressed: () {
                  widget.textControl.clear();
                  setState(() {
                    showButtonClear = false;
                  });
                },
                icon: const Icon(Icons.cancel_outlined),
              )
            : null,
      ),
    );
  }
}

//II. TextField in register page
class TextInputRegister extends StatefulWidget {
  TextEditingController textControl = TextEditingController();
  late String hintText = "";
  late bool hideText;

  TextInputRegister({super.key, required this.textControl, required this.hintText, required this.hideText});

  @override
  State<TextInputRegister> createState() => _TextInputRegisterState();
}

class _TextInputRegisterState extends State<TextInputRegister> {

  bool showButtonClear = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textControl,
      onChanged: (value) {
        if (value.toString().trim().isNotEmpty) {
          setState(() {
            showButtonClear = true;
          });
        } else {
          setState(() {
            showButtonClear = false;
          });
        }
      },
      obscureText: widget.hideText,
      decoration: InputDecoration(
        suffixIcon: showButtonClear
            ? IconButton(
                onPressed: () {
                  widget.textControl.clear();
                  setState(() {
                    showButtonClear = false;
                  });
                },
                icon: const Icon(Icons.cancel_outlined),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.white),
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
