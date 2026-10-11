import 'package:flutter_test/flutter_test.dart';
import 'package:finals/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ReUseHubApp());
  });
}