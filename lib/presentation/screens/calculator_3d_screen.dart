import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/number_analysis.dart';
import '../providers/calculator_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/n1_n2_operations_sheet.dart';
import '../widgets/number_analysis_sheet.dart';
import '../widgets/three_js_bridge.dart';
import '../widgets/three_js_view.dart';

/// Clean, Immersive 3D Calculator Screen focused entirely on the 3D Device
class Calculator3DScreen extends StatefulWidget {
  const Calculator3DScreen({super.key});

  @override
  State<Calculator3DScreen> createState() => _Calculator3DScreenState();
}

class _Calculator3DScreenState extends State<Calculator3DScreen> {
  @override
  void initState() {
    super.initState();
    // Hook provider callbacks to display modal sheets when 3D buttons are pressed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CalculatorProvider>();
      provider.onAnalysisTriggered = (NumberAnalysis analysis) {
        if (mounted) {
          NumberAnalysisSheet.show(context, analysis);
        }
      };
      provider.onHistoryTriggered = () {
        if (mounted) {
          _showHistorySheet(context);
        }
      };
      provider.onCenterTriggered = () {
        resetThreeJSCamera();
      };
    });
  }

  void _showHistorySheet(BuildContext context) {
    final provider = context.read<CalculatorProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: GlassContainer(
            blur: 24,
            opacity: 0.9,
            backgroundColor: AppColors.surfaceDark.withValues(alpha: 0.9),
            borderColor: AppColors.cyberCyan.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.textDim.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.history_rounded, color: AppColors.cyberCyan, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'HISTORIAL DE CÁLCULOS',
                          style: TextStyle(
                            color: AppColors.cyberCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    if (provider.history.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          provider.clearHistory();
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.crimsonRed),
                        label: const Text(
                          'Limpiar',
                          style: TextStyle(color: AppColors.crimsonRed, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.glassBorderSubtle, height: 1),
                const SizedBox(height: 12),
                Expanded(
                  child: provider.history.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calculate_outlined, size: 48, color: AppColors.textDim),
                              SizedBox(height: 12),
                              Text(
                                'Aún no hay cálculos en el historial.',
                                style: TextStyle(color: AppColors.textDim, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.history.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = provider.history[index];
                            return InkWell(
                              onTap: () {
                                provider.loadFromHistory(item);
                                Navigator.pop(ctx);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.glassBorderSubtle),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.expression,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '= ${item.result}',
                                            style: const TextStyle(
                                              color: AppColors.cyberCyan,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (item.analysis != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.analytics_outlined,
                                          color: AppColors.neonPink,
                                          size: 20,
                                        ),
                                        tooltip: 'Ver Análisis',
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          NumberAnalysisSheet.show(context, item.analysis!);
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Fullscreen Clean 3D WebGL Canvas
          const Positioned.fill(
            child: ThreeJSView(),
          ),

          // Top Header Overlay with Glass Action for N1 y N2
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand / Mode badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.glassBorderSubtle),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar_rounded, color: AppColors.cyberCyan, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'CALCULADORA 3D',
                            style: TextStyle(
                              color: AppColors.cyberCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quick Action: Modo n1 y n2
                    InkWell(
                      onTap: () => N1N2OperationsSheet.show(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.cyberCyan.withValues(alpha: 0.25),
                              AppColors.neonPink.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cyberCyan.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyberCyan.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.functions_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'OPERACIONES N1 Y N2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
