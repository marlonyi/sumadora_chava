import 'dart:math' as math;
import '../../domain/entities/number_analysis.dart';
import '../../domain/repositories/i_calculator_engine.dart';
import 'number_theory_service.dart';

/// Concrete Implementation of ICalculatorEngine with safe tokenization,
/// Shunting-yard algorithm for precedence parsing, and full scientific support.
class MathEngineService implements ICalculatorEngine {
  final NumberTheoryService _numberTheoryService;

  MathEngineService({NumberTheoryService? numberTheoryService})
      : _numberTheoryService = numberTheoryService ?? NumberTheoryService();

  @override
  NumberAnalysis analyzeNumber(double value) {
    return _numberTheoryService.analyze(value);
  }

  /// Extracts binary operands n1, operator, and n2 from expression
  static (double n1, String op, double n2, String opName)? extractBinaryOperands(String rawExpr) {
    String expr = rawExpr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(' ', '');

    final match = RegExp(r'^(-?\d+(?:\.\d+)?)\s*([\+\-\*\/\%\^])\s*(-?\d+(?:\.\d+)?)$').firstMatch(expr);
    if (match != null) {
      final double? n1 = double.tryParse(match.group(1)!);
      final String op = match.group(2)!;
      final double? n2 = double.tryParse(match.group(3)!);
      if (n1 != null && n2 != null) {
        String opName;
        switch (op) {
          case '+':
            opName = 'Suma';
            break;
          case '-':
            opName = 'Resta';
            break;
          case '*':
            opName = 'Multiplicación';
            break;
          case '/':
            opName = 'División';
            break;
          case '%':
            opName = 'Residuo';
            break;
          case '^':
            opName = 'Potencia';
            break;
          default:
            opName = 'Operación';
        }
        return (n1, op, n2, opName);
      }
    }
    return null;
  }

  @override
  NumberAnalysis analyzeExpression(String expression, double result) {
    final baseAnalysis = analyzeNumber(result);
    final binaryInfo = extractBinaryOperands(expression);

    if (binaryInfo != null) {
      final (n1, op, n2, opName) = binaryInfo;
      final (n1Prime, n1Desc) = NumberTheoryService.checkDoublePrimality(n1);
      final (n2Prime, n2Desc) = NumberTheoryService.checkDoublePrimality(n2);

      return NumberAnalysis(
        value: baseAnalysis.value,
        isInteger: baseAnalysis.isInteger,
        intValue: baseAnalysis.intValue,
        parity: baseAnalysis.parity,
        isPrime: baseAnalysis.isPrime,
        primalityDescription: baseAnalysis.primalityDescription,
        divisors: baseAnalysis.divisors,
        primeFactorExponents: baseAnalysis.primeFactorExponents,
        primeFactorTree: baseAnalysis.primeFactorTree,
        binary: baseAnalysis.binary,
        hexadecimal: baseAnalysis.hexadecimal,
        factorial: baseAnalysis.factorial,
        isNegative: baseAnalysis.isNegative,
        n1: n1,
        n1IsPrime: n1Prime,
        n1PrimeDesc: n1Desc,
        n2: n2,
        n2IsPrime: n2Prime,
        n2PrimeDesc: n2Desc,
        operatorSymbol: op,
        operationName: opName,
        fullExpression: expression,
      );
    }

    return NumberAnalysis(
      value: baseAnalysis.value,
      isInteger: baseAnalysis.isInteger,
      intValue: baseAnalysis.intValue,
      parity: baseAnalysis.parity,
      isPrime: baseAnalysis.isPrime,
      primalityDescription: baseAnalysis.primalityDescription,
      divisors: baseAnalysis.divisors,
      primeFactorExponents: baseAnalysis.primeFactorExponents,
      primeFactorTree: baseAnalysis.primeFactorTree,
      binary: baseAnalysis.binary,
      hexadecimal: baseAnalysis.hexadecimal,
      factorial: baseAnalysis.factorial,
      isNegative: baseAnalysis.isNegative,
      fullExpression: expression,
    );
  }

  @override
  String formatDouble(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return value.isNegative ? '-Infinito' : 'Infinito';

    if (NumberTheoryService.isInteger(value)) {
      final int intVal = value.round();
      return intVal.toString();
    }

    // Format with maximum 10 decimal digits and strip trailing zeros
    String str = value.toStringAsFixed(10);
    while (str.contains('.') && (str.endsWith('0') || str.endsWith('.'))) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }

