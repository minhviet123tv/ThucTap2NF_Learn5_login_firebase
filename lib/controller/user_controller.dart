import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; //Nhận dữ liệu internet gói http

import '../login/confirm_phone_number.dart';
import '../login/otp_screen.dart';

/*
 Class GetxController thực hiện các dữ liệu và logic chung của app
 Dùng 'FirebaseAuth.instance.currentUser' để kết nối trực tiếp tài khoản user trên firebase
 Hoặc dạng 'firebaseAuth.currentUser'
 */

class UserController extends GetxController {
  static UserController get instance => Get.find();

  //I. Dữ liệu chung
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Firebase
  // final FirebaseFirestore firestore = FirebaseFirestore.instance; // Cloud Firebase Firestore database
  RxString verificationId = ''.obs; // id xác thực phone number (Được gửi về từ firebase)
  LoadingPage loadingPage = LoadingPage.none; // Tình trạng loading cho page đang dùng

  // Dữ liệu đăng nhập, đăng ký
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString passwordConfirm = ''.obs;
  final RxString phoneNumber = ''.obs; // Dùng RxString vì định dạng là kiểu +84123456789
  final RxString countryCode = ''.obs;
  final RxString countryCodeAndPhoneNumber = ''.obs;

  // Trạng thái UI của login_page
  late UILoginState uiLoginState = UILoginState.login; // Enum Login or signup state

  //II. onReady: Thực hiện sau khi cài đặt xong GetxController
  @override
  void onReady() {
    super.onReady();
  }

  //III. Hàm trong App: Sign in, Sign up
  //1. Hàm cập nhật trạng thái cho enum LoadingPage
  void loadingPageState(LoadingPage loadingPage) {
    this.loadingPage = loadingPage;
    update();
  }

  //2. Change switch UI Login State
  void switchLoginState() {
    uiLoginState == UILoginState.login ? uiLoginState = UILoginState.signup : uiLoginState = UILoginState.login;
    update(); // update cho UI
  }

