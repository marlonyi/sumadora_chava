import '../entities/number_analysis.dart';

/// Contract for mathematical evaluation and number theory analysis
abstract interface class ICalculatorEngine {
  /// Evaluates a mathematical expression string and returns the computed result string
  /// Throws FormatException or MathException on invalid syntax or undefined math operations
  String evaluate(String expression);

  /// Performs deep number theory analysis on a given numerical value
  NumberAnalysis analyzeNumber(double value);

  /// Performs analysis on the computed result and extracts n1 and n2 operands if applicable
  NumberAnalysis analyzeExpression(String expression, double result);

  /// Computes a single unary function (e.g. sin, cos, sqrt, ln, etc.)
  double evaluateUnary(String functionName, double arg);

  /// Formats a double value nicely removing trailing zeroes or scientific notation
  String formatDouble(double value);
}
