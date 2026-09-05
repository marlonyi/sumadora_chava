import 'package:flutter_test/flutter_test.dart';
import 'package:sumadora_chava/data/services/math_engine_service.dart';
import 'package:sumadora_chava/data/services/number_theory_service.dart';

void main() {
  late MathEngineService mathEngine;
  late NumberTheoryService numberTheory;

  setUp(() {
    numberTheory = NumberTheoryService();
    mathEngine = MathEngineService(numberTheoryService: numberTheory);
  });

  group('Operaciones Requeridas: Suma, Resta, Mult, Div, Residuo, Potencia', () {
    test('1. Sumar (n1 + n2)', () {
      expect(mathEngine.evaluate('17 + 5'), '22');
      expect(mathEngine.evaluate('100 + 250'), '350');
      expect(mathEngine.evaluate('-10 + 30'), '20');
      expect(mathEngine.evaluate('3.5 + 4.5'), '8');
    });

    test('2. Restar (n1 - n2)', () {
      expect(mathEngine.evaluate('20 - 7'), '13');
      expect(mathEngine.evaluate('50 - 80'), '-30');
      expect(mathEngine.evaluate('10.5 - 2.5'), '8');
    });

    test('3. Multiplicar (n1 * n2 y n1 × n2)', () {
      expect(mathEngine.evaluate('7 * 8'), '56');
      expect(mathEngine.evaluate('12 × 12'), '144');
      expect(mathEngine.evaluate('-5 * 6'), '-30');
    });

    test('4. Dividir (n1 / n2 y n1 ÷ n2)', () {
      expect(mathEngine.evaluate('50 / 2'), '25');
      expect(mathEngine.evaluate('100 ÷ 4'), '25');
      expect(mathEngine.evaluate('7 / 2'), '3.5');
      expect(mathEngine.evaluate('10 / 0'), 'Error: División por cero');
    });

    test('5. Residuo de la división (n1 % n2)', () {
      expect(mathEngine.evaluate('17 % 5'), '2');
      expect(mathEngine.evaluate('20 % 6'), '2');
      expect(mathEngine.evaluate('100 % 10'), '0');
      expect(mathEngine.evaluate('9 % 4'), '1');
      expect(mathEngine.evaluate('15 % 0'), 'Error: División por cero');
    });

    test('6. Potencia (n1 ^ n2)', () {
      expect(mathEngine.evaluate('2 ^ 8'), '256');
      expect(mathEngine.evaluate('5 ^ 3'), '125');
      expect(mathEngine.evaluate('10 ^ 4'), '10000');
      expect(mathEngine.evaluate('9 ^ 0.5'), '3');
      expect(mathEngine.evaluate('3 ^ 0'), '1');
    });
  });

  group('Primalidad de n1 y n2', () {
    test('Determina correctamente si números son primos o no', () {
      // Primos conocidos
      final (isP2, desc2) = NumberTheoryService.checkPrimality(2);
      expect(isP2, isTrue);
      expect(desc2, contains('primo'));

      final (isP3, _) = NumberTheoryService.checkPrimality(3);
      expect(isP3, isTrue);

      final (isP5, _) = NumberTheoryService.checkPrimality(5);
      expect(isP5, isTrue);

      final (isP17, _) = NumberTheoryService.checkPrimality(17);
      expect(isP17, isTrue);

      final (isP97, _) = NumberTheoryService.checkPrimality(97);
      expect(isP97, isTrue);

      // No primos conocidos
      final (isP4, desc4) = NumberTheoryService.checkPrimality(4);
      expect(isP4, isFalse);
      expect(desc4, contains('divisible'));

      final (isP9, _) = NumberTheoryService.checkPrimality(9);
      expect(isP9, isFalse);

      final (isP1, desc1) = NumberTheoryService.checkPrimality(1);
      expect(isP1, isFalse);

      final (isP0, _) = NumberTheoryService.checkPrimality(0);
      expect(isP0, isFalse);

      final (isPNeg, _) = NumberTheoryService.checkPrimality(-7);
      expect(isPNeg, isFalse);
    });

    test('checkDoublePrimality valida enteros, decimales y casos límite', () {
      final (isP17, _) = NumberTheoryService.checkDoublePrimality(17.0);
      expect(isP17, isTrue);

      final (isP4, _) = NumberTheoryService.checkDoublePrimality(4.0);
      expect(isP4, isFalse);

      final (isPDec, descDec) = NumberTheoryService.checkDoublePrimality(3.14);
      expect(isPDec, isFalse);
      expect(descDec, contains('decimales'));
    });

    test('analyzeExpression extrae n1, n2 y determina primalidad para ambos', () {
      // Suma entre 17 (primo) y 5 (primo)
      final analysisSuma = mathEngine.analyzeExpression('17 + 5', 22.0);
      expect(analysisSuma.hasOperands, isTrue);
      expect(analysisSuma.n1, 17.0);
      expect(analysisSuma.n1IsPrime, isTrue);
      expect(analysisSuma.n2, 5.0);
      expect(analysisSuma.n2IsPrime, isTrue);
      expect(analysisSuma.operationName, 'Suma');
      expect(analysisSuma.value, 22.0);
      expect(analysisSuma.isPrime, isFalse); // 22 no es primo

      // Residuo entre 19 (primo) y 4 (no primo)
      final analysisResiduo = mathEngine.analyzeExpression('19 % 4', 3.0);
      expect(analysisResiduo.hasOperands, isTrue);
      expect(analysisResiduo.n1, 19.0);
      expect(analysisResiduo.n1IsPrime, isTrue);
      expect(analysisResiduo.n2, 4.0);
      expect(analysisResiduo.n2IsPrime, isFalse);
      expect(analysisResiduo.operationName, 'Residuo');
      expect(analysisResiduo.value, 3.0);
      expect(analysisResiduo.isPrime, isTrue); // 3 es primo

      // Potencia entre 2 (primo) y 8 (no primo)
      final analysisPotencia = mathEngine.analyzeExpression('2 ^ 8', 256.0);
      expect(analysisPotencia.hasOperands, isTrue);
      expect(analysisPotencia.n1, 2.0);
      expect(analysisPotencia.n1IsPrime, isTrue);
      expect(analysisPotencia.n2, 8.0);
      expect(analysisPotencia.n2IsPrime, isFalse);
      expect(analysisPotencia.operationName, 'Potencia');
      expect(analysisPotencia.value, 256.0);

      // Multiplicación entre 6 (no primo) y 9 (no primo)
      final analysisMult = mathEngine.analyzeExpression('6 * 9', 54.0);
      expect(analysisMult.hasOperands, isTrue);
      expect(analysisMult.n1, 6.0);
      expect(analysisMult.n1IsPrime, isFalse);
      expect(analysisMult.n2, 9.0);
      expect(analysisMult.n2IsPrime, isFalse);
      expect(analysisMult.operationName, 'Multiplicación');
    });
  });
}
