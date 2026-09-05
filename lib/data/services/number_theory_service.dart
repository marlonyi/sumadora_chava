import 'dart:math' as math;
import '../../domain/entities/number_analysis.dart';
import '../../domain/entities/prime_factor_tree.dart';

/// Pure Data Service for Number Theory computations
class NumberTheoryService {
  /// Checks if a double is close to an integer within epsilon tolerance
  static bool isInteger(double value) {
    if (value.isInfinite || value.isNaN) return false;
    return (value - value.roundToDouble()).abs() < 1e-9;
  }

  /// Determines primality with O(sqrt(n)) complexity
  static (bool isPrime, String description) checkPrimality(int n) {
    if (n <= 1) {
      return (false, 'No es primo (los números ≤ 1 no son primos)');
    }
    if (n == 2 || n == 3) {
      return (true, '¡Es un número primo!');
    }
    if (n % 2 == 0) {
      return (false, 'No es primo (divisible por 2)');
    }
    if (n % 3 == 0) {
      return (false, 'No es primo (divisible por 3)');
    }

    final int limit = math.sqrt(n).floor();
    for (int i = 5; i <= limit; i += 6) {
      if (n % i == 0) {
        return (false, 'No es primo (divisible por $i)');
      }
      if (n % (i + 2) == 0) {
        return (false, 'No es primo (divisible por ${i + 2})');
      }
    }
    return (true, '¡Es un número primo!');
  }

  /// Checks primality directly on a double value (validates integer status and boundaries)
  static (bool isPrime, String description) checkDoublePrimality(double val) {
    if (val.isNaN || val.isInfinite) {
      return (false, 'No es un número válido');
    }
    if (!isInteger(val)) {
      return (false, 'No es primo (los números decimales no son primos)');
    }
    final int intVal = val.round();
    if (intVal <= 1) {
      return (false, 'No es primo (los números ≤ 1 no son primos)');
    }
    if (intVal > 1000000000) {
      return (false, 'Número fuera del rango de análisis rápido');
    }
    return checkPrimality(intVal);
  }

  /// Generates the complete sorted list of exact positive divisors
  static List<int> getDivisors(int n) {
    if (n == 0) return [0];
    final int absN = n.abs();
    final List<int> smallDivisors = [];
    final List<int> largeDivisors = [];

    final int limit = math.sqrt(absN).floor();

    for (int i = 1; i <= limit; i++) {
      if (absN % i == 0) {
        smallDivisors.add(i);
        final int counterpart = absN ~/ i;
        if (counterpart != i) {
          largeDivisors.add(counterpart);
        }
      }
    }

    return [...smallDivisors, ...largeDivisors.reversed];
  }

  /// Computes prime factorization with exponents (e.g. 60 -> [2^2, 3^1, 5^1])
  static List<PrimeFactorExponent> getPrimeFactorization(int n) {
    if (n <= 1) return const [];
    final Map<int, int> counts = {};
    int temp = n;

    // Check factor 2
    while (temp % 2 == 0) {
      counts[2] = (counts[2] ?? 0) + 1;
      temp ~/= 2;
    }

    // Check factor 3
    while (temp % 3 == 0) {
      counts[3] = (counts[3] ?? 0) + 1;
      temp ~/= 3;
    }

    // Check factors 6k ± 1
    int factor = 5;
    while (factor * factor <= temp) {
      while (temp % factor == 0) {
        counts[factor] = (counts[factor] ?? 0) + 1;
        temp ~/= factor;
      }
      final int nextFactor = factor + 2;
      while (temp % nextFactor == 0) {
        counts[nextFactor] = (counts[nextFactor] ?? 0) + 1;
        temp ~/= nextFactor;
      }
      factor += 6;
    }

    if (temp > 1) {
      counts[temp] = (counts[temp] ?? 0) + 1;
    }

    return counts.entries
        .map((e) => PrimeFactorExponent(prime: e.key, exponent: e.value))
        .toList();
  }

