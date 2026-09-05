Actúa como un Ingeniero de Software Senior especializado en Flutter (Clean Architecture, Provider/Bloc) y Gráficos WebGL/Three.js.

Tu objetivo es diseñar e implementar desde cero el proyecto Flutter completo llamado "sumadora_chava", integrando un motor 3D interactivo en Three.js con física de pulsado, iluminación de estudio, análisis numérico en tiempo real y renderizado WebGL fluido dentro del ecosistema Flutter.

El proyecto debe satisfacer estrictamente las siguientes directrices arquitectónicas, técnicas y de diseño:

---

### 1. ARQUITECTURA DE SOFTWARE Y PRINCIPIOS SOLID (FLUTTER + DART)
Estructura el código en capas desacopladas siguiendo Clean Architecture:
- **Core:** Constantes de diseño, paleta de colores cyberpunk/dark (`AppColors`), temas y contratos base.
- **Domain Layer (Puro Dart, sin Flutter UI ni JS):**
  - Entidades: `NumberAnalysis` (value, parity, isPrime, divisors, binary, hex, factorial) y `CalculationHistory`.
  - Contratos: `ICalculatorEngine` que define métodos para evaluar expresiones seguras, funciones unarias/científicas y análisis de teoría de números.
- **Data Layer:**
  - `MathEngineService`: Implementación de `ICalculatorEngine` que procesa expresiones matemáticas, previene divisiones por cero y tokeniza operaciones.
  - `NumberTheoryService`: Lógica pura de primalidad (complejidad O(sqrt(n))), criba de divisores y conversiones posicionales.
- **Presentation Layer:**
  - State Management: `CalculatorProvider` (ChangeNotifier) orquestando el estado reactivo.
  - View / 3D Canvas: Componente puente que monta el lienzo WebGL de Three.js (usando `HtmlElementView` en Flutter Web o contenedor interoperable con JS/CSS).
  - UI Overlay: BottomSheet o panel lateral en Flutter nativo con efecto Glassmorphism para visualizar el `NumberAnalysis`.

---

### 2. ESPECIFICACIÓN DEL MOTOR 3D EN THREE.JS (EMBEDDED)
El módulo WebGL/Three.js debe estar completamente autocontenido (Zero external assets, sin dependencias de modelos .gltf/.obj pesados):
- **Chasis de Calculadora 3D:** Malla con bordes biselados usando `THREE.ExtrudeGeometry` y un material `MeshStandardMaterial` metálico oscuro satinado.
- **Botones Interactivos 3D:** Matriz completa de teclas (Científicas, Aritméticas, Acciones y Números). Cada tecla es una caja 3D cuya cara frontal utiliza un `CanvasTexture` generado en memoria con tipografía nítida y bordes biselados procedurales.
- **Pantalla LCD 3D Procedural:** Plano con textura dinámica actualizada en tiempo real que refleja la expresión actual y el resultado numérico con una cuadrícula sutil de fondo y material emisivo.
- **Física Visual y Animación de Pulsado:** Detección de clics mediante `THREE.Raycaster`. Al tocar un botón, debe descender físicamente en el eje Z/Y hacia el chasis con rebote suave mediante interpolación (Tween) y emitir un destello lumínico en su material antes de retornar a su posición de reposo.
- **Iluminación y Cámara:** Cámara en perspectiva con controles orbitales suaves (`OrbitControls` con damping y límites angulares para no invertir la vista), luz ambiental, luz direccional con proyección de sombras suaves (`PCFSoftShadowMap`) y luz de punto emisiva de acento.

---

### 3. CANAL DE COMUNICACIÓN BIDIRECCIONAL (DART <-> JAVASCRIPT)
- Cuando el usuario pulse una tecla física en el entorno 3D, el evento interceptado por el Raycaster debe notificar al controlador en Dart para sincronizar el historial, actualizar el `CalculatorProvider` y desencadenar el análisis numérico.
- La pantalla 3D debe actualizarse instantáneamente reflejando los datos enviados desde Dart o el motor interno.
- Al pulsar el botón '=', la app debe disparar el `NumberAnalysis` y desplegar en Flutter un panel deslizable (`showModalBottomSheet`) con:
  - Paridad (Par / Impar).
  - Primalidad (¿Es primo? Sí / No).
  - Lista ordenada de divisores exactos.
  - Representación Binaria (`0b...`) y Hexadecimal (`0x...`).
  - Factorial exacto (para n <= 18).

---

### 4. ÁRBOL DE DIRECTORIOS Y ARCHIVOS REQUERIDOS
Genera el código completo y organizado según la siguiente estructura:
```text
sumadora_chava/
├── pubspec.yaml
├── web/
│   ├── index.html
│   └── js/
│       └── calculator_3d_engine.js
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/app_colors.dart
│   │   └── theme/app_theme.dart
│   ├── domain/
│   │   ├── entities/number_analysis.dart
│   │   └── repositories/i_calculator_engine.dart
│   ├── data/
│   │   ├── services/math_engine_service.dart
│   │   └── services/number_theory_service.dart
│   └── presentation/
│       ├── providers/calculator_provider.dart
│       ├── widgets/three_js_view.dart
│       ├── widgets/number_analysis_sheet.dart
│       └── screens/calculator_3d_screen.dart
5. CRITERIOS DE CALIDAD Y ENTREGA
Código Dart con tipado estricto, sin warnings y listo para flutter run -d chrome.

Código JavaScript moderno (ES6), modular, sin dependencias locales rotas (utilizar CDNs oficiales de Three.js y Tween.js en index.html o scripts estáticos en web/).

No utilizar código incompleto, sin // TODO ni implementaciones simuladas. Entrega cada archivo listo para producción en un bloque estructurado.