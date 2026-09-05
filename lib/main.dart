import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/math_engine_service.dart';
import 'data/services/number_theory_service.dart';
import 'domain/repositories/i_calculator_engine.dart';
import 'presentation/providers/calculator_provider.dart';
import 'presentation/screens/calculator_3d_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SumadoraChavaApp());
}

class SumadoraChavaApp extends StatelessWidget {
  final ICalculatorEngine? engine;

  const SumadoraChavaApp({super.key, this.engine});

  @override
  Widget build(BuildContext context) {
    final effectiveEngine = engine ?? MathEngineService(
      numberTheoryService: NumberTheoryService(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CalculatorProvider>(
          create: (_) => CalculatorProvider(engine: effectiveEngine),
        ),
      ],
      child: MaterialApp(
        title: 'Sumadora Chava 3D',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Calculator3DScreen(),
      ),
    );
  }
}
