import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/number_analysis.dart';
import 'glass_container.dart';

/// Modal Bottom Sheet displaying ONLY the requested calculations:
/// Operation result and whether n1 and n2 are prime numbers.
class NumberAnalysisSheet extends StatelessWidget {
  final NumberAnalysis analysis;

  const NumberAnalysisSheet({
    super.key,
    required this.analysis,
  });

  static Future<void> show(BuildContext context, NumberAnalysis analysis) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => NumberAnalysisSheet(analysis: analysis),
    );
  }

  String _formatNumber(double val) {
    if (val % 1 == 0) return val.toInt().toString();
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool hasOperands = analysis.hasOperands;

    return Container(
      constraints: BoxConstraints(
        maxHeight: media.size.height * 0.78,
      ),
      child: GlassContainer(
        blur: 24,
        opacity: 0.9,
        backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.9),
        borderColor: AppColors.cyberCyan.withValues(alpha: 0.45),
        borderWidth: 1.5,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
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
                        Icons.check_circle_outline,
                        color: AppColors.cyberCyan,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasOperands
                              ? 'ANÁLISIS DE LA OPERACIÓN'
                              : 'RESULTADO DEL CÁLCULO',
                          style: const TextStyle(
                            color: AppColors.cyberCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          analysis.operationName ?? 'Cálculo',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

            const SizedBox(height: 14),
            const Divider(color: AppColors.glassBorderSubtle, height: 1),
            const SizedBox(height: 16),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Operation Result Card
                  _buildResultCard(),

                  const SizedBox(height: 18),

                  // 2. Primality Section for n1 and n2 (if binary operands exist)
                  if (hasOperands) ...[
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.cyberCyan, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'PRIMALIDAD DE LOS OPERANDOS (n1 y n2)',
                          style: TextStyle(
                            color: AppColors.cyberCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Side-by-side or stacked cards for n1 and n2
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // n1 Card
                        Expanded(
                          child: _buildOperandCard(
                            label: 'n1',
                            value: analysis.n1!,
                            isPrime: analysis.n1IsPrime ?? false,
                            description: analysis.n1PrimeDesc ?? '',
                            color: AppColors.cyberCyan,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // n2 Card
                        Expanded(
                          child: _buildOperandCard(
                            label: 'n2',
                            value: analysis.n2!,
                            isPrime: analysis.n2IsPrime ?? false,
                            description: analysis.n2PrimeDesc ?? '',
                            color: AppColors.neonPink,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                  ],

                  // 3. Result Primality Card
                  const Row(
                    children: [
                      Icon(Icons.star_outline, color: AppColors.amberGold, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'PRIMALIDAD DEL RESULTADO',
                        style: TextStyle(
                          color: AppColors.amberGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildResultPrimalityCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Big, Clear Result Card with the full operation
  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceElevated.withValues(alpha: 0.8),
            AppColors.surfaceDark.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                analysis.operationName?.toUpperCase() ?? 'OPERACIÓN',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              if (analysis.operatorSymbol != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cyberCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Operador: ${analysis.operatorSymbol}',
                    style: const TextStyle(
                      color: AppColors.cyberCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (analysis.fullExpression != null && analysis.fullExpression!.isNotEmpty)
            Text(
              analysis.fullExpression!,
              style: const TextStyle(
                color: AppColors.textDim,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '= ',
                style: TextStyle(
                  color: AppColors.cyberCyan,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  _formatNumber(analysis.value),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Clean, High-Contrast Card for n1 or n2 Primality
  Widget _buildOperandCard({
    required String label,
    required double value,
    required bool isPrime,
    required String description,
    required Color color,
  }) {
    final formattedVal = _formatNumber(value);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrime
              ? AppColors.emeraldGreen.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formattedVal,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Prime Status Badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: isPrime
                  ? AppColors.emeraldGreen.withValues(alpha: 0.15)
                  : AppColors.amberGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isPrime
                    ? AppColors.emeraldGreen.withValues(alpha: 0.6)
                    : AppColors.amberGold.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPrime ? Icons.check_circle : Icons.cancel_outlined,
                  color: isPrime ? AppColors.emeraldGreen : AppColors.amberGold,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isPrime ? 'ES PRIMO' : 'NO ES PRIMO',
                    style: TextStyle(
                      color: isPrime ? AppColors.emeraldGreen : AppColors.amberGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Card for Result Primality
  Widget _buildResultPrimalityCard() {
    final bool isPrime = analysis.isPrime;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrime
              ? AppColors.emeraldGreen.withValues(alpha: 0.5)
              : AppColors.amberGold.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPrime
                  ? AppColors.emeraldGreen.withValues(alpha: 0.18)
                  : AppColors.amberGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPrime ? Icons.verified_outlined : Icons.info_outline,
              color: isPrime ? AppColors.emeraldGreen : AppColors.amberGold,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Valor ${_formatNumber(analysis.value)}: ',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isPrime ? 'ES PRIMO' : 'NO ES PRIMO',
                      style: TextStyle(
                        color: isPrime ? AppColors.emeraldGreen : AppColors.amberGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  analysis.primalityDescription,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
