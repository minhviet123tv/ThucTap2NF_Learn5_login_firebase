import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_base_app_chat/home/profile_user/view_one_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FireStorageController extends GetxController {
  //I. Dữ liệu chung
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Cloud Firestore database
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; // Firebase | Không thể tạo sẵn currentUser

  XFile? imageFile; // Ảnh avatar
  UploadTask? uploadTask; // Xử lý upload file
  PageStorageState pageStorageState = PageStorageState.none; // Trạng thái chọn textfield của trang profile

  void loadStoragePageState(PageStorageState pageStorageState){
    this.pageStorageState = pageStorageState;
    update();
  }

  //Tạo list url ảnh để dùng ngẫu nhiên (đã phải lưu trên firestore)
  List<String> listUrlAvatar = [
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_1.jpg?alt=media&token=705bdfc3-f499-4e51-bf52-e375ffeb6aee",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_2.jpg?alt=media&token=a8cfbe7b-8db2-4d10-a15c-875eca767bb7",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_3.jpg?alt=media&token=1bb9948f-b5e4-4bc1-bf42-091743079f44",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_4.jpg?alt=media&token=576b9a39-a218-4761-bbdb-7cc3fcc55f02",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_5.jpg?alt=media&token=80551048-b75a-4d25-a507-45ee1b77d441",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_6.jpg?alt=media&token=9264972f-7542-4a1e-a241-a3fcc078cc3e",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_7.jpg?alt=media&token=1c55c530-8c10-4ad1-ba94-e2525f53aa91",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_8.jpg?alt=media&token=aea41a90-3188-45c4-a43f-45218b8c9a9a",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_9.jpg?alt=media&token=0c851ea7-a6d8-4d12-8901-0e3b23fca930",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_10.jpg?alt=media&token=6700c0d9-31f3-491e-9460-e3652c53365d",

    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_11.jpg?alt=media&token=1f3dfb25-865c-4d6d-beb1-d1da85e02086",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_12.jpg?alt=media&token=bbbe1c4a-b373-4f08-94bf-9e22dbe0c5d9",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_13.jpg?alt=media&token=ceeabb47-e8be-41cf-8ea8-41ce814da6de",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_14.jpg?alt=media&token=b2cc623d-9b5d-4887-b542-8866c02e2bf0",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_15.jpg?alt=media&token=f3542b80-1cdf-4144-86d1-9a034441147e",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_16.jpg?alt=media&token=db43bda5-563b-4e0a-8788-148d071e967b",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_17.jpg?alt=media&token=fc25f6fb-c5d9-446a-be39-57f88308e467",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_18.jpg?alt=media&token=793c4da7-be15-4c19-ae57-6a3dacfad6af",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_19.jpg?alt=media&token=a86baf15-bfc3-4dc3-b3d3-5a397b4484b5",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_20.jpg?alt=media&token=7d12a169-3350-4602-9cfa-4c7ba14b2812",

    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_21.jpg?alt=media&token=08318a1a-e0d5-415a-8c49-5a345e701c48",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_22.jpg?alt=media&token=e557c5de-5769-409e-a838-04ad3d694cec",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_23.jpg?alt=media&token=d124b845-ab98-4184-90e5-2a47e1c49490",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_24.jpg?alt=media&token=e0095fbc-906f-4d8a-99a0-b85113628965",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_25.jpg?alt=media&token=6b0f9818-0393-4419-9a1f-5e611a6e26d8",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_26.jpg?alt=media&token=65a6696d-d958-427d-90ef-1415167e0be8",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_27.jpg?alt=media&token=1951de56-0d13-4a8a-9c03-ec9035165cce",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_28.jpg?alt=media&token=122ac8bc-7bcd-490e-bf4a-97c199d8cbee",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_29.jpg?alt=media&token=816ce897-a056-4369-adff-8b9f4ca7eb71",
    "https://firebasestorage.googleapis.com/v0/b/authenticationapp-98add.appspot.com/o/avatar%2Favatar_default_30.jpg?alt=media&token=3c45889f-9334-4349-aafb-1f6f19fb3718",
  ];

  //I. Mở ảnh của máy và chọn ảnh
  void selectImageAndUpload() async {
    //1. Mở chọn ảnh và trả ảnh được chọn thành XFile (lưu tạm thời ảnh vào app khi được chọn)
    final XFile? pickFileImage = await ImagePicker().pickImage(source: ImageSource.gallery); // source: Chỉ định nguồn ảnh sẽ lấy

    //2. Xử lý sau khi chọn ảnh: cập nhật cho file ảnh và upload lên fire storage
    if (pickFileImage != null) {
      imageFile = pickFileImage;
      uploadFileToStorage(); // Upload luôn sau khi chọn ảnh xong
    }
  }

  //II. Thực hiện upload 1 file
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

  //III. (Lưu) Check xem đã có key 'avatar_url' chưa -> Thêm key nếu chưa có key trong firestore (Đã kiểm duyệt phương án này là chính xác)
  // Phải đặt lệnh get().then() ở FutureBuilder để đảm bảo đồng bộ và được thực hiện. Lưu ở đây để hiểu
  void addKeyAvatar() async {
    // Phương án này là dùng để thêm key dữ liệu sau khi kiểm tra containsKey nói chung cho các document
    await firestore.collection('users').doc(firebaseAuth.currentUser?.uid).get().then((documentSnapshot) async {
      if (documentSnapshot.exists) {
        if (documentSnapshot.data()!.containsKey('avatar_url') == false) {
          // Tạo avatar mẫu mặc định (tạo list url link storage rồi chọn ngẫu nhiên) | Random sẽ run từ 0 -> trước length
          // Phải ghi rõ lại câu lệnh để chắc chắn đúng địa chỉ | set: sử dụng merge -> Thêm nếu chưa có, nếu có thì set lại
          firestore
              .collection('users')
              .doc(firebaseAuth.currentUser?.uid)
              .set({'avatar_url': listUrlAvatar[Random().nextInt(listUrlAvatar.length)]}, SetOptions(merge: true));
        }
      }
    });
  }

  //IV. Cập nhật nội dung 'news_content'
  void updateNewsContent(String content) async {
    await firestore.collection('users').doc(firebaseAuth.currentUser?.uid).update({
      'news_content': content, // '${content[0].toUpperCase()}${content.substring(1,content.length)}'
    });

    // Chuyển trạng thái sang xem Text
    loadStoragePageState(PageStorageState.none);
  }

  //V. Xoá 'news_content' -> Đưa về empty, vẫn giữ key
  void deleteNewsContent() async {
    await firestore.collection('users').doc(firebaseAuth.currentUser?.uid).update({
      'news_content': "",
    });

    // Chuyển trạng thái sang xem Text
    loadStoragePageState(PageStorageState.none);
  }

}

enum PageStorageState {none, selectTextField}