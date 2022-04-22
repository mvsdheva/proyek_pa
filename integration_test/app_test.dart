import 'package:flutter/material.dart';
import 'package:herbal/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'home_user/bottom_nav_bar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  ButtonNavBarUser buttonNavBarUser;

  group('end-to-end-test', () {
    testWidgets('testSetting', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 2));

      buttonNavBarUser = ButtonNavBarUser(tester);

      await buttonNavBarUser.clickNavigationsetting();
      // expect(
      //     find.byWidgetPredicate((widget) =>
      //         widget is AppBar &&
      //         widget.title is Text &&
      //         (widget as Text).data == 'Setelan'),
      //     findsOneWidget);
    });
  });
}
