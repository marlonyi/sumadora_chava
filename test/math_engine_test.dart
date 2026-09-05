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

  group('MathEngineService - Arithmetic & Precedence', () {
    test('Evaluates basic addition, subtraction, multiplication, and division', () {
      expect(mathEngine.evaluate('2 + 3 * 4'), '14');
      expect(mathEngine.evaluate('(2 + 3) * 4'), '20');
      expect(mathEngine.evaluate('100 / 4 - 5'), '20');
      expect(mathEngine.evaluate('2 ^ 3 + 1'), '9');
    });

    test('Prevents division by zero safely', () {
      expect(mathEngine.evaluate('10 / 0'), 'Error: División por cero');
      expect(mathEngine.evaluate('5 % 0'), 'Error: División por cero');
    });

    test('Evaluates unary functions (sqrt, sin, cos, ln, log, x^2)', () {
      expect(mathEngine.evaluate('sqrt(16)'), '4');
      expect(mathEngine.evaluate('sin(0)'), '0');
      expect(mathEngine.evaluate('cos(0)'), '1');
      expect(mathEngine.evaluate('ln(1)'), '0');
      expect(mathEngine.evaluate('log(100)'), '2');
    });

    test('Evaluates negative numbers and powers', () {
      expect(mathEngine.evaluate('-5 + 10'), '5');
      expect(mathEngine.evaluate('3 ^ 2'), '9');
    });
  });

  group('NumberTheoryService - Primality, Divisors, Base Conversions & Factorial', () {
    test('Primality check O(sqrt(n))', () {
      final (isPrime2, _) = NumberTheoryService.checkPrimality(2);
      expect(isPrime2, isTrue);

      final (isPrime17, _) = NumberTheoryService.checkPrimality(17);
      expect(isPrime17, isTrue);

      final (isPrime4, _) = NumberTheoryService.checkPrimality(4);
      expect(isPrime4, isFalse);

      final (isPrime1, _) = NumberTheoryService.checkPrimality(1);
      expect(isPrime1, isFalse);

      final (isPrime997, _) = NumberTheoryService.checkPrimality(997);
      expect(isPrime997, isTrue);
    });

    test('Exact divisors generation', () {
      expect(NumberTheoryService.getDivisors(12), [1, 2, 3, 4, 6, 12]);
      expect(NumberTheoryService.getDivisors(7), [1, 7]);
      expect(NumberTheoryService.getDivisors(28), [1, 2, 4, 7, 14, 28]);
    });

    test('Positional base conversions (Binary & Hexadecimal)', () {
      expect(NumberTheoryService.toBinary(10), '0b1010');
      expect(NumberTheoryService.toBinary(255), '0b11111111');
      expect(NumberTheoryService.toHexadecimal(255), '0xFF');
      expect(NumberTheoryService.toHexadecimal(16), '0x10');
    });

    test('Exact factorial up to n <= 18', () {
      expect(NumberTheoryService.calculateFactorial(0), '1');
      expect(NumberTheoryService.calculateFactorial(1), '1');
      expect(NumberTheoryService.calculateFactorial(5), '120');
      expect(NumberTheoryService.calculateFactorial(10), '3,628,800');
    });

    test('Prime factorization and tree generation', () {
      final factors = NumberTheoryService.getPrimeFactorization(60);
      expect(factors.map((f) => f.toString()).join(' × '), '2^2 × 3 × 5');

      final tree = NumberTheoryService.buildPrimeFactorTree(60);
      expect(tree, isNotNull);
      expect(tree!.value, 60);
      expect(tree.isPrime, isFalse);
    });

    test('Full NumberAnalysis entity creation', () {
      final analysis = numberTheory.analyze(28);
      expect(analysis.isInteger, isTrue);
      expect(analysis.parity, 'Par');
      expect(analysis.isPrime, isFalse);
      expect(analysis.divisors, [1, 2, 4, 7, 14, 28]);
      expect(analysis.primeFactorizationFormatted, '2^2 × 7');
      expect(analysis.binary, '0b11100');
      expect(analysis.hexadecimal, '0x1C');
    });
  });
}
