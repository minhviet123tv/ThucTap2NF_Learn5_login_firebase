import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayMessage extends StatelessWidget {
  String email;

  DisplayMessage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    // Truy vấn danh sách dữ liệu của bảng 'message' trên Firestore (danh sách dữ liệu theo id)
    // final Stream<QuerySnapshot> _message = FirebaseFirestore.instance.collection("message").orderBy('time').snapshots();
    final Stream<QuerySnapshot> _message = FirebaseFirestore.instance.collection("chatroom").orderBy('time').snapshots();

    return StreamBuilder(
      stream: _message,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Somethings went wrong"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length, // List bởi docs của bảng 'message' trên Cloud FireStore
          itemBuilder: (context, index) {
            QueryDocumentSnapshot query = snapshot.data!.docs[index]; // dữ liệu của 1 tin nhắn (message)
            Timestamp time = query['time']; // Đổi định đạng time
            DateTime dateTime = time.toDate();
            return Column(
              crossAxisAlignment: email == query['email'] ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 300,
                  child: ListTile(
                    title: Text(query['email']), // Nội dung 'email' trong truy vấn
                    subtitle: SizedBox(
                      width: 200,
                      child: Text(
                        "${query['message']}",
                        softWrap: true,
                        textAlign: TextAlign.left,
                      ), // Tự xuống dòng
                    ),
                    trailing: Text("${dateTime.hour}:${dateTime.minute}"),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.purpleAccent,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ), // Thời gian nhắn tin
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
