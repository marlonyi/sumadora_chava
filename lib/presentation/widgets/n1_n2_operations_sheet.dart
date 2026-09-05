import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/number_theory_service.dart';
import '../providers/calculator_provider.dart';
import 'glass_container.dart';

/// Interactive Sheet dedicated to two numbers n1 and n2:
/// Evaluates: Suma (+), Resta (-), Multiplicación (*), División (/), Residuo (%), Potencia (^)
/// and tells whether n1 and n2 are prime numbers.
class N1N2OperationsSheet extends StatefulWidget {
  const N1N2OperationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => const N1N2OperationsSheet(),
    );
  }

  @override
  State<N1N2OperationsSheet> createState() => _N1N2OperationsSheetState();
}

class _N1N2OperationsSheetState extends State<N1N2OperationsSheet> {
  final TextEditingController _n1Controller = TextEditingController(text: '17');
  final TextEditingController _n2Controller = TextEditingController(text: '5');

  double? _n1;
  double? _n2;

  @override
  void initState() {
    super.initState();
    _parseInputs();
  }

  @override
  void dispose() {
    _n1Controller.dispose();
    _n2Controller.dispose();
    super.dispose();
  }

  void _parseInputs() {
    setState(() {
      _n1 = double.tryParse(_n1Controller.text.trim());
      _n2 = double.tryParse(_n2Controller.text.trim());
    });
  }

  String _formatNumber(double val) {
    if (val.isNaN) return 'Error';
    if (val.isInfinite) return val.isNegative ? '-Infinito' : 'Infinito';
    if (val % 1 == 0) return val.toInt().toString();
    return val.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final provider = context.read<CalculatorProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: media.size.height * 0.85,
        ),
        child: GlassContainer(
          blur: 24,
          opacity: 0.92,
          backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.92),
          borderColor: AppColors.cyberCyan.withValues(alpha: 0.45),
          borderWidth: 1.5,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.textDim.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cyberCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.cyberCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.calculate_rounded,
                          color: AppColors.cyberCyan,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPERACIONES N1 Y N2',
                            style: TextStyle(
                              color: AppColors.cyberCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Suma, Resta, Mult, Div, Residuo, Potencia',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              const SizedBox(height: 14),

              // Inputs for n1 and n2
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _n1Controller,
                      label: 'Número 1 (n1)',
                      color: AppColors.cyberCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      controller: _n2Controller,
                      label: 'Número 2 (n2)',
                      color: AppColors.neonPink,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Primality of n1 and n2 Cards
              Row(
                children: [
                  Expanded(
                    child: _buildPrimalityStatusCard(
                      label: 'n1',
                      val: _n1,
                      accentColor: AppColors.cyberCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPrimalityStatusCard(
                      label: 'n2',
                      val: _n2,
                      accentColor: AppColors.neonPink,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Row(
                children: [
                  Icon(Icons.format_list_bulleted_rounded, color: AppColors.cyberCyan, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'RESULTADO DE LAS 6 OPERACIONES',
                    style: TextStyle(
                      color: AppColors.cyberCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Operations List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildOperationRow(
                      name: 'Suma',
                      opSymbol: '+',
                      result: _n1 != null && _n2 != null ? (_n1! + _n2!) : null,
                      onSelect: () => _executeOperation(provider, '+'),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationRow(
                      name: 'Resta',
                      opSymbol: '−',
                      calcOp: '-',
                      result: _n1 != null && _n2 != null ? (_n1! - _n2!) : null,
                      onSelect: () => _executeOperation(provider, '-'),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationRow(
                      name: 'Multiplicación',
                      opSymbol: '×',
                      calcOp: '*',
                      result: _n1 != null && _n2 != null ? (_n1! * _n2!) : null,
                      onSelect: () => _executeOperation(provider, '*'),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationRow(
                      name: 'División',
                      opSymbol: '÷',
                      calcOp: '/',
                      result: _n1 != null && _n2 != null
                          ? (_n2! == 0 ? null : (_n1! / _n2!))
                          : null,
                      customError: _n2 == 0 ? 'División por cero' : null,
                      onSelect: () => _executeOperation(provider, '/'),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationRow(
                      name: 'Residuo de la división',
                      opSymbol: '%',
                      result: _n1 != null && _n2 != null
                          ? (_n2! == 0 ? null : (_n1! % _n2!))
                          : null,
                      customError: _n2 == 0 ? 'División por cero' : null,
                      onSelect: () => _executeOperation(provider, '%'),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationRow(
                      name: 'Potencia (n1 ^ n2)',
                      opSymbol: '^',
                      result: _n1 != null && _n2 != null
                          ? math.pow(_n1!, _n2!).toDouble()
                          : null,
                      onSelect: () => _executeOperation(provider, '^'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _executeOperation(CalculatorProvider provider, String op) {
    if (_n1 == null || _n2 == null) return;
    Navigator.pop(context);
    provider.executeN1N2Operation(_n1!, _n2!, op);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        onChanged: (_) => _parseInputs(),
      ),
    );
  }

  Widget _buildPrimalityStatusCard({
    required String label,
    required double? val,
    required Color accentColor,
  }) {
    if (val == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: Text(
          '$label: Ingrese un valor',
          style: const TextStyle(color: AppColors.textDim, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }

    final (bool isPrime, String desc) = NumberTheoryService.checkDoublePrimality(val);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrime
              ? AppColors.emeraldGreen.withValues(alpha: 0.6)
              : AppColors.amberGold.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label = ${_formatNumber(val)}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                isPrime ? Icons.check_circle : Icons.cancel_outlined,
                color: isPrime ? AppColors.emeraldGreen : AppColors.amberGold,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isPrime
                  ? AppColors.emeraldGreen.withValues(alpha: 0.15)
                  : AppColors.amberGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPrime ? '¿Es primo? SÍ' : '¿Es primo? NO',
              style: TextStyle(
                color: isPrime ? AppColors.emeraldGreen : AppColors.amberGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationRow({
    required String name,
    required String opSymbol,
    String? calcOp,
    required double? result,
    String? customError,
    required VoidCallback onSelect,
  }) {
    final String resultDisplay = customError ??
        (result != null ? _formatNumber(result) : '—');

    final bool hasError = customError != null;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cyberCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                opSymbol,
                style: const TextStyle(
                  color: AppColors.cyberCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_n1 != null && _n2 != null)
                    Text(
                      '${_formatNumber(_n1!)} $opSymbol ${_formatNumber(_n2!)}',
                      style: const TextStyle(
                        color: AppColors.textDim,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
            ),
            Text(
              resultDisplay,
              style: TextStyle(
                color: hasError
                    ? AppColors.crimsonRed
                    : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textDim,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