  //3. Sign In vào tài khoản firebase
  Future<void> signInAppChat(BuildContext context, LoadingPage loadingPage) async {
    // Loading page state
    loadingPageState(loadingPage);

    // Kiểm tra trống dữ liệu
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", 'Please type email and password!', backgroundColor: Colors.green[300]);
      loadingPageState(LoadingPage.none); // Loading page
      return;
    }

    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.value);

    // Sign In, kiểm tra dữ liệu nhập vào (cấu trúc Email)
    if (emailValid && password.value.length >= 6) {
      // Kiểm tra tình trạng login và xác thực email
      try {
        User? user = await signInWithEmailAndPassword(email.value, password.value); // Dùng hàm signIn của firebase (đã tạo)
        if (user != null) {
          Get.toNamed('/home'); // Chuyển về home page nếu đăng nhập thành công
        }
      } catch (ex) {
        print(ex.toString());
      }
    } else {
      // Thông báo các lỗi của dữ liệu nhập vào
      String notify = "";

      if (emailValid) {
        notify += "Email ok! ";
      } else {
        notify += "Email not ok! ";
      }

      if (password.value.length < 6) {
        notify += "Password not ok! ";
      } else {
        notify += "Password ok!";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notify)));
    }

    // Loading page state
    loadingPageState(LoadingPage.none);
  }

  //4. Sign Up
  void signUpAppChat(BuildContext context, LoadingPage loadingPage) async {
    //I. Cập nhật trạng thái
    loadingPageState(loadingPage);

    //II. Kiểm tra cấu trúc Email
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.value);

    //III. Sign Up, kiểm tra cấu trúc email nhập vào
    if (emailValid && password.value.length >= 6 && password.value == passwordConfirm.value) {
      //1. Đăng ký tài khoản bằng email
      try {
        User? user = await signUpWithEmailAndPassword(email.value, password.value); // hàm firrebase đã tạo
        if (user != null) {
          // Lưu user vào Firestore database (đã đăng ký thành công)
          // collection: chứa tên bảng (có sẵn hoặc tạo nếu chưa có) | doc: id (của hàng) đặt vào hoặc để trống sẽ tạo tự động
          // set: Thêm dữ liệu của hàng (các cột)
          await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
            "uid": user.uid.toString(), // Lưu uid của chính nó
            "email": email.value.toString(),
          });

          // Chuyển hướng đến trang xác thực điện thoại
          Get.to(() => const ConfirmPhoneNumber(loadingPage: LoadingPage.confirmPhoneNumber));
          loadingPageState(LoadingPage.none); // Load xong trang
        }
      } catch (ex) {
        print(ex.toString());
      }
    } else {
      // Notify error
      String notify = "";

      if (emailValid) {
        notify += "Email ok! ";
      } else {
        notify += "Email not ok! ";
      }

      if (password.value.length < 6) {
        notify += "Password not ok! ";
      } else {
        notify += "Password ok! ";
      }

      if (password.value != passwordConfirm.value) {
        notify += "PasswordConfirm not same! ";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notify)));
    }

    //IV. Cập nhật trạng thái -> load xong
    loadingPageState(LoadingPage.none);
  }

  //5. Get phoneNumber and countryCode
  void getPhoneNumberAndContryCode() {
    countryCodeAndPhoneNumber.value = '${countryCode.value}${phoneNumber.value}';
  }

  //IV. Các hàm firebase: Hàm đăng ký, đăng nhập firebase, ...
  //1. Tạo user mới (User của UserCredential)
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Tạo tài khoản mới và trả về User (tài khoản firebase)
      UserCredential credential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (signUpError) {
      // Print Error
      print('Sign Up Error: ${signUpError.toString()}');

      // Thong bao khi email da ton tai | Notify when email exists
      if (signUpError.toString().contains("email-already-in-use")) {
        Get.snackbar("Notify", "",
            backgroundColor: Colors.green[300],
            messageText: const Text(
              "Email already in use!",
              style: TextStyle(fontSize: 16),
            ));
      } else {
        Get.snackbar("Error", "Please try again!");
      }
    }

    return null;
  }

  //2. Đăng nhập firebase, trả về user
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Nếu đã có tài khoản trên firebase -> return user
      UserCredential credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Trả về user (đã Sign in)
      return credential.user;
    } catch (signInError) {
      print('Sign In Error:: ${signInError.toString()}');

      // Thông báo nếu email chưa đăng ký hoặc password không đúng (invalid-credential)
      if (signInError.toString().contains('invalid-credential')) {
        // Sử dụng thông báo của Get.snackbar, tạo kiểu cho title và message
        Get.snackbar("", "",
            backgroundColor: Colors.green[300],
            titleText: const Text(
              "Notify",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            messageText: const Text(
              "Email or password invalid!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ));
      } else {
        Get.snackbar('Notify', signInError.toString(), backgroundColor: Colors.green[300]);
      }
    }

    // Trả về null (cho user) nếu lỗi (không đăng nhập được)
    return null;
  }

  //3. Thoát tài khoản firebase và xoá dữ liệu user ở GetxController
  Future<void> signOut() async {
    loadingPageState(LoadingPage.signOut); // update loading page state

    try {
      await firebaseAuth.signOut();

      // Clear các thông tin user đã lưu | Giữ email
      password.value = '';
      passwordConfirm.value = '';
      phoneNumber.value = '';
      countryCode.value = '';
      countryCodeAndPhoneNumber.value = '';

      loadingPageState(LoadingPage.none); // update loading page state
      Get.toNamed('/login'); // Chuyển hướng đến login
    } catch (exception) {
      print('Sign Out Error:\n ${exception.toString()}');
    }

    loadingPageState(LoadingPage.none); // update loading page state
  }

  //4. Xác nhận số điện thoại: gửi mã OTP về (Nếu số điện thoại có thật)
  // Có thể update số điện thoại luôn ở đây, hoặc chờ xác nhận xong OTP mới update
  Future<void> phoneAuthentication(LoadingPage loadingPage) async {
    //A. Cập nhật trạng thái loading
    loadingPageState(loadingPage);

    //B. Kiểm tra dữ liệu đưa vào
    if (phoneNumber.value.isEmpty || countryCode.value.isEmpty) {
      Get.snackbar("Error", 'Please type phone number!', backgroundColor: Colors.green[300]);
      loadingPageState(LoadingPage.none); // Chuyển trạng thái loading page về không
      return;
    }

    // Lấy số điện thoại đầy đủ
    getPhoneNumberAndContryCode();

    //C. Thực hiện phương thức verifyPhoneNumber
    await firebaseAuth.verifyPhoneNumber(
      //1. Số điện thoại đầy đủ gồm cả mã quốc gia + số điện thoại
      phoneNumber: countryCodeAndPhoneNumber.value,

      //2. Hành động sau khi nhận dạng đúng số điện thoại | (Đã thử dùng nhưng chưa thấy run được lệnh nào)
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("Verification Completed!");
        print("Credential: $credential");
      },

      //3. Khi xác nhận và kết nối thành công -> Có mã gửi về điện thoại
      // (số điện thoại đúng cấu trúc: mã quốc gia + số | Số điện thoại này có thể có thật hoặc không)
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId.value = verificationId; // Cập nhật verificationId (mã của firebase)

        // Khi dùng trạng thái là confirmPhoneNumber hoặc changePhoneNumber -> Confirm OTP | Không thể dùng this.loadingPage
        if (loadingPage == LoadingPage.confirmPhoneNumber || loadingPage == LoadingPage.changePhoneNumber) {
          Get.to(() => OtpScreen(
                loadingPage: loadingPage,
              )); // Đến trang nhập mã OTP, dùng trạng thái
        }

        // Khi dùng trạng thái chỉ gửi lại mã
        if (loadingPage == LoadingPage.resendOtp) {
          Get.snackbar("Notify", "Resend OTP successfully", backgroundColor: Colors.green[300]); // Thông báo đã gửi lại mã
        }
      },

      //4. Mã verificationId của firebase thay đổi khi chờ quá thời gian -> Cập nhật
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId.value = verificationId;
      },

      //5. Khi xác thực số điện thoại không thành công (Sẽ có load webview của firebase để xử lý rồi lại trả lại màn hình)
      verificationFailed: (FirebaseAuthException exception) {
        print('[Error] verify phone number:\n $exception');

        // Tách thành list và lấy phần tử đầu tiên (tên lỗi)
        String errFirst = exception.toString().split(']').first;
        String errFirstName = errFirst.substring(1, errFirst.length).split('/').last;
        Get.snackbar("Error", errFirstName);
      },
    );

    //D. Chuyển trạng thái loading page về không
    loadingPageState(LoadingPage.none);
  }

  //5. Xác thực mã OTP
  Future<void> verifyOTP(String textOtp, LoadingPage loadingPage) async {
    // Cập nhật trạng thái load page
    loadingPageState(loadingPage);

    try {
      // Đối tượng dùng để xác thực: truyền verificationId của firebase, mã OTP (đã gửi về số điện thoại và người dùng gõ vào)
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId.value, // Phải dùng phoneAuthentication trước để lấy mã này
        smsCode: textOtp,
      );

      // Thực hiện update số điện thoại bằng mã OTP (Mỗi lần update là phải xác thực)
      await FirebaseAuth.instance.currentUser?.updatePhoneNumber(phoneAuthCredential);

      // Xử lý sau khi xác nhận thành công OTP đăng ký tài khoản mới
      if (loadingPage == LoadingPage.confirmPhoneNumber) {
        Get.snackbar("Notify", "Register success!", backgroundColor: Colors.green[300]);
        Get.toNamed('/login');
        uiLoginState = UILoginState.login; // Chuyển sang trạng thái login
      }

      // Xử lý khi thay đổi số điện thoại
      if (loadingPage == LoadingPage.changePhoneNumber) {
        Get.snackbar("Notify", "Change phone number success!", backgroundColor: Colors.green[300]);
        Get.toNamed('/home');
      }
    } catch (exception) {
      print(['Error OTP: ${exception.toString()}']);

      // Tách lấy tên của error (phần đầu tiên trong ngoặc vuông []) -> Thông báo snackbar
      String errorFirst = exception.toString().split(']').first; // Tách phần tử đầu tiên và ký tự ']', nằm cuối phần tử
      String errorFirstName = errorFirst.substring(1, errorFirst.length).split('/').last; // Tách lấy tên lỗi ở cuối
      Get.snackbar("Error", errorFirstName); // Tách ký tự '[' của phần tử đầu tiên, nằm đầu phần tử
    }

    // Cập nhật trạng thái load page
    loadingPageState(LoadingPage.none);
  }

  //6. Update profile User (Gồm displayName, photoURL, password)
  Future<void> updateMyUser(BuildContext context, String newString, LoadingPage loadingPage) async {
    loadingPageState(loadingPage); // update loading page state

    // Kiểm tra dữ liệu đưa vào
    if(newString.isEmpty){
      Get.snackbar("Error", "Please type data!", backgroundColor: Colors.grey[300]);
      return;
    }

    // Cập nhật dữ liệu theo trạng thái
    try {
      // 1. Cập nhật displayName
      if (loadingPage == LoadingPage.changeDisplayName) {
        await firebaseAuth.currentUser?.updateDisplayName(newString);
        Get.snackbar("Notify", "Update displayName success!", backgroundColor: Colors.green[300]);
      }

      //2. Cập nhật photoURL: Vừa có đuôi ảnh, vừa có kết nối
      else if (loadingPage == LoadingPage.changePhotoURL) {

        //a. Kiểm tra đuôi photo
        if(!newString.contains(".jpg") && !newString.contains(".jpeg") && !newString.contains(".png")){
          Get.snackbar("Error", "Photo required format: jpg, jpeg, png", backgroundColor: Colors.grey[300]);
          return;
        }

        //b. Kiểm tra kết nối url. Lấy dữ liệu từ link bằng http.get()
        final getData = await http.get(Uri.parse(newString));
        // Nếu có kết nối (máy chủ trả về tín hiệu, trạng thái 200) -> có ảnh -> update ảnh cho user profile
        if (getData.statusCode == 200) {
          await firebaseAuth.currentUser?.updatePhotoURL(newString); // Update ảnh với URL đã xác minh
          Get.snackbar("Notify", "Update photoURL success!", backgroundColor: Colors.green[300]);
        } else {
          // Thông báo nếu lỗi
          Get.snackbar("Error", "Failed to load photos!", backgroundColor: Colors.green[300]);
          throw Exception('Failed to load photos');
        }
      }

      //3. Cập nhật password
      else if (loadingPage == LoadingPage.changePassword) {
        // Kiểm tra chiều dài mật khẩu
        if (newString.isEmpty || newString.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password must be >= 6 characters")));
          return;
        }
        // Cập nhật password cho currentUser đang login firebase
        await firebaseAuth.currentUser?.updatePassword(newString);
        Get.snackbar("Notify", "Update password success!", backgroundColor: Colors.green[300]);
      }
    } catch (ex) {
      print(ex.toString());
    }

    FocusScope.of(context).requestFocus(FocusNode()); // Ẩn bàn phím
    loadingPageState(LoadingPage.none); // update loading page state done
  }
}

// enum quản lý trạng thái loading trang
enum LoadingPage {
  none,
  signIn,
  signUp,
  signOut,
  confirmPhoneNumber,
  resendOtp,
  changeDisplayName,
  changePhotoURL,
  changePassword,
  changePhoneNumber,
}

// Quản lý trạng thái UI của login_page
enum UILoginState { signup, login }
