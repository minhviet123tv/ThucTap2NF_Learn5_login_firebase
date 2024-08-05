import 'package:firebase_auth/firebase_auth.dart';

// Tao class chua cac ham su dung Firebase

class MyFirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //1. Create account (User by UserCredential)
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Method by Firebase auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print('Sign Up Error:: ${e.toString()}');
    }

    return null;
  }

  //2. Sign In account
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // if email password on firebase -> return user
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      print('Sign In Error:: ${e.toString()}');
    }

    return null;
  }

  //2. Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: ${e.toString()}');
    }
  }
}

/*

Cau truc cua UserCredential:

UserCredential(
 additionalUserInfo: AdditionalUserInfo(isNewUser: true, profile: {}, providerId: null, username: null, authorizationCode: null),
 credential: null,
 user: User(displayName: null, email: abcd@gmail.com, isEmailVerified: false, isAnonymous: false, metadata: UserMetadata(creationTime: 2024-08-05 07:30:24.122Z, lastSignInTime: 2024-08-05 07:30:24.122Z),
 phoneNumber: null,
 photoURL: null, providerData, [UserInfo(displayName: null, email: abcd@gmail.com, phoneNumber: null, photoURL: null, providerId: password, uid: abcd@gmail.com)],
 refreshToken: null,
 tenantId: null,
 uid: 3drVxXeRq8VAZ86kfjItIpFM0Tl2)
)

 */
