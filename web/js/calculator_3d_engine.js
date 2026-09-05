/**
 * Sumadora Chava - Ultra-Sharp 3D WebGL Scientific Calculator
 * Razor-Sharp Typography, Perfect Aspect-Ratio Texturing, Clean OLED LCD
 * Zero blur, Zero distortion, 100% Readable and Responsive.
 */

(function () {
  'use strict';

  let scene, camera, renderer, controls;
  let calculatorGroup;
  let bodyMesh, frameMesh, screenBezel, displayMesh, glassMesh;
  let displayTexture, displayCanvas, displayCtx;
  const buttonMeshes = [];
  const raycaster = new THREE.Raycaster();
  const mouse = new THREE.Vector2();
  let containerElement = null;
  let isInitialized = false;
  let animationFrameId = null;

  let currentExpression = '';
  let currentResult = '0';
  let currentStatus = 'RAD';

  // --- Web Audio Synthesizer ---
  let audioCtx = null;

  function unlockAudio() {
    if (!audioCtx) {
      try {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext;
        if (AudioContextClass) {
          audioCtx = new AudioContextClass();
        }
      } catch (e) {}
    }
    if (audioCtx && audioCtx.state === 'suspended') {
      audioCtx.resume().catch(() => {});
    }
  }

  window.addEventListener('pointerdown', unlockAudio, { once: true, passive: true });
  window.addEventListener('keydown', unlockAudio, { once: true, passive: true });
  window.addEventListener('touchstart', unlockAudio, { once: true, passive: true });

  function playKeyBeep(frequency = 600) {
    try {
      unlockAudio();
      if (!audioCtx || audioCtx.state !== 'running') return;

      const now = audioCtx.currentTime;
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(frequency, now);
      osc.frequency.exponentialRampToValueAtTime(frequency * 0.5, now + 0.04);

      gain.gain.setValueAtTime(0.07, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.04);

      osc.connect(gain);
      gain.connect(audioCtx.destination);

      osc.start(now);
      osc.stop(now + 0.04);
    } catch (e) {}
  }

  // --- Keypad Definitions ---
  const KEY_LAYOUT = [
    // Row 0: Top Wide Feature Buttons
    [
      { label: 'HIST', display: 'HISTORIAL', type: 'special_hist', sound: 750 },
      { label: 'CENTER', display: 'CENTRAR', type: 'special_center', sound: 850 }
    ],
    // Row 1: Trigonometry & Logarithms
    [
      { label: 'sin', display: 'sin', type: 'func', sound: 880 },
      { label: 'cos', display: 'cos', type: 'func', sound: 880 },
      { label: 'tan', display: 'tan', type: 'func', sound: 880 },
      { label: 'ln',  display: 'ln',  type: 'func', sound: 820 },
      { label: 'log', display: 'log', type: 'func', sound: 820 }
    ],
    // Row 2: Secondary Scientific & Clear
    [
      { label: 'sqrt', display: '√', type: 'func', sound: 780 },
      { label: '^',    display: 'xʸ', type: 'op', sound: 780 },
      { label: '(',    display: '(', type: 'paren', sound: 700 },
      { label: ')',    display: ')', type: 'paren', sound: 700 },
      { label: 'AC',   display: 'AC', type: 'action_ac', sound: 350 }
    ],
    // Row 3: 7-8-9, DEL, Divide
    [
      { label: '7', display: '7', type: 'num', sound: 520 },
      { label: '8', display: '8', type: 'num', sound: 540 },
      { label: '9', display: '9', type: 'num', sound: 560 },
      { label: 'DEL', display: 'DEL', type: 'action_del', sound: 400 },
      { label: '/', display: '÷', type: 'op', sound: 650 }
    ],
    // Row 4: 4-5-6, Multiply, Sign
    [
      { label: '4', display: '4', type: 'num', sound: 460 },
      { label: '5', display: '5', type: 'num', sound: 480 },
      { label: '6', display: '6', type: 'num', sound: 500 },
      { label: '*', display: '×', type: 'op', sound: 650 },
      { label: '+/-', display: '±', type: 'func', sound: 600 }
    ],
    // Row 5: 1-2-3, Minus, Modulo
    [
      { label: '1', display: '1', type: 'num', sound: 400 },
      { label: '2', display: '2', type: 'num', sound: 420 },
      { label: '3', display: '3', type: 'num', sound: 440 },
      { label: '-', display: '−', type: 'op', sound: 650 },
      { label: '%', display: '%', type: 'op', sound: 650 }
    ],
    // Row 6: 0, Dot, Pi, Plus, Equals
    [
      { label: '0', display: '0', type: 'num', sound: 380 },
      { label: '.', display: '•', type: 'num', sound: 450 },
      { label: 'pi', display: 'π', type: 'func', sound: 720 },
      { label: '+', display: '+', type: 'op', sound: 650 },
      { label: '=', display: '=', type: 'equal', sound: 990 }
    ]
  ];

  // Clean, High-Contrast Color Themes (Optimized for crystal-clear readability)
  const THEMES = {
    num: {
      bg: '#111827',
      border: '#00e5ff',
      text: '#ffffff',
      emissive: 0x00e5ff,
      emissiveIntensity: 0.18
    },
    op: {
      bg: '#271705',
      border: '#fbbf24',
      text: '#ffffff',
      emissive: 0xf59e0b,
      emissiveIntensity: 0.22
    },
    func: {
      bg: '#1e112a',
      border: '#c084fc',
      text: '#ffffff',
      emissive: 0xa855f7,
      emissiveIntensity: 0.2
    },
    paren: {
      bg: '#0f172a',
      border: '#38bdf8',
      text: '#ffffff',
      emissive: 0x38bdf8,
      emissiveIntensity: 0.18
    },
    action_ac: {
      bg: '#370b16',
      border: '#f87171',
      text: '#ffffff',
      emissive: 0xef4444,
      emissiveIntensity: 0.28
    },
    action_del: {
      bg: '#2f0d1e',
      border: '#f472b6',
      text: '#ffffff',
      emissive: 0xec4899,
      emissiveIntensity: 0.25
    },
    equal: {
      bg: '#043424',
      border: '#34d399',
      text: '#ffffff',
      emissive: 0x10b981,
      emissiveIntensity: 0.35
    },
    special_analysis: {
      bg: '#380620',
      border: '#f43f5e',
      text: '#ffffff',
      emissive: 0xf43f5e,
      emissiveIntensity: 0.3
    },
    special_center: {
      bg: '#042233',
      border: '#00e5ff',
      text: '#ffffff',
      emissive: 0x00e5ff,
      emissiveIntensity: 0.28
    },
    special_hist: {
      bg: '#052233',
      border: '#00e5ff',
      text: '#ffffff',
      emissive: 0x00e5ff,
      emissiveIntensity: 0.25
    }
  };

  /**
   * Helper to create rounded rectangle shape for chassis
   */
  function createRoundedRectShape(width, height, radius) {
    const shape = new THREE.Shape();
    const x = -width / 2;
    const y = -height / 2;
    shape.moveTo(x + radius, y);
    shape.lineTo(x + width - radius, y);
    shape.quadraticCurveTo(x + width, y, x + width, y + radius);
    shape.lineTo(x + width, y + height - radius);
    shape.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    shape.lineTo(x + radius, y + height);
    shape.quadraticCurveTo(x, y + height, x, y + height - radius);
    shape.lineTo(x, y + radius);
    shape.quadraticCurveTo(x, y, x + radius, y);
    return shape;
  }

  /**
   * Generates razor-sharp button textures matching exact button aspect ratio
   */
  function generateButtonTexture(displayLabel, type, aspectWidth = 1, aspectHeight = 1) {
    const canvas = document.createElement('canvas');
    // Compute resolution with exact aspect ratio
    const baseRes = 512;
    if (aspectWidth > aspectHeight) {
      canvas.width = Math.round(baseRes * (aspectWidth / aspectHeight));
      canvas.height = baseRes;
    } else {
      canvas.width = baseRes;
      canvas.height = Math.round(baseRes * (aspectHeight / aspectWidth));
    }

    const ctx = canvas.getContext('2d');
    const w = canvas.width;
    const h = canvas.height;
    const theme = THEMES[type] || THEMES.num;

    // Solid High-Contrast Background
    ctx.fillStyle = theme.bg;
    ctx.fillRect(0, 0, w, h);

    // Subtle Bevel Border
    ctx.strokeStyle = theme.border;
    ctx.lineWidth = Math.max(8, Math.round(w * 0.025));
    ctx.strokeRect(ctx.lineWidth / 2, ctx.lineWidth / 2, w - ctx.lineWidth, h - ctx.lineWidth);

    // Inner subtle border
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.12)';
    ctx.lineWidth = 3;
    ctx.strokeRect(ctx.lineWidth + 8, ctx.lineWidth + 8, w - (ctx.lineWidth + 8) * 2, h - (ctx.lineWidth + 8) * 2);

    // Clean, Razor-Sharp Vector Typography (NO blur/shadow)
    ctx.fillStyle = theme.text;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    const label = displayLabel || '';
    const centerX = w / 2;
    const centerY = h / 2;

    // Auto-fit font size based on aspect ratio & text length
    if (aspectWidth / aspectHeight > 2.5) {
      // Wide banner button (HISTORIAL / ANÁLISIS)
      ctx.font = `bold ${Math.round(h * 0.38)}px system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`;
      ctx.letterSpacing = '2px';
      ctx.fillText(label, centerX, centerY + h * 0.02);
    } else if (label.length === 1) {
      ctx.font = `bold ${Math.round(h * 0.52)}px system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`;
      ctx.fillText(label, centerX, centerY + h * 0.03);
    } else if (label.length === 2) {
      ctx.font = `bold ${Math.round(h * 0.42)}px system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`;
      ctx.fillText(label, centerX, centerY + h * 0.03);
    } else if (label.length === 3) {
      ctx.font = `bold ${Math.round(h * 0.36)}px system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`;
      ctx.fillText(label, centerX, centerY + h * 0.03);
    } else {
      ctx.font = `bold ${Math.round(h * 0.28)}px system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`;
      ctx.fillText(label, centerX, centerY + h * 0.03);
    }

    const texture = new THREE.CanvasTexture(canvas);
    texture.minFilter = THREE.LinearFilter;
    texture.magFilter = THREE.LinearFilter;
    texture.generateMipmaps = false;
    texture.needsUpdate = true;
    return texture;
  }

  /**
   * Creates the LCD Display Canvas Texture
   */
  function initDisplayTexture() {
    displayCanvas = document.createElement('canvas');
    displayCanvas.width = 1200;
    displayCanvas.height = 460;
    displayCtx = displayCanvas.getContext('2d');

    displayTexture = new THREE.CanvasTexture(displayCanvas);
    displayTexture.minFilter = THREE.LinearFilter;
    displayTexture.magFilter = THREE.LinearFilter;
    displayTexture.generateMipmaps = false;
    displayTexture.needsUpdate = true;

    drawLCDDisplay('', '0', 'RAD');
  }

  function drawLCDDisplay(expression, result, status) {
    if (!displayCtx) return;

    currentExpression = expression !== undefined ? expression : currentExpression;
    currentResult = result !== undefined ? result : currentResult;
    currentStatus = status !== undefined ? status : currentStatus;

    const w = 1200;
    const h = 460;

    // Deep Dark OLED Panel
    displayCtx.fillStyle = '#060a12';
    displayCtx.fillRect(0, 0, w, h);

    // Subtle Outer Bezel Glow Line
    displayCtx.strokeStyle = '#00e5ff';
    displayCtx.lineWidth = 6;
    displayCtx.strokeRect(6, 6, w - 12, h - 12);

    // Inner subtle frame
    displayCtx.strokeStyle = 'rgba(0, 229, 255, 0.2)';
    displayCtx.lineWidth = 2;
    displayCtx.strokeRect(20, 20, w - 40, h - 40);

    // Top Header Bar: App Name & Mode
    displayCtx.fillStyle = '#38bdf8';
    displayCtx.font = 'bold 32px system-ui, sans-serif';
    displayCtx.textAlign = 'left';
    displayCtx.textBaseline = 'top';
    displayCtx.fillText('SUMADORA CHAVA', 42, 38);

    // Mode Tag (RAD / DEG)
    displayCtx.textAlign = 'right';
    displayCtx.fillStyle = '#10b981';
    displayCtx.font = 'bold 32px monospace';
    displayCtx.fillText(`[ ${currentStatus} ]`, w - 42, 38);

    // Horizontal Divider
    displayCtx.strokeStyle = 'rgba(56, 189, 248, 0.25)';
    displayCtx.lineWidth = 2;
    displayCtx.beginPath();
    displayCtx.moveTo(42, 95);
    displayCtx.lineTo(w - 42, 95);
    displayCtx.stroke();

    // Expression Line (Current input formula)
    displayCtx.textAlign = 'right';
    displayCtx.fillStyle = '#94a3b8';
    displayCtx.font = '38px "Consolas", "Courier New", monospace';
    displayCtx.textBaseline = 'middle';
    displayCtx.fillText(currentExpression || '', w - 42, 160);

    // Main Huge Result Value (Ultra-Sharp White + Cyan Emissive)
    displayCtx.textAlign = 'right';
    displayCtx.fillStyle = '#ffffff';
    displayCtx.textBaseline = 'bottom';

    const resStr = currentResult || '0';
    if (resStr.length > 18) {
      displayCtx.font = 'bold 68px "Consolas", monospace';
    } else if (resStr.length > 12) {
      displayCtx.font = 'bold 88px "Consolas", monospace';
    } else {
      displayCtx.font = 'bold 118px "Consolas", monospace';
    }
    displayCtx.fillText(resStr, w - 42, 400);

    if (displayTexture) {
      displayTexture.needsUpdate = true;
    }
  }

  /**
   * Builds the entire 3D Calculator Mesh Model
   */
  function buildCalculator() {
    calculatorGroup = new THREE.Group();
    buttonMeshes.length = 0;

    // 1. Calculator Body Chassis (Solid dark satin metal)
    const bodyWidth = 9.4;
    const bodyLength = 14.8;
    const bodyHeight = 1.1;
    const cornerRadius = 0.6;

    const bodyShape = createRoundedRectShape(bodyWidth, bodyLength, cornerRadius);
    const extrudeSettings = {
      depth: bodyHeight,
      bevelEnabled: true,
      bevelSegments: 6,
      steps: 1,
      bevelSize: 0.16,
      bevelThickness: 0.16
    };

    const bodyGeo = new THREE.ExtrudeGeometry(bodyShape, extrudeSettings);
    bodyGeo.rotateX(Math.PI / 2);

    const bodyMaterial = new THREE.MeshStandardMaterial({
      color: 0x0a101d,
      roughness: 0.35,
      metalness: 0.85,
      envMapIntensity: 1.2
    });

    bodyMesh = new THREE.Mesh(bodyGeo, bodyMaterial);
    bodyMesh.castShadow = true;
    bodyMesh.receiveShadow = true;
    bodyMesh.position.y = -bodyHeight / 2;
    calculatorGroup.add(bodyMesh);

    // Inner Face Tray Frame
    const frameGeo = new THREE.BoxGeometry(bodyWidth - 0.4, 0.08, bodyLength - 0.4);
    const frameMat = new THREE.MeshStandardMaterial({
      color: 0x050912,
      roughness: 0.45,
      metalness: 0.9
    });
    frameMesh = new THREE.Mesh(frameGeo, frameMat);
    frameMesh.position.y = 0.04;
    frameMesh.receiveShadow = true;
    calculatorGroup.add(frameMesh);

    // 2. LCD Display 3D Screen
    initDisplayTexture();
    const screenWidth = 8.2;
    const screenHeight = 2.8;

    const screenBezelGeo = new THREE.BoxGeometry(screenWidth + 0.3, 0.12, screenHeight + 0.3);
    const screenBezelMat = new THREE.MeshStandardMaterial({
      color: 0x02050b,
      roughness: 0.2,
      metalness: 0.95
    });
    screenBezel = new THREE.Mesh(screenBezelGeo, screenBezelMat);
    screenBezel.position.set(0, 0.08, -5.1);
    calculatorGroup.add(screenBezel);

    const screenGeo = new THREE.PlaneGeometry(screenWidth, screenHeight);
    const screenMat = new THREE.MeshStandardMaterial({
      map: displayTexture,
      emissive: 0x00e5ff,
      emissiveMap: displayTexture,
      emissiveIntensity: 0.6,
      roughness: 0.15,
      metalness: 0.2
    });
    displayMesh = new THREE.Mesh(screenGeo, screenMat);
    displayMesh.rotateX(-Math.PI / 2);
    displayMesh.position.set(0, 0.15, -5.1);
    calculatorGroup.add(displayMesh);

    const glassGeo = new THREE.PlaneGeometry(screenWidth, screenHeight);
    const glassMat = new THREE.MeshPhysicalMaterial({
      color: 0xffffff,
      transparent: true,
      opacity: 0.15,
      roughness: 0.05,
      metalness: 0.1,
      transmission: 0.9,
      ior: 1.5
    });
    glassMesh = new THREE.Mesh(glassGeo, glassMat);
    glassMesh.rotateX(-Math.PI / 2);
    glassMesh.position.set(0, 0.17, -5.1);
    calculatorGroup.add(glassMesh);

    // 3. Keypad Matrix Construction

    // A) Row 0: Top Chassis Actions (HISTORIAL & ANÁLISIS - 2 wide buttons)
    const row0 = KEY_LAYOUT[0];
    const topBarCols = row0.length; // 2
    const topBtnWidth = 3.75;
    const topBtnLength = 0.88;
    const topBtnHeight = 0.32;
    const topGapX = 0.38;
    const topStartZ = -3.0;
    const totalTopWidth = topBarCols * topBtnWidth + (topBarCols - 1) * topGapX;
    const startTopX = -totalTopWidth / 2 + topBtnWidth / 2;

    for (let c = 0; c < topBarCols; c++) {
      const keyData = row0[c];
      const posX = startTopX + c * (topBtnWidth + topGapX);
      const posZ = topStartZ;

      const topGeo = new THREE.BoxGeometry(topBtnWidth, topBtnHeight, topBtnLength);
      const theme = THEMES[keyData.type] || THEMES.special_hist;
      // Pass exact width & length for 1:1 aspect ratio texturing
      const buttonTex = generateButtonTexture(keyData.display, keyData.type, topBtnWidth, topBtnLength);

      const sideMat = new THREE.MeshStandardMaterial({
        color: 0x080e18,
        roughness: 0.3,
        metalness: 0.8
      });

      const topMat = new THREE.MeshStandardMaterial({
        map: buttonTex,
        emissive: theme.emissive,
        emissiveMap: buttonTex,
        emissiveIntensity: theme.emissiveIntensity,
        roughness: 0.15,
        metalness: 0.4
      });

      const keyMesh = new THREE.Mesh(topGeo, [
        sideMat, sideMat, topMat, sideMat, sideMat, sideMat
      ]);
      keyMesh.castShadow = true;
      keyMesh.receiveShadow = true;
      keyMesh.position.set(posX, 0.22, posZ);

      keyMesh.userData = {
        label: keyData.label,
        type: keyData.type,
        sound: keyData.sound || 600,
        restY: 0.22,
        topMat: topMat,
        sideMat: sideMat
      };

      calculatorGroup.add(keyMesh);
      buttonMeshes.push(keyMesh);
    }

    // B) Rows 1 to 6: 5 Columns Matrix (Scientific, Operators, Numbers)
    const standardRows = KEY_LAYOUT.length - 1; // 6
    const standardCols = 5;

    const btnWidth = 1.38;
    const btnLength = 1.06;
    const btnHeight = 0.36;
    const gapX = 0.24;
    const gapZ = 0.22;

    const startZ = -1.8;
    const totalMatrixWidth = standardCols * btnWidth + (standardCols - 1) * gapX;
    const startX = -totalMatrixWidth / 2 + btnWidth / 2;

    for (let r = 1; r <= standardRows; r++) {
      for (let c = 0; c < standardCols; c++) {
        const keyData = KEY_LAYOUT[r][c];
        const posX = startX + c * (btnWidth + gapX);
        const posZ = startZ + (r - 1) * (btnLength + gapZ);

        const keyGeo = new THREE.BoxGeometry(btnWidth, btnHeight, btnLength);
        const theme = THEMES[keyData.type] || THEMES.num;
        // Pass exact width & length for 1:1 aspect ratio texturing
        const buttonTex = generateButtonTexture(keyData.display || keyData.label, keyData.type, btnWidth, btnLength);

        const sideMat = new THREE.MeshStandardMaterial({
          color: 0x080e18,
          roughness: 0.3,
          metalness: 0.8
        });

        const topMat = new THREE.MeshStandardMaterial({
          map: buttonTex,
          emissive: theme.emissive,
          emissiveMap: buttonTex,
          emissiveIntensity: theme.emissiveIntensity,
          roughness: 0.15,
          metalness: 0.4
        });

        const keyMesh = new THREE.Mesh(keyGeo, [
          sideMat, sideMat, topMat, sideMat, sideMat, sideMat
        ]);
        keyMesh.castShadow = true;
        keyMesh.receiveShadow = true;
        keyMesh.position.set(posX, 0.24, posZ);

        keyMesh.userData = {
          label: keyData.label,
          type: keyData.type,
          sound: keyData.sound || 500,
          restY: 0.24,
          topMat: topMat,
          sideMat: sideMat
        };

        calculatorGroup.add(keyMesh);
        buttonMeshes.push(keyMesh);
      }
    }

    calculatorGroup.rotation.x = THREE.MathUtils.degToRad(-5.5);
    calculatorGroup.position.y = 0.3;

    scene.add(calculatorGroup);

    // Floor Surface with subtle grid
    const floorGeo = new THREE.PlaneGeometry(80, 80);
    const floorMat = new THREE.MeshStandardMaterial({
      color: 0x04070e,
      roughness: 0.6,
      metalness: 0.4
    });
    const floorMesh = new THREE.Mesh(floorGeo, floorMat);
    floorMesh.rotateX(-Math.PI / 2);
    floorMesh.position.y = -0.8;
    floorMesh.receiveShadow = true;
    scene.add(floorMesh);

    const grid = new THREE.GridHelper(50, 50, 0x00e5ff, 0x0e1b2f);
    grid.position.y = -0.79;
    scene.add(grid);
  }

  /**
   * Setup Studio Quality Lighting
   */
  function setupLighting() {
    const ambientLight = new THREE.AmbientLight(0x475569, 1.4);
    scene.add(ambientLight);

    const keyLight = new THREE.DirectionalLight(0xffffff, 1.8);
    keyLight.position.set(6, 20, 14);
    keyLight.castShadow = true;
    keyLight.shadow.mapSize.width = 2048;
    keyLight.shadow.mapSize.height = 2048;
    keyLight.shadow.camera.near = 0.5;
    keyLight.shadow.camera.far = 45;
    keyLight.shadow.camera.left = -10;
    keyLight.shadow.camera.right = 10;
    keyLight.shadow.camera.top = 10;
    keyLight.shadow.camera.bottom = -10;
    keyLight.shadow.bias = -0.0005;
    scene.add(keyLight);

    const cyanRim = new THREE.PointLight(0x00e5ff, 2.5, 30);
    cyanRim.position.set(-10, 8, -4);
    scene.add(cyanRim);

    const pinkRim = new THREE.PointLight(0xff007f, 2.2, 30);
    pinkRim.position.set(10, 7, 8);
    scene.add(pinkRim);

    const fillLight = new THREE.DirectionalLight(0x7dd3fc, 0.8);
    fillLight.position.set(0, 12, 16);
    scene.add(fillLight);
  }

  /**
   * Physical Key Press Spring Animation using TWEEN.js
   */
  function animateKeyPress(mesh) {
    if (!mesh || !mesh.userData) return;
    const restY = mesh.userData.restY;
    const targetY = restY - 0.16;

    playKeyBeep(mesh.userData.sound);

    const topMat = mesh.userData.topMat;
    const origEmissive = topMat ? topMat.emissiveIntensity : 0.2;
    if (topMat) {
      topMat.emissiveIntensity = 1.2;
    }

    if (window.TWEEN) {
      new TWEEN.Tween(mesh.position)
        .to({ y: targetY }, 50)
        .easing(TWEEN.Easing.Quadratic.Out)
        .onComplete(() => {
          new TWEEN.Tween(mesh.position)
            .to({ y: restY }, 180)
            .easing(TWEEN.Easing.Back.Out)
            .start();

          if (topMat) {
            new TWEEN.Tween({ intensity: 1.2 })
              .to({ intensity: origEmissive }, 220)
              .onUpdate((obj) => {
                topMat.emissiveIntensity = obj.intensity;
              })
              .start();
          }
        })
        .start();
    } else {
      mesh.position.y = targetY;
      setTimeout(() => {
        mesh.position.y = restY;
        if (topMat) topMat.emissiveIntensity = origEmissive;
      }, 100);
    }
  }

  let lastTriggerTime = 0;
  let lastTriggerKey = '';

  /**
   * Triggers key press programmatically and dispatches to Dart
   */
  function triggerKey(label) {
    const now = Date.now();
    if (now - lastTriggerTime < 140 && lastTriggerKey === label) {
      return;
    }
    lastTriggerTime = now;
    lastTriggerKey = label;

    const mesh = buttonMeshes.find((m) => m.userData.label === label);
    if (mesh) {
      animateKeyPress(mesh);
    }

    if (label === 'CENTER' || label === 'CENTRAR') {
      window.resetCalculator3DCamera();
    }

    // Notify Dart Bridge
    if (typeof window.onCalculator3DKeyPress === 'function') {
      window.onCalculator3DKeyPress(label);
    }

    window.dispatchEvent(
      new CustomEvent('calculator-3d-key', { detail: { key: label } })
    );
  }

  /**
   * Raycast Mouse/Pointer Intersections
   */
  function handlePointerRaycast(clientX, clientY) {
    if (!containerElement || !camera || !renderer) return false;

    const rect = renderer.domElement.getBoundingClientRect();
    if (
      clientX < rect.left ||
      clientX > rect.right ||
      clientY < rect.top ||
      clientY > rect.bottom
    ) {
      return false;
    }

    mouse.x = ((clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(buttonMeshes, true);

    if (intersects.length > 0) {
      let hitMesh = intersects[0].object;
      while (hitMesh && !hitMesh.userData.label && hitMesh.parent) {
        hitMesh = hitMesh.parent;
      }

      if (hitMesh && hitMesh.userData.label) {
        triggerKey(hitMesh.userData.label);
        return true;
      }
    }
    return false;
  }

  function onPointerDown(event) {
    handlePointerRaycast(event.clientX, event.clientY);
  }

  function onPointerMove(event) {
    if (!containerElement || !camera || !renderer) return;

    const rect = renderer.domElement.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(buttonMeshes, true);

    if (intersects.length > 0) {
      document.body.style.cursor = 'pointer';
      if (containerElement) containerElement.style.cursor = 'pointer';
    } else {
      document.body.style.cursor = 'default';
      if (containerElement) containerElement.style.cursor = 'default';
    }
  }

  /**
   * Global Keyboard Listener
   */
  function onKeyDown(event) {
    const key = event.key;

    if (key >= '0' && key <= '9') {
      triggerKey(key);
      event.preventDefault();
    } else if (key === '.' || key === ',') {
      triggerKey('.');
      event.preventDefault();
    } else if (key === '+' || key === '-' || key === '*' || key === '/') {
      triggerKey(key);
      event.preventDefault();
    } else if (key === 'Enter' || key === '=') {
      triggerKey('=');
      event.preventDefault();
    } else if (key === 'Backspace') {
      triggerKey('DEL');
      event.preventDefault();
    } else if (key === 'Escape' || key.toUpperCase() === 'C') {
      triggerKey('AC');
      event.preventDefault();
    } else if (key === '(' || key === ')') {
      triggerKey(key);
      event.preventDefault();
    } else if (key === '%') {
      triggerKey('%');
      event.preventDefault();
    } else if (key === '^') {
      triggerKey('^');
      event.preventDefault();
    }
  }

  function onWindowResize() {
    if (!containerElement || !camera || !renderer) return;

    const width = containerElement.clientWidth || window.innerWidth;
    const height = containerElement.clientHeight || window.innerHeight;

    camera.aspect = width / height;
    camera.updateProjectionMatrix();
    renderer.setSize(width, height);
  }

  /**
   * Main Render Loop
   */
  function animate(time) {
    animationFrameId = requestAnimationFrame(animate);

    if (window.TWEEN) {
      TWEEN.update(time);
    }

    if (controls) {
      controls.update();
    }

    if (renderer && scene && camera) {
      renderer.render(scene, camera);
    }
  }

  /**
   * Initializes the 3D Engine in a target DOM container
   */
  function initEngine(target) {
    if (typeof THREE === 'undefined') {
      setTimeout(() => initEngine(target), 50);
      return;
    }

    if (!target) {
      target = document.getElementById('threejs-canvas-wrapper') ||
               document.getElementById('threejs-container');
    }

    if (typeof target === 'string') {
      containerElement = document.getElementById(target);
      if (!containerElement) {
        setTimeout(() => initEngine(target), 60);
        return;
      }
    } else if (target && (target instanceof HTMLElement || target.nodeType === 1)) {
      containerElement = target;
    }

    if (!containerElement) {
      setTimeout(() => initEngine(target), 60);
      return;
    }

    if (isInitialized) {
      onWindowResize();
      return;
    }

    let width = containerElement.clientWidth;
    let height = containerElement.clientHeight;

    if (!width || !height || width === 0 || height === 0) {
      width = window.innerWidth;
      height = window.innerHeight;
    }

    // 1. Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x060911);
    scene.fog = new THREE.FogExp2(0x060911, 0.03);

    // 2. Camera: Positioned for straight, clear, un-distorted view
    camera = new THREE.PerspectiveCamera(38, width / height, 0.1, 100);
    camera.position.set(0, 15.2, 11.2);

    // 3. Renderer with High Performance & Antialiasing
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false, powerPreference: 'high-performance' });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.15;

    while (containerElement.firstChild) {
      containerElement.removeChild(containerElement.firstChild);
    }
    containerElement.appendChild(renderer.domElement);

    // 4. Orbit Controls with Damping
    if (typeof THREE.OrbitControls !== 'undefined') {
      controls = new THREE.OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true;
      controls.dampingFactor = 0.06;
      controls.minDistance = 6;
      controls.maxDistance = 28;
      controls.maxPolarAngle = Math.PI / 2.05;
      controls.target.set(0, 0, 0);
    }

    // 5. Lighting & 3D Model
    setupLighting();
    buildCalculator();

    // 6. Event Listeners
    renderer.domElement.addEventListener('pointerdown', onPointerDown, false);
    renderer.domElement.addEventListener('pointermove', onPointerMove, false);
    window.addEventListener('keydown', onKeyDown, false);
    window.addEventListener('resize', onWindowResize, false);

    if (window.ResizeObserver) {
      const ro = new ResizeObserver(() => onWindowResize());
      ro.observe(containerElement);
    }

    isInitialized = true;
    animate();

    console.log('✔ Sumadora Chava 3D Engine Initialized with Razor-Sharp Typography');
  }

  // --- Public API for Dart <-> JS Interoperability ---

  window.initCalculator3D = function (target) {
    initEngine(target);
  };

  window.updateCalculator3DDisplay = function (expression, result, status) {
    drawLCDDisplay(expression, result, status);
  };

  window.pressCalculator3DKey = function (keyLabel) {
    triggerKey(keyLabel);
  };

  window.resetCalculator3DCamera = function () {
    if (camera && controls) {
      if (window.TWEEN) {
        new TWEEN.Tween(camera.position)
          .to({ x: 0, y: 15.2, z: 11.2 }, 600)
          .easing(TWEEN.Easing.Cubic.Out)
          .onUpdate(() => {
            if (controls) controls.update();
          })
          .start();
        new TWEEN.Tween(controls.target)
          .to({ x: 0, y: 0, z: 0 }, 600)
          .easing(TWEEN.Easing.Cubic.Out)
          .onUpdate(() => {
            if (controls) controls.update();
          })
          .onComplete(() => {
            if (controls) controls.update();
          })
          .start();
      } else {
        camera.position.set(0, 15.2, 11.2);
        controls.target.set(0, 0, 0);
        controls.update();
      }
    }
  };

  window.toggleCalculator3DAutoRotate = function () {
    if (controls) {
      controls.autoRotate = !controls.autoRotate;
      controls.autoRotateSpeed = 2.0;
    }
  };
})();
