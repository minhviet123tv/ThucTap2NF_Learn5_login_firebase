// Cài CLI và SDK (Có thể xem trên console google firebase)
//
// 1.
// npm install -g firebase-tools
//
// 2.
// firebase login
// fix: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
//
// 3.
// dart pub global activate flutterfire_cli
//
// 4. (Theo trang console, có đuôi tên dự án)
//
// flutterfire configure
//
// 5. Cài package: firebase_core và firebase_analytics
// flutter pub add firebase_core
// flutter pub add firebase_analytics
//
// 6. Main app:
//
// WidgetsFlutterBinding.ensureInitialized();
//
// await Firebase.initializeApp(
// options: DefaultFirebaseOptions.currentPlatform,
// );
