import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import 'three_js_bridge.dart';

/// Flutter Widget embedding the Three.js 3D WebGL Canvas
class ThreeJSView extends StatefulWidget {
  final String containerId;
  final String viewType;

  const ThreeJSView({
    super.key,
    this.containerId = 'threejs-canvas-wrapper',
    this.viewType = 'threejs-calculator-view',
  });

  @override
  State<ThreeJSView> createState() => _ThreeJSViewState();
}

class _ThreeJSViewState extends State<ThreeJSView> {
  bool _initialized = false;
  String _lastRenderedKey = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initEngine();
    });
  }

  void _initEngine() {
    if (_initialized) return;

    final provider = context.read<CalculatorProvider>();

    initThreeJSEngine(widget.containerId, (String key) {
      // Callback from 3D Raycaster clicks in Three.js
      provider.handleKeyInput(key);
    });

    setState(() {
      _initialized = true;
    });

    // Initial display sync
    _syncDisplay(provider);
  }

  void _syncDisplay(CalculatorProvider provider) {
    final status = provider.isRadMode ? 'RAD' : 'DEG';
    final currentKey = '${provider.expression}_${provider.displayValue}_$status';

    if (currentKey != _lastRenderedKey) {
      _lastRenderedKey = currentKey;
      updateThreeJSDisplay(provider.expression, provider.displayValue, status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    _syncDisplay(provider);

    return Stack(
      children: [
        Positioned.fill(
          child: buildThreeJSPlatformView(widget.viewType, widget.containerId),
        ),
      ],
    );
  }
}
