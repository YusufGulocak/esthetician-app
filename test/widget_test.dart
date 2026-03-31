import 'package:flutter_test/flutter_test.dart';
import 'package:dilan_beauty_app/main.dart';

void main() {
  testWidgets('Splash screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const DilanBeautyApp());
    expect(find.text('DILAN'), findsOneWidget);
  });
}