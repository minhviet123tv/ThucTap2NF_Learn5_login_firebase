import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';

/*
Home page
 */

class HomePage extends StatelessWidget {
  // Truy vấn theo tên dữ liệu trên RealTime Database Firebase (Dạng nút của mô hình dữ liệu tree)
  final DatabaseReference dataFromRealtimeDatabase = FirebaseDatabase.instance.ref('RealTimeQuery');

  // TextField Controller
  TextEditingController textAge = TextEditingController();
  TextEditingController textCountry = TextEditingController();
  TextEditingController textName = TextEditingController();

  // Trang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(null),
        title: const Text("Home page", style: TextStyle(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.blue,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()), // FocusManager.instance.primaryFocus?.unfocus
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //I. Danh sách dữ liệu
            listDataFromRealTimeDatabase(),
            //II. Form add, update thông tin
            changeDataToRealTimeDatabase(),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // Đẩy bottom sheet lên khi có bàn phím
    );
  }

  //1. list Data From RealTime Database
  Widget listDataFromRealTimeDatabase() {
    return Expanded(
      child: FirebaseAnimatedList(
        scrollDirection: Axis.vertical, // Hướng của list | Khi dùng horizontal thì cần đặt kích thước cho item
        // Lệnh truy vấn | Sắp xếp dùng .orderByChild('name') | Truy vấn khác như: .equalTo('') .startAt(), .endAt(), ...
        query: dataFromRealtimeDatabase.orderByChild('age'),
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, snapshot, animation, index) {
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: Text(snapshot.child('id').value.toString()),
              subtitle: Column(
                children: [
                  Text(snapshot.child('name').value.toString()),
                  Text(snapshot.child('age').value.toString()),
                  Text(snapshot.child('country').value.toString()),
                ],
              ),
              trailing: PopupMenuButton(
                onOpened: () => FocusScope.of(context).requestFocus(FocusNode()),
                icon: const Icon(Icons.more_horiz),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                clipBehavior: Clip.antiAlias,
                itemBuilder: (BuildContext context) {
                  return [
                    //1. Edit dữ liệu
                    PopupMenuItem(
                      value: "updateData",
                      child: ListTile(
                        onTap: () {
                          // Lấy id của item đó lưu trong chính nó cho nút id
                          String id = snapshot.child('id').value.toString();
                          String name = textName.text.toString().trim();
                          String age = textAge.text.toString().trim();
                          String country = textCountry.text.toString().trim();


                          UserModel user = UserModel(id: id, name: name, age: age, country: country,);

                          dataFromRealtimeDatabase.child(id).update(user.toJson());

                          // Pop cửa sổ menu theo tên đã đặt
                          Navigator.pop(context, "updateData");
                        },
                        leading: const Icon(Icons.edit),
                        title: const Text("Edit"),
                      ),
                    ),

                    //2. Delete 1 item
                    PopupMenuItem(
                      value: "deleteData",
                      child: ListTile(
                        onTap: () {
                          // Lấy id của item đó lưu trong chính nó cho cột id
                          String id = snapshot.child('id').value.toString();
                          dataFromRealtimeDatabase.child(id).remove();
                          Navigator.pop(context, "deleteData"); // Pop cửa sổ menu theo tên
                        },
                        leading: const Icon(Icons.delete),
                        title: const Text("Delete"),
                      ),
                    ),
                  ];
                },
              ),
            ),
          );
        },
      ),
    );
  }

//2. Add Data To RealTime Database
  Widget changeDataToRealTimeDatabase() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10),
      child: Column(
        children: [
          TextField(
            controller: textAge,
            decoration: const InputDecoration(
              hintText: "Age",
            ),
          ),
          TextField(
            controller: textCountry,
            decoration: const InputDecoration(
              hintText: "Country",
            ),
          ),
          TextField(
            controller: textName,
            decoration: const InputDecoration(
              hintText: "Name",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final id = DateTime.now().microsecond.toString(); // Tạo id
              String age = textAge.text.toString().trim();
              String country = textCountry.text.toString().trim();
              String name = textName.text.toString().trim();

              UserModel user = UserModel(id: id, name: name, age: age, country: country);

              // Thực hiện add data bằng lệnh set: Tạo child 1 là id, bên trong id là các child 2 (Thông tin user dạng Json)
              dataFromRealtimeDatabase.child(id).set(user.toJson());

              textAge.clear(); // xoá text trên TextField
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}
