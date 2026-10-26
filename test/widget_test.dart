import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/main.dart';
import 'package:job_connect/screens/login_screen.dart';

void main() {
  testWidgets('app starts on the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const JobConnectApp());

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}