  @override
  double evaluateUnary(String functionName, double arg) {
    switch (functionName.toLowerCase()) {
      case 'sin':
        return math.sin(arg);
      case 'cos':
        return math.cos(arg);
      case 'tan':
        if ((arg % math.pi - (math.pi / 2)).abs() < 1e-9) {
          throw const FormatException('Error: Tangente indefinida');
        }
        return math.tan(arg);
      case 'asin':
        if (arg < -1.0 || arg > 1.0) throw const FormatException('Error: Dominio asin [-1, 1]');
        return math.asin(arg);
      case 'acos':
        if (arg < -1.0 || arg > 1.0) throw const FormatException('Error: Dominio acos [-1, 1]');
        return math.acos(arg);
      case 'atan':
        return math.atan(arg);
      case 'sqrt':
      case '√':
        if (arg < 0) throw const FormatException('Error: Raíz de número negativo');
        return math.sqrt(arg);
      case 'cbrt':
        return arg < 0 ? -math.pow(-arg, 1.0 / 3.0).toDouble() : math.pow(arg, 1.0 / 3.0).toDouble();
      case 'ln':
        if (arg <= 0) throw const FormatException('Error: ln(x) solo para x > 0');
        return math.log(arg);
      case 'log':
      case 'log10':
        if (arg <= 0) throw const FormatException('Error: log(x) solo para x > 0');
        return math.log(arg) / math.ln10;
      case 'exp':
        return math.exp(arg);
      case 'abs':
        return arg.abs();
      case 'sqr':
      case 'x^2':
        return arg * arg;
      case 'inv':
      case '1/x':
        if (arg.abs() < 1e-15) throw const FormatException('Error: División por cero');
        return 1.0 / arg;
      case 'neg':
      case '+/-':
        return -arg;
      default:
        throw FormatException('Función unaria desconocida: $functionName');
    }
  }

