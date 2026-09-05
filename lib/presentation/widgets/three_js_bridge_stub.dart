import 'package:flutter/material.dart';

void initThreeJSEngine(String containerId, void Function(String key) onKeyPress) {
  // Stub for non-web platforms
}

void updateThreeJSDisplay(String expression, String result, String status) {
  // Stub for non-web platforms
}

void pressThreeJSKey(String key) {
  // Stub for non-web platforms
}

void resetThreeJSCamera() {
  // Stub for non-web platforms
}

void toggleThreeJSAutoRotate() {
  // Stub for non-web platforms
}

Widget buildThreeJSPlatformView(String viewType, String containerId) {
  return Container(
    color: const Color(0xFF080C14),
    child: const Center(
      child: Text(
        'El visor 3D WebGL está optimizado para Flutter Web.',
        style: TextStyle(color: Colors.white70),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
