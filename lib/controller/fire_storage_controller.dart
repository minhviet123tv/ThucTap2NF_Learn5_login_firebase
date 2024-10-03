import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FireStorageController extends GetxController {
  //I. Dữ liệu chung
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Cloud Firestore database
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Firebase | Không thể tạo sẵn currentUser

  XFile? imageFile; // Ảnh avatar
  UploadTask? uploadTask; // Xử lý upload file

  //I.1 Mở ảnh của máy và chọn ảnh
  void selectImageAndUpload() async {
    //1. Mở chọn ảnh và trả ảnh được chọn thành XFile (lưu tạm thời ảnh vào app khi được chọn)
    final XFile? pickFileImage = await ImagePicker().pickImage(source: ImageSource.gallery); // source: Chỉ định nguồn ảnh sẽ lấy

    //2. Xử lý sau khi chọn ảnh: cập nhật cho file ảnh và upload lên fire storage
    if (pickFileImage != null) {
      imageFile = pickFileImage;
      uploadFileToStorage(); // Upload luôn sau khi chọn ảnh xong
    }
  }

  //I.2 Thực hiện upload 1 file
  void uploadFileToStorage() async {
    // Chỉ upload khi có ảnh, nếu không có ảnh thì không có hành động gì
    if (imageFile != null) {
      try {
        //1. Cấp quyền trên và nơi lưu + tên ảnh vào fire storage (đặt theo uid của mỗi user) | Nếu muốn xoá thì thêm đuôi .delete()
        Reference reference = FirebaseStorage.instance.ref().child("avatar/${firebaseAuth.currentUser?.uid}");

        //2. Thực hiện upload: put file được upload (chính là path của file ảnh đã lấy)
        uploadTask = reference.putFile(File(imageFile!.path));
        update(); // Cập nhật để hiện loading vì đã có uploadTask != null

        //3. Hành động sau khi upload (loading progress xong): await uploadTask!.whenComplete(() => print("Uploaded success!"))
        TaskSnapshot taskSnapshot = await uploadTask!;

        //4.1 Lấy URL sau khi load xong
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        //4.2 Update cho firestore của user (dùng update mà không phải set vì chắc chắn đã được thêm khi vào trang)
        firestore.collection('users').doc(firebaseAuth.currentUser?.uid).update({
          'avatar_url': downloadUrl,
        });

        //5. Xoá uploadTask sau khi load xong
        uploadTask = null;
        imageFile = null;

        //6. Cập nhật sau khi hoàn thành upload ảnh
        update();

      } catch (ex) {
        print(ex);
      }
    }
  }
}