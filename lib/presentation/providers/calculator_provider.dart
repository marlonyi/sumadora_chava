import 'package:flutter/foundation.dart';
import '../../domain/entities/number_analysis.dart';
import '../../domain/repositories/i_calculator_engine.dart';
import '../../data/services/math_engine_service.dart';

/// Provider orchestrating Calculator State and bridging with the 3D Engine
class CalculatorProvider extends ChangeNotifier {
  final ICalculatorEngine _engine;

  String _expression = '';
  String _displayValue = '0';
  String? _lastResult;
  NumberAnalysis? _currentAnalysis;
  final List<CalculationHistory> _history = [];
  bool _isRadMode = true;
  String? _errorMessage;

  // Callback to signal the UI (e.g. when '=' or 'ANALYSIS' or 'HIST' or 'CENTRAR' is pressed)
  void Function(NumberAnalysis analysis)? onAnalysisTriggered;
  VoidCallback? onHistoryTriggered;
  VoidCallback? onCenterTriggered;

  CalculatorProvider({ICalculatorEngine? engine})
      : _engine = engine ?? MathEngineService();

  // Getters
  String get expression => _expression;
  String get displayValue => _displayValue;
  String? get lastResult => _lastResult;
  NumberAnalysis? get currentAnalysis => _currentAnalysis;
  List<CalculationHistory> get history => List.unmodifiable(_history);
  bool get isRadMode => _isRadMode;
  String? get errorMessage => _errorMessage;

  void toggleAngleMode() {
    _isRadMode = !_isRadMode;
    notifyListeners();
  }

  /// Processes key input coming from 3D Raycaster clicks or Flutter UI
  void handleKeyInput(String key) {
    _errorMessage = null;

    switch (key.toUpperCase()) {
      case 'AC':
      case 'C':
        clear();
        break;

      case 'DEL':
      case 'BACKSPACE':
        deleteLast();
        break;

      case '=':
      case 'ENTER':
      case 'EVAL':
        evaluate(triggerSheet: true);
        break;

      case 'HIST':
      case 'HISTORY':
      case 'HISTORIAL':
        if (onHistoryTriggered != null) {
          onHistoryTriggered!();
        }
        break;

      case 'CENTER':
      case 'CENTRAR':
        if (onCenterTriggered != null) {
          onCenterTriggered!();
        }
        break;

      case 'RAD':
      case 'DEG':
      case 'RAD/DEG':
      case 'DEG/RAD':
      case 'MODE':
        toggleAngleMode();
        break;

      case 'ANALYSIS':
      case 'ANALYZE':
      case 'ANALIZAR':
        triggerCurrentAnalysis();
        break;

      case '+/-':
      case 'NEG':
        _toggleSign();
        break;

      case '%':
        _appendOperator('%');
        break;

      case '1/X':
      case 'INV':
        _applyUnaryImmediate('1/x');
        break;

      case 'X^2':
      case 'SQR':
        _appendOperator('^2');
        break;

      case 'SQRT':
      case '√':
        _appendFunction('sqrt');
        break;

      case 'SIN':
      case 'COS':
      case 'TAN':
      case 'LN':
      case 'LOG':
        _appendFunction(key.toLowerCase());
        break;

      case 'PI':
      case 'π':
        _appendConstant('π');
        break;

      case 'E':
        _appendConstant('e');
        break;

      case '^':
      case '+':
      case '-':
      case '*':
      case '/':
      case '×':
      case '÷':
        _appendOperator(key == '×' ? '*' : (key == '÷' ? '/' : key));
        break;

      case '(':
      case ')':
        _appendParenthesis(key);
        break;

      case '.':
        _appendDot();
        break;

      default:
        // Digit inputs (0-9)
        if (RegExp(r'^[0-9]$').hasMatch(key)) {
          _appendDigit(key);
        }
        break;
    }

    notifyListeners();
  }

  void _appendDigit(String digit) {
    if (_lastResult != null && _expression.isEmpty) {
      _displayValue = digit;
      _expression = digit;
      _lastResult = null;
      return;
    }

    if (_displayValue == '0' && _expression.isEmpty) {
      _displayValue = digit;
      _expression = digit;
    } else {
      _expression += digit;
      _displayValue = _expression;
    }
  }

  void _appendDot() {
    if (_expression.isEmpty) {
      _expression = '0.';
      _displayValue = '0.';
    } else {
      // Check if last token already has a dot
      final lastToken = _expression.split(RegExp(r'[^0-9.]')).last;
      if (!lastToken.contains('.')) {
        _expression += '.';
        _displayValue = _expression;
      }
    }
  }