  @override
  String evaluate(String expression) {
    if (expression.trim().isEmpty) return '0';

    try {
      final double result = _evaluateExpression(expression);
      return formatDouble(result);
    } on FormatException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error de sintaxis';
    }
  }

  // --- Internal Parser & Shunting-Yard Evaluator ---

  double _evaluateExpression(String rawExpr) {
    String expr = rawExpr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', '${math.pi}')
        .replaceAll('PI', '${math.pi}')
        .replaceAll('pi', '${math.pi}')
        .replaceAll('E', '${math.e}')
        .replaceAll('e', '${math.e}')
        .replaceAll(' ', '');

    final List<_Token> tokens = _tokenize(expr);
    final List<_Token> rpn = _toRpn(tokens);
    return _evaluateRpn(rpn);
  }

  List<_Token> _tokenize(String expr) {
    final List<_Token> tokens = [];
    int i = 0;

    bool expectUnary = true;

    while (i < expr.length) {
      final String char = expr[i];

      // Numbers (integers or decimals)
      if (_isDigit(char) || char == '.') {
        final int start = i;
        bool hasDot = char == '.';
        i++;
        while (i < expr.length && (_isDigit(expr[i]) || (!hasDot && expr[i] == '.'))) {
          if (expr[i] == '.') hasDot = true;
          i++;
        }
        final double num = double.parse(expr.substring(start, i));
        tokens.add(_Token(_TokenType.number, num.toString(), num));
        expectUnary = false;
        continue;
      }

      // Unary minus or plus
      if ((char == '-' || char == '+') && expectUnary) {
        tokens.add(_Token(
          char == '-' ? _TokenType.unaryMinus : _TokenType.unaryPlus,
          char == '-' ? 'u-' : 'u+',
        ));
        i++;
        continue;
      }

      // Binary Operators
      if ('+-*/%^'.contains(char)) {
        tokens.add(_Token(_TokenType.operator, char));
        i++;
        expectUnary = true;
        continue;
      }

      // Parentheses
      if (char == '(') {
        tokens.add(_Token(_TokenType.leftParen, '('));
        i++;
        expectUnary = true;
        continue;
      }
      if (char == ')') {
        tokens.add(_Token(_TokenType.rightParen, ')'));
        i++;
        expectUnary = false;
        continue;
      }

      // Scientific Functions (sin, cos, tan, ln, log, sqrt, abs, exp, etc.)
      if (_isAlpha(char)) {
        final int start = i;
        while (i < expr.length && _isAlpha(expr[i])) {
          i++;
        }
        final String fn = expr.substring(start, i).toLowerCase();
        tokens.add(_Token(_TokenType.function, fn));
        expectUnary = true;
        continue;
      }

      throw FormatException('Carácter desconocido: $char');
    }

    return tokens;
  }

  List<_Token> _toRpn(List<_Token> tokens) {
    final List<_Token> output = [];
    final List<_Token> opStack = [];

    for (final token in tokens) {
      switch (token.type) {
        case _TokenType.number:
          output.add(token);
          break;
        case _TokenType.function:
          opStack.add(token);
          break;
        case _TokenType.unaryMinus:
        case _TokenType.unaryPlus:
          opStack.add(token);
          break;
        case _TokenType.operator:
          while (opStack.isNotEmpty &&
              opStack.last.type != _TokenType.leftParen &&
              (_getPrecedence(opStack.last) > _getPrecedence(token) ||
                  (_getPrecedence(opStack.last) == _getPrecedence(token) &&
                      !_isRightAssociative(token)))) {
            output.add(opStack.removeLast());
          }
          opStack.add(token);
          break;
        case _TokenType.leftParen:
          opStack.add(token);
          break;
        case _TokenType.rightParen:
          while (opStack.isNotEmpty && opStack.last.type != _TokenType.leftParen) {
            output.add(opStack.removeLast());
          }
          if (opStack.isEmpty) {
            throw const FormatException('Error: Paréntesis desbalanceados');
          }
          opStack.removeLast(); // Discard '('
          if (opStack.isNotEmpty && opStack.last.type == _TokenType.function) {
            output.add(opStack.removeLast());
          }
          break;
      }
    }

    while (opStack.isNotEmpty) {
      if (opStack.last.type == _TokenType.leftParen || opStack.last.type == _TokenType.rightParen) {
        throw const FormatException('Error: Paréntesis desbalanceados');
      }
      output.add(opStack.removeLast());
    }

    return output;
  }

  double _evaluateRpn(List<_Token> rpn) {
    final List<double> stack = [];

    for (final token in rpn) {
      switch (token.type) {
        case _TokenType.number:
          stack.add(token.numericValue!);
          break;
        case _TokenType.unaryMinus:
          if (stack.isEmpty) throw const FormatException('Error de sintaxis');
          stack.add(-stack.removeLast());
          break;
        case _TokenType.unaryPlus:
          if (stack.isEmpty) throw const FormatException('Error de sintaxis');
          // No-op
          break;
        case _TokenType.function:
          if (stack.isEmpty) throw const FormatException('Error de sintaxis en función');
          final double arg = stack.removeLast();
          stack.add(evaluateUnary(token.value, arg));
          break;
        case _TokenType.operator:
          if (stack.length < 2) throw const FormatException('Error de sintaxis');
          final double b = stack.removeLast();
          final double a = stack.removeLast();
          switch (token.value) {
            case '+':
              stack.add(a + b);
              break;
            case '-':
              stack.add(a - b);
              break;
            case '*':
              stack.add(a * b);
              break;
            case '/':
              if (b.abs() < 1e-15) throw const FormatException('Error: División por cero');
              stack.add(a / b);
              break;
            case '%':
              if (b.abs() < 1e-15) throw const FormatException('Error: División por cero');
              stack.add(a % b);
              break;
            case '^':
              stack.add(math.pow(a, b).toDouble());
              break;
            default:
              throw FormatException('Operador desconocido: ${token.value}');
          }
          break;
        default:
          throw const FormatException('Token inesperado');
      }
    }

    if (stack.length != 1) {
      throw const FormatException('Error en evaluación');
    }

    return stack.first;
  }

  int _getPrecedence(_Token token) {
    if (token.type == _TokenType.unaryMinus || token.type == _TokenType.unaryPlus) return 4;
    if (token.type == _TokenType.function) return 5;
    switch (token.value) {
      case '^':
        return 3;
      case '*':
      case '/':
      case '%':
        return 2;
      case '+':
      case '-':
        return 1;
      default:
        return 0;
    }
  }

  bool _isRightAssociative(_Token token) {
    return token.value == '^' ||
        token.type == _TokenType.unaryMinus ||
        token.type == _TokenType.unaryPlus;
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) {
    final int code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || c == '√';
  }
}

enum _TokenType { number, operator, unaryMinus, unaryPlus, function, leftParen, rightParen }

class _Token {
  final _TokenType type;
  final String value;
  final double? numericValue;

  _Token(this.type, this.value, [this.numericValue]);
}
