import 'prime_factor_tree.dart';

/// Pure Domain Entity representing deep mathematical analysis of a number
class NumberAnalysis {
  final double value;
  final bool isInteger;
  final int? intValue;
  final String parity; // 'Par', 'Impar', or 'No entero'
  final bool isPrime;
  final String primalityDescription;
  final List<int> divisors;
  final List<PrimeFactorExponent> primeFactorExponents;
  final PrimeFactorNode? primeFactorTree;
  final String binary;
  final String hexadecimal;
  final String factorial;
  final bool isNegative;

  // Operands n1 and n2 analysis for binary operations
  final double? n1;
  final bool? n1IsPrime;
  final String? n1PrimeDesc;
  final double? n2;
  final bool? n2IsPrime;
  final String? n2PrimeDesc;
  final String? operatorSymbol;
  final String? operationName; // Suma, Resta, Multiplicación, División, Residuo, Potencia
  final String? fullExpression;

  const NumberAnalysis({
    required this.value,
    required this.isInteger,
    this.intValue,
    required this.parity,
    required this.isPrime,
    required this.primalityDescription,
    required this.divisors,
    this.primeFactorExponents = const [],
    this.primeFactorTree,
    required this.binary,
    required this.hexadecimal,
    required this.factorial,
    required this.isNegative,
    this.n1,
    this.n1IsPrime,
    this.n1PrimeDesc,
    this.n2,
    this.n2IsPrime,
    this.n2PrimeDesc,
    this.operatorSymbol,
    this.operationName,
    this.fullExpression,
  });

  bool get hasOperands => n1 != null && n2 != null;

  String get primeFactorizationFormatted {
    if (primeFactorExponents.isEmpty) {
      if (intValue == 0 || intValue == 1) return '$intValue (Caso especial)';
      return 'N/A';
    }
    return primeFactorExponents.map((e) => e.toString()).join(' × ');
  }

  @override
  String toString() {
    return 'NumberAnalysis(val: $value, isInt: $isInteger, parity: $parity, prime: $isPrime, divisors: ${divisors.length}, factors: $primeFactorizationFormatted, bin: $binary, hex: $hexadecimal, fact: $factorial)';
  }
}

/// Domain Entity representing a calculation record in history
class CalculationHistory {
  final String id;
  final String expression;
  final String result;
  final DateTime timestamp;
  final NumberAnalysis? analysis;

  CalculationHistory({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.analysis,
  });
}
