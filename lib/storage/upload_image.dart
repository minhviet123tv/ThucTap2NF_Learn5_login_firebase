import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../firebase_options.dart';

// main
void main() async {
  // Đảm bảo đã khởi tạo (cho firebase và Bindings)
  WidgetsFlutterBinding.ensureInitialized();

  // Tạo firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UploadImage());
}

// home
class UploadImage extends StatelessWidget {
  const UploadImage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SafeArea(child: UploadImagePage()),
    );
  }
}

// page: Nếu dùng Getx thì không cần dùng stateful
class UploadImagePage extends StatefulWidget {
  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  XFile? imageFile; // Chứa thông tin file sẽ sử dụng (name, path)
  UploadTask? uploadTask; // Dữ liệu upload file (các thể hiện trước, trong và sau khi upload file)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload image to Firebase storage",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // cách 2 bên lề màn hình
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 10),

                //1. Hiện ảnh thường khi không upload, khi upload hiện loading (gộp 2 trong 1)
                customAvatarAndProgress(),
                const SizedBox(height: 10),

                //2. Các nút chọn ảnh, xoá và upload
                rowButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //I.1 Image Avatar: Hiện ảnh được chọn, nếu chưa có thì hiện icon hoặc tạo ảnh mặc định.
  // Khi upload thì hiện thông tin upload.
  customAvatarAndProgress() {
    // Dùng ElevatedButton tạo thành ảnh dạng nút có viền của nút bao ngoài, có hiệu ứng khi click
    return ElevatedButton(
      onPressed: () {
        selectImage();
      },
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(6)), // Cách ra tạo thành viền bao ngoài cho phần child
      child: Stack(
        alignment: Alignment.center,
        children: [
          //2. Hiện khi upload: CircularProgressIndicator với kích thước của SizedBox (Mục đích mở rộng kích thước bằng ảnh)
          if (uploadTask != null)
            StreamBuilder(
              stream: uploadTask?.snapshotEvents,
              builder: (context, snapshotUploadImage) {
                if (snapshotUploadImage.hasData) {
                  // Chỉ số loading: bytes đã chuyển * 100 / tổng bytes
                  double progressLoading = snapshotUploadImage.data!.bytesTransferred * 100 / snapshotUploadImage.data!.totalBytes;
                  return SizedBox(
                    height: 225, // Bằng đường kính của ảnh
                    width: 225,
                    child: CircularProgressIndicator(
                      value: progressLoading, // Hình ảnh tiến độ % upload theo chỉ số (cập nhật theo giá trị thực vì nằm trong stream)
                      color: Colors.green,
                      backgroundColor: Colors.grey,
                      strokeWidth: 12, // chiều dày vòng loading (mở ra bên ngoài SizedBox, căn bằng 2*padding của ElevatedButton)
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),

          //1. Hiện ảnh đang được chọn (sẽ hiện chồng lên CircularProgressIndicator khi loading) | Nếu chưa có ảnh thì hiện icon
          ClipOval(
            child: imageFile != null
                ? Image.file(
                    File(imageFile!.path), // Hiện ảnh dạng dùng file do dùng XFile (lưu tạm tại app) khi có ảnh được chọn
                    width: 225, // Kích thước đường kính
                    height: 225,
                    fit: BoxFit.cover,
                  )
                : const CircleAvatar(
                    radius: 112.5, // Bán kính = 225/2
                    child: Icon(Icons.image), // Tạo hiện kiểu icon khi không có ảnh (Căn chỉnh bằng kích thước)
                  ),
          ),

          //3. Text hiện chỉ số % đang load: Sẽ hiện chồng lên ảnh khi loading (đặt trên cùng)
          if (uploadTask != null)
            StreamBuilder(
              stream: uploadTask?.snapshotEvents,
              builder: (context, snapshotUploadImage) {
                if (snapshotUploadImage.hasData) {
                  double progressLoading = snapshotUploadImage.data!.bytesTransferred * 100 / snapshotUploadImage.data!.totalBytes;
                  return Text(
                    "${progressLoading.roundToDouble()}%", // Làm tròn
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          // Hiện text giá trị loading
        ],
      ),
    );
  }

  //I.2 Mở ảnh của máy và chọn ảnh
  void selectImage() async {
    //1. Mở chọn ảnh và trả ảnh được chọn thành XFile (lưu tạm thời ảnh vào app khi được chọn)
    final XFile? pickFileImage = await ImagePicker().pickImage(source: ImageSource.gallery); // source: Chỉ định nguồn ảnh sẽ lấy

    //2. Xử lý sau khi chọn ảnh: cập nhật cho file ảnh toàn cục
    if (pickFileImage != null) {
      imageFile = pickFileImage;

      // Cập nhật hiển thị cho image
      setState(() {
        uploadFileToStorage(); // Upload luôn sau khi chọn ảnh xong
      });
    }
  }

  //II.1 Hàng chứa các nút: Select, Select, Upload
  rowButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //1. Nút bấm mở để chọn ảnh
        ElevatedButton(
          onPressed: () {
            selectImage();
          },
          child: const Text("Select"),
        ),

        //2. Nút xoá ảnh
        ElevatedButton(
          onPressed: () {
            imageFile = null; // Chuyển file ảnh thành null
            uploadTask = null;
            setState(() {});
          },
          child: const Text("Clear"),
        ),

        //3. Nút upload ảnh lên fire storage
        ElevatedButton(
          onPressed: () {
            uploadFileToStorage(); // Thực hiện upload
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text("Upload", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  //II.2 Thực hiện upload 1 file (logic)
  // Sau này lấy lại ở firestore có thể kiểm tra có tồn tại key chứa ảnh của Map bằng: docs[index].containsKey("key_image)
  void uploadFileToStorage() async {
    // Chỉ upload khi có ảnh
    if (imageFile != null) {
      try {
        //1. Chuẩn bị sẵn: Cấp quyền trên fire storage và nơi lưu + tên ảnh trên firestore
        // Dùng child() hoặc "/" để chỉ rõ đường dẫn
        // => Tên ảnh này sẽ luôn cố định trên firestore nếu như được đặt tên cụ thể. VD: 'images/${currentUser?.uid}_avatar'
        // Dù chọn ảnh khác để upload và thì tên đó thì vẫn không thay đổi mà chỉ thay đổi ảnh (giữ nguyên địa chỉ)
        Reference reference = FirebaseStorage.instance.ref().child("images/${imageFile!.name}"); // Đặt tên theo file thì lưu theo file

        // Xoá ảnh
        // FirebaseStorage.instance.ref().child("images/${imageFile!.name}").delete()

        // Có thể tạo tên bằng milisecond hoặc microsecond từ mốc đếm chung thời gian của thế giới
        // String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

        //2. Thực hiện upload: put file được upload (chính là file ảnh đã lấy, điền path cho File)
        uploadTask = reference.putFile(File(imageFile!.path)); // Có thể put nhiều kiểu khác như: Blob, String, data

        setState(() {}); // Cập nhật cho loading và show progress vì đã có uploadTask != null

        //3. Hành động sau khi upload (loading progress xong) nếu cần | Xoá whenComplete nếu không cần
        TaskSnapshot taskSnapshot = await uploadTask!.whenComplete(() => print("Uploaded success!"));

        //4. Lấy URL sau khi load xong (Có thể lưu firestore để làm đường dẫn hoặc lấy theo tên cố định | Cần cập nhật cách lấy ảnh)
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print("URL\n: $downloadUrl");

        //5. Xoá uploadTask sau khi load xong (Có thể để lại ảnh imageFile hoặc xoá tuỳ nhu cầu)
        setState(() {
          uploadTask = null;
          // imageFile = null;
        });

        //6. Thông báo đã upload xong
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload success!")));

      } catch (ex){print(ex);}
    } else {
      // Thông báo nếu chưa có ảnh
      Get.snackbar("Notify", "Please select image!", backgroundColor: Colors.grey[300]);
    }
  }
}
