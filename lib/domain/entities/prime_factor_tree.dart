/// Tree node representing a step in the prime factorization
class PrimeFactorNode {
  final int value;
  final bool isPrime;
  final PrimeFactorNode? left;
  final PrimeFactorNode? right;

  const PrimeFactorNode({
    required this.value,
    required this.isPrime,
    this.left,
    this.right,
  });

  bool get isLeaf => left == null && right == null;
}

/// Representation of a prime factor with its exponent (e.g., 2^3)
class PrimeFactorExponent {
  final int prime;
  final int exponent;

  const PrimeFactorExponent({
    required this.prime,
    required this.exponent,
  });

  @override
  String toString() => exponent > 1 ? '$prime^$exponent' : '$prime';
}
