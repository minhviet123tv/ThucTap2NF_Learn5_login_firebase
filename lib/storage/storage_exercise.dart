import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo đã khởi tạo (cho firebase và cả Bindings)

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StorageExercise());
}

class StorageExercise extends StatelessWidget {
  const StorageExercise({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: StorageExercisePage(),
      ),
    );
  }
}

class StorageExercisePage extends StatefulWidget {
  @override
  State<StorageExercisePage> createState() => _StorageExercisePageState();
}

class _StorageExercisePageState extends State<StorageExercisePage> {
  XFile? imageFile; // Đường dẫn thông tin local của ảnh (source file của ảnh)
  UploadTask? uploadTask; // upload lên fire storage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //I. Chọn đối tượng ảnh của máy (dạng XFile), hiện ảnh nếu đã chọn
              InkWell(
                onTap: () async {
                  selectImage();
                },

                // Hiện icon mở chọn ảnh nếu chưa có file ảnh được chọn, nếu đã chọn ảnh thì hiện ảnh
                child: imageFile == null
                    ? const CircleAvatar(
                        radius: 100,
                        child: Icon(Icons.camera_alt),
                      )
                    : Image.file(
                        // Hiện ảnh cho file | path: đường dẫn (đã gán) đến máy local
                        File(imageFile!.path),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 20),

              //II. Thực hiện upload ảnh lên fire storage, hiện loading khi upload (bằng cách dùng uploadTask)
              uploadTask != null
                  ? loadingProgress()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //1. Nút upload: Thực hiện lệnh upload
                        ElevatedButton(
                          onPressed: () async {
                            // Quyền truy cập fire storage
                            // child: Tạo đường dẫn lưu ảnh trên storage cấu trúc 'folder_name/images_name'. Ở đây lấy tên sẵn ở local
                            // -> Có thể thực hiện lưu lại đường dẫn này để sử dụng lại (cho firestore)
                            // -> Tìm cách lấy ảnh, link ảnh (theo tên)
                            final rel = FirebaseStorage.instance.ref().child('images/${imageFile!.name}');
                            uploadTask = rel.putFile(File(imageFile!.path)); // upload ảnh

                            // Cập nhật cho loading
                            setState(() {});

                            // Hành động sau khi upload xong
                            final snapshot = await uploadTask!.whenComplete(() => print("uploaded!!!"));
                            final downloadUrl = await snapshot.ref.getDownloadURL();
                            print("URL: $downloadUrl");

                            // Xoá loading
                            setState(() {
                              uploadTask = null;
                              imageFile = null;
                            });

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            "Upload",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),

                        //2. Nút clear ảnh: Làm trống file ảnh
                        ElevatedButton(
                          onPressed: () {
                            imageFile = null;
                            setState(() {});
                          },
                          child: const Text("Clear"),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),

              //III. Hiện loading
              // loadingProgress(),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Hiện loading khi upload ảnh
  loadingProgress() {
    return StreamBuilder(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: progress,
                  color: Colors.green,
                  backgroundColor: Colors.grey,
                  strokeWidth: 5,
                ),
              ),
              Text('${(progress * 100).roundToDouble()}%'), // Đếm % upload
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  //1. Mở chọn ảnh để lấy thông tin file (pickImage là chọn 1 ảnh, có nhiều kiểu chọn và cách chọn lọc, click xem hàm để tìm hiểu)
  void selectImage() async {
    //1. Mở chọn ảnh từ máy local, trả về đối tượng file (XFile) sẽ chứa các thông tin
    // (Cài ios cần thêm ở Runner/Info.plist)
    final XFile? picture = await ImagePicker().pickImage(source: ImageSource.gallery); // source: Chỉ định nguồn ảnh sẽ lấy

    // Nếu đã chọn được ảnh thì cập nhật cho file ảnh toàn cục | Nếu không chọn thì
    if (picture != null) {
      imageFile = picture; // Nếu có chọn ảnh: Gán XFile chứa đường dẫn path của ảnh, name tên ảnh
      setState(() {}); // Cập nhật cho image
    }
  }
}
