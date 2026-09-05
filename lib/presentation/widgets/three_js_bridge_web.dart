// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

bool _isViewRegistered = false;

void initThreeJSEngine(String containerId, void Function(String key) onKeyPress) {
  // Register callback on window
  js.context['onCalculator3DKeyPress'] = (dynamic key) {
    if (key != null) {
      onKeyPress(key.toString());
    }
  };

  // Call window.initCalculator3D with containerId
  if (js.context.hasProperty('initCalculator3D')) {
    final elem = html.document.getElementById(containerId);
    if (elem != null) {
      js.context.callMethod('initCalculator3D', [elem]);
    } else {
      js.context.callMethod('initCalculator3D', [containerId]);
    }
  }
}

void updateThreeJSDisplay(String expression, String result, String status) {
  if (js.context.hasProperty('updateCalculator3DDisplay')) {
    js.context.callMethod('updateCalculator3DDisplay', [expression, result, status]);
  }
}

void pressThreeJSKey(String key) {
  if (js.context.hasProperty('pressCalculator3DKey')) {
    js.context.callMethod('pressCalculator3DKey', [key]);
  }
}

void resetThreeJSCamera() {
  if (js.context.hasProperty('resetCalculator3DCamera')) {
    js.context.callMethod('resetCalculator3DCamera', []);
  }
}

void toggleThreeJSAutoRotate() {
  if (js.context.hasProperty('toggleCalculator3DAutoRotate')) {
    js.context.callMethod('toggleCalculator3DAutoRotate', []);
  }
}

Widget buildThreeJSPlatformView(String viewType, String containerId) {
  if (!_isViewRegistered) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.DivElement()
        ..id = containerId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.overflow = 'hidden';

      // Immediate attachment
      if (js.context.hasProperty('initCalculator3D')) {
        js.context.callMethod('initCalculator3D', [element]);
      }

      return element;
    });
    _isViewRegistered = true;
  }

  return HtmlElementView(viewType: viewType);
}
