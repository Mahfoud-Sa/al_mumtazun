// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:engineering_ops_dashboard/app.dart';
import 'package:engineering_ops_dashboard/di/service_locator.dart';
import 'package:engineering_ops_dashboard/localization/locale_cubit.dart';

void main() {
  testWidgets('App boots to dashboard', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await configureDependencies();
    await getIt<LocaleCubit>().setLocale(const Locale('en'));

    await tester.pumpWidget(
      const EngineeringOpsApp(),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Dashboard Insights'), findsOneWidget);
  });
}
