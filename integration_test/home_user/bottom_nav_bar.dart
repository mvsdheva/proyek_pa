import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ButtonNavBarUser{
  final WidgetTester tester;
  ButtonNavBarUser(this.tester);

  Future<void> clickNavigationsetting() async{
    final settingButtonFinder = find.byKey(Key('play_video'));

    await tester.ensureVisible(settingButtonFinder);
    await tester.tap(settingButtonFinder);

    await tester.pumpAndSettle();
  }
}