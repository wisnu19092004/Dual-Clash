import 'package:flutter_test/flutter_test.dart';
import 'package:game_papan/main.dart';

void main() {
  testWidgets('App initializes smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BoardMasterApp());
    expect(find.text('DUAL CLASH'), findsOneWidget);
  });
}
