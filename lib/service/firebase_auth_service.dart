// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
//
// import 'otp_screen.dart';
//
// // Tao class chua cac ham su dung Firebase
//
// class MyFirebaseAuthService {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   //1. Create account (User by UserCredential)
//   Future<User?> signUpWithEmailAndPassword(String email, String password) async {
//     try {
//       // Method by Firebase auth
//       UserCredential credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
//       return credential.user;
//     } catch (signUpError) {
//       // Print Error
//       print('Sign Up Error:: ${signUpError.toString()}');
//
//       // Thong bao khi email da ton tai | Notify when email exists
//       if (signUpError.toString().contains("email-already-in-use")) {
//         Get.snackbar("Notify", "Email already in use!", backgroundColor: Colors.green[300]);
//       }
//     }
//
//     return null;
//   }
//
//   //2. Sign In account
//   Future<User?> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       // if email password on firebase -> return user
//       // UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password,);
//       UserCredential credential = await auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return credential.user;
//     } catch (e) {
//       print('Sign In Error:: ${e.toString()}');
//
//       // Thong bao neu email chua dang ky
//       if (e.toString().contains('invalid-credential')) {
//         Get.snackbar("Notify", "Email not register 2!",
//             backgroundColor: Colors.green[300],
//             titleText: const Text(
//               "Notify",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//             ),
//             messageText: const Text(
//               "Email is not register!",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
//             ));
//       }
//     }
//
//     return null;
//   }
//
//   //3. Sign out
//   Future<void> signOut() async {
//     try {
//       await auth.signOut();
//     } catch (e) {
//       print('Sign Out Error: ${e.toString()}');
//     }
//   }
//
//   //4. Xác thực số điện thoại
//   Future<void> phoneAuthentication(String textPhoneNumber) async {
//     await auth.verifyPhoneNumber(
//       phoneNumber: textPhoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         Get.snackbar("Notify", 'Confirm Phone Number Success!', backgroundColor: Colors.purpleAccent);
//         await auth.signInWithCredential(credential); // Đăng nhập firebase sau khi xác thực
//       },
//       verificationFailed: (FirebaseAuthException exception) {},
//       codeSent: (String verificationId, int? resendToken) {
//         // Cập nhật verificationId cho GetxController
//
//         // Chuyen huong khi co ma xac thuc
//         Get.to(() => OtpScreen(
//               verificationId: verificationId,
//             ));
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {},
//     );
//   }
// }
//
// /*
//
// Cau truc cua UserCredential:
//
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
