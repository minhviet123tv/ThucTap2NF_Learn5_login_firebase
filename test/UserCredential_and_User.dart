/// Cấu trúc của UserCredential:

// UserCredential(
//  additionalUserInfo: AdditionalUserInfo(isNewUser: true, profile: {}, providerId: null, username: null, authorizationCode: null),
//  credential: null,
//  user:
  //  User(displayName: null, email: abcd@gmail.com, isEmailVerified: false, isAnonymous: false, metadata: UserMetadata(creationTime: 2024-08-05 07:30:24.122Z, lastSignInTime: 2024-08-05 07:30:24.122Z),
  //  phoneNumber: null,
  //  photoURL: null, providerData, [UserInfo(displayName: null, email: abcd@gmail.com, phoneNumber: null, photoURL: null, providerId: password, uid: abcd@gmail.com)],
  //  refreshToken: null,
  //  tenantId: null,
  //  uid: 3drVxXeRq8VAZ86kfjItIpFM0Tl2
  //  )
// )



// credential.user: Cấu hình thông tin của user trên firebase, chứa các thông tin như sau (Có thể lấy các thông tin này bằng FirebaseAuth.instance.currentUser?.thôngtin)
// User(
// displayName: null,
// email: null,
// isEmailVerified: false,
// isAnonymous: false,
// metadata: UserMetadata(creationTime: 2024-08-09 03:06:43.951Z, lastSignInTime: 2024-08-11 10:04:48.813Z), // Dùng firebaseAuth.currentUser?.metadata sẽ có được UserMetadata, bên trong là các tham số
// phoneNumber: +84123456789,
// photoURL: null,
// providerData,
// [UserInfo(displayName: null, email: null, phoneNumber: +84123456789, photoURL: null, providerId: phone, uid: )], // Có vẻ như chỉ là đơn thuần hiện thông tin của providerData
// refreshToken: null,
// tenantId: null,
// uid: OPZx9khBOYUSchi1pGGNcQvEhdd2
// )


// creationTime tài khoản firebase (Định dạng giờ UTC), có thể lấy milisecond, second, ...
// controller.firebaseAuth.currentUser?.metadata.creationTime?.toString() ?? "creationTime",