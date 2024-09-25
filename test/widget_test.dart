// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fire_base_app_chat/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

    // Lấy phần tử cuối của list và top 10 phần tử cuối
    List<int> listNumber = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19];
    int lastNumber = listNumber.last;

    List<int> last10Number = [];
    if(listNumber.length > 10){
      for(int i=listNumber.length - 10; i < listNumber.length; i++){
        last10Number.add(listNumber[i]);
      }
    }

    print("$lastNumber\n");
    last10Number.forEach((element)=> print(element));

    // Build our app and trigger a frame.
    // await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);
    //
    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    //
    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
