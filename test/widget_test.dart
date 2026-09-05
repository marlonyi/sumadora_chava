import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sumadora_chava/main.dart';
import 'package:sumadora_chava/presentation/screens/calculator_3d_screen.dart';

void main() {
  testWidgets('SumadoraChavaApp builds and displays 3D screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SumadoraChavaApp());
    expect(find.byType(Calculator3DScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