  void _appendOperator(String op) {
    if (_expression.isEmpty) {
      if (_lastResult != null) {
        _expression = _lastResult! + op;
      } else if (op == '-') {
        _expression = '-';
      }
    } else {
      final lastChar = _expression[_expression.length - 1];
      if ('+-*/%^'.contains(lastChar)) {
        // Replace previous operator
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
    }
    _displayValue = _expression;
    _lastResult = null;
  }

  void _appendFunction(String fn) {
    if (_lastResult != null && _expression.isEmpty) {
      _expression = '$fn($_lastResult)';
    } else {
      _expression += '$fn(';
    }
    _displayValue = _expression;
    _lastResult = null;
  }

  void _appendConstant(String c) {
    if (_lastResult != null && _expression.isEmpty) {
      _expression = c;
    } else {
      _expression += c;
    }
    _displayValue = _expression;
    _lastResult = null;
  }

  void _appendParenthesis(String p) {
    _expression += p;
    _displayValue = _expression;
    _lastResult = null;
  }

  void _toggleSign() {
    if (_expression.isNotEmpty) {
      if (_expression.startsWith('-(') && _expression.endsWith(')')) {
        _expression = _expression.substring(2, _expression.length - 1);
      } else {
        _expression = '-($_expression)';
      }
      _displayValue = _expression;
    } else if (_lastResult != null) {
      final val = double.tryParse(_lastResult!);
      if (val != null) {
        _lastResult = _engine.formatDouble(-val);
        _displayValue = _lastResult!;
      }
    }
  }

  void _applyUnaryImmediate(String fn) {
    if (_expression.isEmpty && _lastResult != null) {
      _expression = '$fn($_lastResult)';
    } else if (_expression.isNotEmpty) {
      _expression = '$fn($_expression)';
    }
    evaluate(triggerSheet: false);
  }

  /// Evaluates the active expression, analyzes the number, and updates state
  void evaluate({bool triggerSheet = true}) {
    if (_expression.trim().isEmpty) {
      if (_lastResult != null) {
        final double? val = double.tryParse(_lastResult!);
        if (val != null) {
          _currentAnalysis = _engine.analyzeNumber(val);
          if (triggerSheet && onAnalysisTriggered != null) {
            onAnalysisTriggered!(_currentAnalysis!);
          }
        }
      }
      return;
    }

    final String rawExpr = _expression;
    final String resultStr = _engine.evaluate(rawExpr);

    if (resultStr.startsWith('Error')) {
      _errorMessage = resultStr;
      _displayValue = resultStr;
      notifyListeners();
      return;
    }

    final double? numericVal = double.tryParse(resultStr);
    NumberAnalysis? analysis;

    if (numericVal != null) {
      analysis = _engine.analyzeExpression(rawExpr, numericVal);
      _currentAnalysis = analysis;
    }

    // Save to calculation history
    final historyEntry = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      expression: rawExpr,
      result: resultStr,
      timestamp: DateTime.now(),
      analysis: analysis,
    );
    _history.insert(0, historyEntry);
    if (_history.length > 50) {
      _history.removeLast();
    }

    _lastResult = resultStr;
    _displayValue = resultStr;
    _expression = '';

    notifyListeners();

    if (triggerSheet && analysis != null && onAnalysisTriggered != null) {
      onAnalysisTriggered!(analysis);
    }
  }

  /// Directly executes an operation between n1 and n2 (Suma, Resta, Multiplicación, División, Residuo, Potencia)
  void executeN1N2Operation(double n1, double n2, String op, {bool triggerSheet = true}) {
    final String formattedN1 = _engine.formatDouble(n1);
    final String formattedN2 = _engine.formatDouble(n2);
    final String expr = '$formattedN1 $op $formattedN2';
    _expression = expr;
    _displayValue = expr;
    evaluate(triggerSheet: triggerSheet);
  }

  void triggerCurrentAnalysis() {
    double? val;
    String expr = _expression;
    if (_lastResult != null) {
      val = double.tryParse(_lastResult!);
      if (expr.isEmpty && _history.isNotEmpty) {
        expr = _history.first.expression;
      }
    } else if (_displayValue != '0' && !_displayValue.startsWith('Error')) {
      val = double.tryParse(_displayValue);
    }

    if (val != null) {
      _currentAnalysis = _engine.analyzeExpression(expr, val);
      if (onAnalysisTriggered != null) {
        onAnalysisTriggered!(_currentAnalysis!);
      }
      notifyListeners();
    }
  }

  void clear() {
    _expression = '';
    _displayValue = '0';
    _lastResult = null;
    _errorMessage = null;
    _currentAnalysis = null;
    notifyListeners();
  }

  void deleteLast() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _displayValue = _expression.isEmpty ? '0' : _expression;
    } else {
      _displayValue = '0';
    }
    _lastResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void loadFromHistory(CalculationHistory item) {
    _expression = item.expression;
    _displayValue = item.result;
    _lastResult = item.result;
    _currentAnalysis = item.analysis;
    notifyListeners();
  }
}
