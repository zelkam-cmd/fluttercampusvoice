import 'package:flutter_test/flutter_test.dart';
import 'package:campusvoice_mobile/main.dart';

void main() {
  testWidgets('App renders LoginScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusVoiceApp());
    expect(find.text('CampusVoice'), findsWidgets);
  });
}
