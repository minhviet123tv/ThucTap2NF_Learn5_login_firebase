import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../login/confirm_phone_number.dart';
import '../login/otp_screen.dart';

/*
 class GetxController thực hiện các dữ liệu và logic chung của app
 */

class UserController extends GetxController {
  static UserController get instance => Get.find();

  //I. Dữ liệu chung
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Firebase
  late Rx<User?> user; // Tài khoản firebase
  RxString verificationId = ''.obs; // id xác thực phone number (Được gửi về từ firebase)
  LoadingPage loadingPage = LoadingPage.none; // Tình trạng loading cho page đang dùng

  // Dữ liệu đăng nhập, đăng ký
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString passwordConfirm = ''.obs;
  final RxString phoneNumber = ''.obs; // Dùng RxString vì định dạng là kiểu +84123456789
  final RxString countryCode = ''.obs;
  final RxString countryCodeAndPhoneNumber = ''.obs;

  //II. onReady: Thực hiện sau khi cài đặt xong GetxController
  @override
  void onReady() {
    super.onReady();
    user = Rx<User?>(firebaseAuth.currentUser); // Khai báo tài khoản user
  }

  //III. Hàm trong App: Sign in, Sign up
  //1. Hàm cập nhật trạng thái cho enum LoadingPage
  void loadingPageState(LoadingPage loadingPage) {
    this.loadingPage = loadingPage;
    update();
  }

  //2. Sign In
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
      User? user = await signInWithEmailAndPassword(email.value, password.value); // Dùng hàm signIn của firebase (đã tạo)

