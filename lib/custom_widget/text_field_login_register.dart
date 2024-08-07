
import 'package:flutter/material.dart';

//I. Wiget TextFeild tạo kiểu chung, nhập dữ liệu kiểu riêng khi khởi tạo
class TextFieldLoginRegister extends StatelessWidget {

  final TextEditingController? textControl;
  final int? maxLength;
  final TextInputType keyboardType;
  final String hintText;
  final Widget? prefixIcon;
  final bool? obscureText;
  final ValueChanged<String>? onChanged;

  TextFieldLoginRegister({super.key, this.textControl, this.maxLength, required this.keyboardType , required this.hintText,
    this.prefixIcon, this.obscureText, this.onChanged});

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: textControl,
      maxLines: 1, //dòng
      maxLength: maxLength, //số lượng ký tự
      enabled: true, //cho phép sử dụng
      keyboardType: keyboardType,
      textAlign: TextAlign.start, //Căn vị trí chữ gợi ý và chữ gõ vào
      style: const TextStyle(color: Colors.black), //kiểu dáng chữ sẽ gõ vào
      obscureText: obscureText ?? false, //Ẩn sau mỗi lần gõ (hay dùng cho password), phải đặt mặc định nếu null
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        // icon: Icon(Icons.email), //icon đầu dòng không nằm trong ô gõ
        prefixIcon: prefixIcon, //icon đầu dòng nằm trong ô gõ chữ
        contentPadding: const EdgeInsets.all(10),

        focusedBorder: const OutlineInputBorder( //Viền ngoài của TextField -> Khi có focus
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.all(Radius.circular(10)), //Bo góc viền
        ),
        enabledBorder: const OutlineInputBorder( //Viền ngoài của TextField -> Khi được phép gõ vào (enabled: true)
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.all(Radius.circular(10)), //Bo góc viền
        ),
      ),

    );
  }
}