  /// Recursively builds a prime factor tree for visualization
  static PrimeFactorNode? buildPrimeFactorTree(int n) {
    if (n <= 1) return null;
    final (isPrime, _) = checkPrimality(n);
    if (isPrime) {
      return PrimeFactorNode(value: n, isPrime: true);
    }

    // Find smallest divisor > 1
    int smallestFactor = 2;
    if (n % 2 != 0) {
      smallestFactor = 3;
      while (smallestFactor * smallestFactor <= n && n % smallestFactor != 0) {
        smallestFactor += 2;
      }
      if (n % smallestFactor != 0) smallestFactor = n;
    }

    final int otherFactor = n ~/ smallestFactor;
    return PrimeFactorNode(
      value: n,
      isPrime: false,
      left: buildPrimeFactorTree(smallestFactor),
      right: buildPrimeFactorTree(otherFactor),
    );
  }

  /// Computes exact factorial for n in [0, 18]
  static String calculateFactorial(int n) {
    if (n < 0) return 'Indefinido para números negativos';
    if (n > 18) return 'Supera límite exacto (n > 18)';
    
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return _formatNumberWithCommas(result);
  }

  /// Formats an integer with thousands separator
  static String _formatNumberWithCommas(int n) {
    final String s = n.toString();
    final StringBuffer sb = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      sb.write(s[i]);
      count++;
      if (count % 3 == 0 && i > 0 && s[i - 1] != '-') {
        sb.write(',');
      }
    }
    return sb.toString().split('').reversed.join();
  }

  /// Converts an integer to binary notation 0b...
  static String toBinary(int n) {
    if (n < 0) {
      return '-0b${(-n).toRadixString(2)}';
    }
    return '0b${n.toRadixString(2)}';
  }

  /// Converts an integer to hexadecimal notation 0x...
  static String toHexadecimal(int n) {
    if (n < 0) {
      return '-0x${(-n).toRadixString(16).toUpperCase()}';
    }
    return '0x${n.toRadixString(16).toUpperCase()}';
  }

  /// Performs full analysis on a double value
  NumberAnalysis analyze(double value) {
    if (value.isNaN || value.isInfinite) {
      return NumberAnalysis(
        value: value,
        isInteger: false,
        intValue: null,
        parity: 'N/A',
        isPrime: false,
        primalityDescription: 'No es un número finito válido',
        divisors: const [],
        binary: 'N/A',
        hexadecimal: 'N/A',
        factorial: 'N/A',
        isNegative: value < 0,
      );
    }

    final bool isInt = isInteger(value);
    if (!isInt) {
      return NumberAnalysis(
        value: value,
        isInteger: false,
        intValue: null,
        parity: 'N/A (Decimal)',
        isPrime: false,
        primalityDescription: 'Solo los enteros positivos > 1 pueden ser primos',
        divisors: const [],
        binary: 'N/A (No entero)',
        hexadecimal: 'N/A (No entero)',
        factorial: 'Indefinido para decimales',
        isNegative: value < 0,
      );
    }

    final int intVal = value.round();
    final bool isNeg = intVal < 0;
    final String parity = (intVal % 2 == 0) ? 'Par' : 'Impar';

    final (bool isPrime, String primeDesc) = (intVal > 0 && intVal <= 1000000000)
        ? checkPrimality(intVal)
        : (false, intVal <= 0 ? 'Los enteros ≤ 0 no son primos' : 'Número fuera del rango de análisis rápido');

    final List<int> divisors = (intVal.abs() <= 50000000)
        ? getDivisors(intVal)
        : [1, intVal.abs()];

    final List<PrimeFactorExponent> primeFactors = (intVal > 1 && intVal <= 50000000)
        ? getPrimeFactorization(intVal)
        : const [];

    final PrimeFactorNode? factorTree = (intVal > 1 && intVal <= 1000000)
        ? buildPrimeFactorTree(intVal)
        : null;

    final String bin = toBinary(intVal);
    final String hex = toHexadecimal(intVal);
    final String fact = (intVal >= 0 && intVal <= 18)
        ? calculateFactorial(intVal)
        : (intVal < 0 ? 'Indefinido para negativos' : 'Supera n > 18');

    return NumberAnalysis(
      value: value,
      isInteger: true,
      intValue: intVal,
      parity: parity,
      isPrime: isPrime,
      primalityDescription: primeDesc,
      divisors: divisors,
      primeFactorExponents: primeFactors,
      primeFactorTree: factorTree,
      binary: bin,
      hexadecimal: hex,
      factorial: fact,
      isNegative: isNeg,
    );
  }
}
