import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../service/otp_screen.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  //I. Dữ liệu
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Firebase
  late Rx<User?> firebaseUser; // Tài khoản firebase
  RxString verificationId = ''.obs; // id xác thực, sẽ có khi thực hiện xác nhận số điện thoại (Được gửi về từ firebase)

  // Dữ liệu đăng nhập, đăng ký
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString passwordConfirm = ''.obs;
  final RxString phoneNumber = ''.obs; // Dùng RxString vì định dạng là kiểu +84123456789

  //II. onReady: Thực hiện sau khi cài đặt xong GetxController
  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(firebaseAuth.currentUser); // Khai báo tài khoản user
  }

  //1. Tạo user mới (User của UserCredential)
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Tạo tài khoản mới và trả về tài khoản firebase
      UserCredential credential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (signUpError) {
      // Print Error
      print('Sign Up Error:: ${signUpError.toString()}');

      // Thong bao khi email da ton tai | Notify when email exists
      if (signUpError.toString().contains("email-already-in-use")) {
        Get.snackbar("Notify", "", backgroundColor: Colors.green[300], messageText: const Text("Email already in use!", style: TextStyle(fontSize: 16),));
      }
    }

    return null;
  }

  //2. Đăng nhập user
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

      // Thông báo nếu email chưa đăng ký (Xác nhận theo mã trong thông báo lỗi)
      if (signInError.toString().contains('invalid-credential')) {
        // Sử dụng thôngbáo của Get.snackbar, tạo kiểu cho title và message
        Get.snackbar("", "",
            backgroundColor: Colors.green[300],
            titleText: const Text(
              "Notify",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            messageText: const Text(
              "Email is not register!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ));
      }
    }

    // Trả về null (cho user) nếu lỗi (không đăng nhập được)
    return null;
  }

  //3. Thoát tài khoản firebase
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      // print lỗi (không hiện trên màn hình UI)
      print('Sign Out Error: ${e.toString()}');
    }
  }

  //4.1 Xác thực số điện thoại: Nếu số điện thoại có thật thì sẽ gửi mã OTP đến
  Future<void> phoneAuthentication(String textPhoneNumber) async {
    // Thực hiện phương thức verifyPhoneNumber
    await firebaseAuth.verifyPhoneNumber(
      //1. Số điện thoại đã truyền vào
      phoneNumber: textPhoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) async {
        Get.snackbar("Notify", 'Confirm Phone Number Success!', backgroundColor: Colors.purpleAccent);
        await firebaseAuth.signInWithCredential(credential); // Đăng nhập firebase sau khi xác thực
      },

      //2. Kết nối thành công: Số điện thoại đúng cấu trúc (mã quốc gia + số | Số điện thoại này có thể có thật hoặc không)
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId.value = verificationId; // Cập nhật verificationId (mã của firebase) cho GetxController
        // Hành động chuyển hướng khi có mã xác thực -> Đến trang nhập mã đã gửi về điện thoại
        Get.to(() => OtpScreen(
              verificationId: verificationId,
            ));
      },

      //3. Mã verificationId của firebase thay đổi khi chờ quá thời gian
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId.value = verificationId;
      },

      //4. Khi xác thực số điện thoại không thành công
      verificationFailed: (FirebaseAuthException exception) {
        if (exception.code == 'invalid-phone-number') {
          // Số điện thoại không đúng cấu trúc: mã quốc gia + số điện thoại
          print('The provided phone number is not valid');
          Get.snackbar("Error", "The provided phone number is not valid");
        } else {
          // Thông báo lỗi khác (ví dụ như thiết bị máy ảo không phải Pixel không dùng được)
          print('Somethings went wrong. Please try again');
          Get.snackbar("Error", "Somethings went wrong. Please try again.");
        }
      },
    );
  }

  //4.2 Xác thực mã OTP: Là dạng phản hồi của điện thoại trả về firebase (Người dùng lấy mã OTP đã nhận được và nhập phản hồi lại)
  // Nhập mã OTP đúng/sai: tạo trả về true/false
  Future<bool> verifyOTP(String verificationId, String textOtp) async {
    try {
      // Tạo đối tượng dùng để xác thực: truyền verificationId của firebase, mã OTP (đã gửi về số điện thoại và người dùng gõ vào)
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: textOtp,
      );

      // Thực hiện xác thực bằng cách đăng nhập vào firebase với 2 dữ liệu
      // (mã trong firebase và mã OTP đã gửi về | gần giống dạng id và mật khẩu)
      UserCredential credential = await firebaseAuth.signInWithCredential(phoneAuthCredential);

      // Nếu đăng nhập thành công -> có user -> true và ngược lại
      return credential.user != null ? true : false;

      // (Lưu) phương thức thực hiện hành động sau khi xác thực thành công
      // FirebaseAuth.instance.signInWithCredential(credential).then((value) {
//       Get.toNamed('/login');
//     });
    } catch (exception) {
      print(exception.toString());
      Get.snackbar("Error", exception.toString()); // Hiện thông báo lỗi khi nhập sai OTP hoặc không đăng nhập (xác thực) được
    }

    // Trả về false nếu xác thực không được
    return false;
  }
}

/// Cấu trúc của UserCredential:

// UserCredential(
//  additionalUserInfo: AdditionalUserInfo(isNewUser: true, profile: {}, providerId: null, username: null, authorizationCode: null),
//  credential: null,
//  user: User(displayName: null, email: abcd@gmail.com, isEmailVerified: false, isAnonymous: false, metadata: UserMetadata(creationTime: 2024-08-05 07:30:24.122Z, lastSignInTime: 2024-08-05 07:30:24.122Z),
//  phoneNumber: null,
//  photoURL: null, providerData, [UserInfo(displayName: null, email: abcd@gmail.com, phoneNumber: null, photoURL: null, providerId: password, uid: abcd@gmail.com)],
//  refreshToken: null,
//  tenantId: null,
//  uid: 3drVxXeRq8VAZ86kfjItIpFM0Tl2)
// )
//
//  */
