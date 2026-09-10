import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:configurator/main.dart';

void main() {
  testWidgets('shows the get started screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ConfiguratorApp());
    await tester.pump();

    expect(find.text('Configurator'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