      if (user != null) {
        Get.toNamed('/home'); // Chuyển về home page nếu đăng nhập thành công
      } else {
        print('Error: ${user.toString()}'); // In lỗi nếu không đăng nhập được
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

  //3. Sign Up
  void signUpAppChat(BuildContext context, LoadingPage loadingPage) async {
    // Cập nhật trạng thái
    loadingPageState(loadingPage);

    //Kiểm tra cấu trúc Email
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.value);

    // Sign Up
    if (emailValid && password.value.length >= 6 && password.value == passwordConfirm.value) {
      // Đăng ký bằng hàm của firebase đã tạo
      User? user = await signUpWithEmailAndPassword(email.value, password.value);
      print("sign up 1");

      // Sau khi xác đăng ký email và password thành công
      if (user != null) {
        Get.to(() => ConfirmPhoneNumber()); // Chuyển hướng đến trang ConfirmPhoneNumber
      } else {
        print('Some error happend in Sign Up'); // Cũng đã có thông báo trong hàm của firebase
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

    // Cập nhật trạng thái -> load xong
    loadingPageState(LoadingPage.none);
  }

  //4. Get phoneNumber and countryCode
  void getPhoneNumberAndContryCode (){
    countryCodeAndPhoneNumber.value = '${countryCode.value}${phoneNumber.value}';
  }

  //III. Các hàm firebase: Hàm đăng ký, đăng nhập firebase, ...
  //1. Tạo user mới (User của UserCredential)
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Tạo tài khoản mới và trả về tài khoản firebase
      UserCredential credential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      print("sign up 2");
      return credential.user;
    } catch (signUpError) {
      // Print Error
      print('Sign Up Error: ${signUpError.toString()}');
      print("sign up 3");

      // Thong bao khi email da ton tai | Notify when email exists
      if (signUpError.toString().contains("email-already-in-use")) {
        Get.snackbar("Notify", "",
            backgroundColor: Colors.green[300],
            messageText: const Text(
              "Email already in use!",
              style: TextStyle(fontSize: 16),
            ));
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

  //3. Thoát tài khoản firebase và xoá dữ liệu user ở controller
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();

      // Clear các thông tin user đã lưu | Giữ email
      password.value = "";
      passwordConfirm.value = '';
      countryCodeAndPhoneNumber.value = '';

      Get.toNamed('/login'); // Chuyển hướng đến login
    } catch (exception) {
      print('Sign Out Error:\n ${exception.toString()}');
    }
  }

  //4. Xác thực số điện thoại: Nếu số điện thoại có thật thì sẽ gửi mã OTP về
  Future<void> phoneAuthentication(LoadingPage loadingPage) async {
    //a. Cập nhật trạng thái loading
    loadingPageState(loadingPage);

    //b. Kiểm tra dữ liệu đưa vào
    if (phoneNumber.value.isEmpty || countryCode.value.isEmpty) {
      Get.snackbar("Error", 'Please type phone number!', backgroundColor: Colors.green[300]);
      loadingPageState(LoadingPage.none); // Chuyển trạng thái loading page về không
      return;
    }

    // Lấy số điện thoại đầy đủ
    getPhoneNumberAndContryCode();

    //c. Thực hiện phương thức verifyPhoneNumber
    await firebaseAuth.verifyPhoneNumber(
      //1. Số điện thoại đầy đủ gồm cả mã quốc gia + số điện thoại
      phoneNumber: countryCodeAndPhoneNumber.value,

      //2. Hành động sau khi xác minh hoàn tất | (Đã thử dùng nhưng chưa thấy run được lệnh nào)
      verificationCompleted: (PhoneAuthCredential credential) async {
        print("Verification Completed \ncredential: \n$credential");
      },

      //3. Khi xác minh và kết nối thành công -> Có mã gửi về điện thoại
      // (số điện thoại đúng cấu trúc: mã quốc gia + số | Số điện thoại này có thể có thật hoặc không)
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId.value = verificationId; // Cập nhật verificationId (mã của firebase)

        // Khi dùng trạng thái cho trang là xác nhận số điện thoại và gửi mã
        if(loadingPage == LoadingPage.confirmPhone) {
          Get.to(() => OtpScreen()); // Đến trang nhập mã OTP
        }

        // Khi dùng trạng thái chỉ gửi lại mã
        if(loadingPage == LoadingPage.resendOtp){
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
        Get.snackbar("Error", exception.toString());
      },
    );

    //d. Chuyển trạng thái loading page về không
    loadingPageState(LoadingPage.none);
  }

  //5.1 Hàm xử lý xác nhận mã OTP
  Future<void> controlOTP(String textConfirmOtp) async {
    //I. Cập nhật trạng thái load page
    loadingPageState(LoadingPage.confirmOtp);

    //II. Thực hiện xác thực mã otp và nhận về kết quả xác thực
    bool otpSuccess = await verifyOTP(verificationId.value, textConfirmOtp);

    //III. Hành động khi xác nhận thành công: Thông báo, chuyển về màn login | Có thể lưu số đã xác thực cho user
    if (otpSuccess) {
      Get.snackbar("Notify", "Register success!", backgroundColor: Colors.green[300]);
      Get.toNamed('/login'); // arguments: {'email': userController.email.value,}
    } else {
      // Thông báo nếu xác nhận thất bại
      Get.snackbar("Error", "OTP invalid", backgroundColor: Colors.green[300]);
    }

    //IV. Cập nhật trạng thái load page
    loadingPageState(LoadingPage.none);
  }

  //5.2 Xác thực mã OTP: Phản hồi của điện thoại trả về firebase (Người dùng lấy mã OTP đã nhận và phản hồi lại)
  // Nhập mã OTP đúng/sai: tạo trả về true/false
  Future<bool> verifyOTP(String verificationId, String textOtp) async {
    try {
      // Tạo đối tượng dùng để xác thực: truyền verificationId của firebase, mã OTP (đã gửi về số điện thoại và người dùng gõ vào)
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: textOtp,
      );

      // Thực hiện xác thực bằng cách đăng nhập vào firebase (gần giống dạng id và mật khẩu)
      // (Có thể tạo .then(value){Get.toNamed('/login');}; để chuyển hướng sau khi xác thực thành công)
      UserCredential credential = await firebaseAuth.signInWithCredential(phoneAuthCredential);

      // Nếu đăng nhập thành công -> có user -> true và ngược lại
      return credential.user != null ? true : false;
    } catch (exception) {
      print(exception.toString());
    }

    // Trả về false nếu xác thực không được
    return false;
  }
}

// enum quản lý trạng thái loading trang
enum LoadingPage { none, signin, signup, confirmPhone, confirmOtp, resendOtp }
