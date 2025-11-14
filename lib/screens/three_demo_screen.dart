// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter/gestures.dart'; // Unused import
// // import 'package:flutter_gl/flutter_gl.dart'; // Temporarily disabled
// // import 'package:three_dart/three_dart.dart' as three; // Temporarily disabled
// // import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm; // Temporarily disabled
//
// class MiscControlsMap extends StatefulWidget {
//   final String fileName;
//
//   const MiscControlsMap({Key? key, required this.fileName}) : super(key: key);
//
//   @override
//   State<MiscControlsMap> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MiscControlsMap> {
//   late FlutterGlPlugin three3dRender;
//   three.WebGLRenderer? renderer;
//
//   int? fboId;
//   late double width;
//   late double height;
//
//   Size? screenSize;
//
//   late three.Scene scene;
//   late three.Camera camera;
//   late three.Mesh mesh;
//
//   double dpr = 1.0;
//
//   var amount = 4;
//
//   bool verbose = true;
//   bool disposed = false;
//
//   late three.WebGLRenderTarget renderTarget;
//
//   dynamic sourceTexture;
//
//   final GlobalKey<three_jsm.DomLikeListenableState> _globalKey =
//       GlobalKey<three_jsm.DomLikeListenableState>();
//
//   late three_jsm.MapControls controls;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Future<void> initPlatformState() async {
//     width = screenSize!.width;
//     height = screenSize!.height - 60;
//
//     three3dRender = FlutterGlPlugin();
//
//     Map<String, dynamic> options = {
//       "antialias": true,
//       "alpha": false,
//       "width": width.toInt(),
//       "height": height.toInt(),
//       "dpr": dpr,
//     };
//
//     await three3dRender.initialize(options: options);
//
//     setState(() {});
//
//     Future.delayed(const Duration(milliseconds: 100), () async {
//       await three3dRender.prepareContext();
//
//       initScene();
//     });
//   }
//
//   initSize(BuildContext context) {
//     if (screenSize != null) {
//       return;
//     }
//
//     final mqd = MediaQuery.of(context);
//
//     screenSize = mqd.size;
//     dpr = mqd.devicePixelRatio;
//
//     initPlatformState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.fileName)),
//       body: Builder(
//         builder: (BuildContext context) {
//           initSize(context);
//           return SingleChildScrollView(child: _build(context));
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Text("render"),
//         onPressed: () {
//           render();
//         },
//       ),
//     );
//   }
//
//   Widget _build(BuildContext context) {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             three_jsm.DomLikeListenable(
//               key: _globalKey,
//               builder: (BuildContext context) {
//                 return Container(
//                   width: width,
//                   height: height,
//                   color: Colors.black,
//                   child: Builder(
//                     builder: (BuildContext context) {
//                       if (kIsWeb) {
//                         return three3dRender.isInitialized
//                             ? HtmlElementView(
//                               viewType: three3dRender.textureId!.toString(),
//                             )
//                             : Container();
//                       } else {
//                         return three3dRender.isInitialized
//                             ? Texture(textureId: three3dRender.textureId!)
//                             : Container();
//                       }
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   render() {
//     int t = DateTime.now().millisecondsSinceEpoch;
//     final gl = three3dRender.gl;
//
//     controls.update();
//
//     renderer!.render(scene, camera);
//
//     int t1 = DateTime.now().millisecondsSinceEpoch;
//
//     if (verbose) {
//       // ignore: avoid_print
//       print("render cost: ${t1 - t} ");
//       // ignore: avoid_print
//       print(renderer!.info.memory);
//       // ignore: avoid_print
//       print(renderer!.info.render);
//     }
//
//     gl.flush();
//
//     if (verbose) {
//       // ignore: avoid_print
//       print(" render: sourceTexture: $sourceTexture ");
//     }
//
//     if (!kIsWeb) {
//       three3dRender.updateTexture(sourceTexture);
//     }
//   }
//
//   initRenderer() {
//     Map<String, dynamic> options = {
//       "width": width,
//       "height": height,
//       "gl": three3dRender.gl,
//       "antialias": true,
//       "canvas": three3dRender.element,
//     };
//     renderer = three.WebGLRenderer(options);
//     renderer!.setPixelRatio(dpr);
//     renderer!.setSize(width, height, false);
//     renderer!.shadowMap.enabled = false;
//
//     if (!kIsWeb) {
//       var pars = three.WebGLRenderTargetOptions({
//         "minFilter": three.LinearFilter,
//         "magFilter": three.LinearFilter,
//         "format": three.RGBAFormat,
//       });
//       renderTarget = three.WebGLRenderTarget(
//         (width * dpr).toInt(),
//         (height * dpr).toInt(),
//         pars,
//       );
//       renderTarget.samples = 4;
//       renderer!.setRenderTarget(renderTarget);
//       sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
//     }
//   }
//
//   initScene() {
//     initRenderer();
//     initPage();
//   }
//
//   initPage() {
//     scene = three.Scene();
//     scene.background = three.Color(0xcccccc);
//     scene.fog = three.FogExp2(0xcccccc, 0.002);
//
//     camera = three.PerspectiveCamera(60, width / height, 1, 1000);
//     camera.position.set(400, 200, 0);
//     camera.lookAt(scene.position);
//
//     // controls
//     controls = three_jsm.MapControls(camera, _globalKey);
//     controls.enableDamping = true;
//     controls.dampingFactor = 0.05;
//     controls.screenSpacePanning = false;
//     controls.minDistance = 100;
//     controls.maxDistance = 500;
//     controls.maxPolarAngle = three.Math.pi / 2;
//     // Disable zoom so mouse wheel scroll passes through and doesn't dolly
//     controls.enableZoom = false;
//
//     // world
//     var geometry = three.BoxGeometry(1, 1, 1);
//     geometry.translate(0, 0.5, 0);
//     var material = three.MeshPhongMaterial({
//       'color': 0xff535353,
//       'flatShading': true,
//     });
//
//     for (var i = 0; i < 500; i++) {
//       var mesh = three.Mesh(geometry, material);
//       mesh.position.x = three.Math.random() * 1600 - 800;
//       mesh.position.y = 0;
//       mesh.position.z = three.Math.random() * 1600 - 800;
//       mesh.scale.x = 20;
//       mesh.scale.y = three.Math.random() * 80 + 10;
//       mesh.scale.z = 20;
//       mesh.updateMatrix();
//       mesh.matrixAutoUpdate = false;
//       scene.add(mesh);
//     }
//
//     // lights
//     var dirLight1 = three.DirectionalLight(0xffffff);
//     dirLight1.position.set(1, 1, 1);
//     scene.add(dirLight1);
//
//     var dirLight2 = three.DirectionalLight(0x002288);
//     dirLight2.position.set(-1, -1, -1);
//     scene.add(dirLight2);
//
//     var ambientLight = three.AmbientLight(0x222222);
//     scene.add(ambientLight);
//
//     animate();
//   }
//
//   animate() {
//     if (!mounted || disposed) {
//       return;
//     }
//
//     render();
//
//     Future.delayed(const Duration(milliseconds: 40), () {
//       animate();
//     });
//   }
//
//   @override
//   void dispose() {
//     disposed = true;
//     three3dRender.dispose();
//     super.dispose();
//   }
// }
//
// class ThreeBackground extends StatefulWidget {
//   final ValueListenable<double>? scrollOffset;
//   const ThreeBackground({super.key, this.scrollOffset});
//
//   @override
//   State<ThreeBackground> createState() => _ThreeBackgroundState();
// }
//
// class _ThreeBackgroundState extends State<ThreeBackground> {
//   late FlutterGlPlugin three3dRender;
//   three.WebGLRenderer? renderer;
//   Size? screenSize;
//   late double width;
//   late double height;
//   double dpr = 1.0;
//
//   late three.Scene scene;
//   late three.Camera camera;
//   late three.WebGLRenderTarget renderTarget;
//   dynamic sourceTexture;
//   bool disposed = false;
//
//   // Interaction support
//   final GlobalKey<three_jsm.DomLikeListenableState> _bgKey =
//       GlobalKey<three_jsm.DomLikeListenableState>();
//   late three_jsm.MapControls _controls;
//   double _scrollRotation = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.scrollOffset?.addListener(_onScrollChanged);
//   }
//
//   @override
//   void didUpdateWidget(covariant ThreeBackground oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.scrollOffset != widget.scrollOffset) {
//       oldWidget.scrollOffset?.removeListener(_onScrollChanged);
//       widget.scrollOffset?.addListener(_onScrollChanged);
//     }
//   }
//
//   void _onScrollChanged() {
//     final v = widget.scrollOffset?.value ?? 0.0;
//     _scrollRotation = v * 0.0005; // map offset to rotation
//   }
//
//   Future<void> _init() async {
//     width = screenSize!.width;
//     height = screenSize!.height;
//
//     three3dRender = FlutterGlPlugin();
//     await three3dRender.initialize(
//       options: {
//         'antialias': true,
//         'alpha': true,
//         'width': width.toInt(),
//         'height': height.toInt(),
//         'dpr': dpr,
//       },
//     );
//     setState(() {});
//     Future.delayed(const Duration(milliseconds: 100), () async {
//       await three3dRender.prepareContext();
//       _initScene();
//     });
//   }
//
//   void _initScene() {
//     // renderer
//     renderer = three.WebGLRenderer({
//       'width': width,
//       'height': height,
//       'gl': three3dRender.gl,
//       'antialias': true,
//       'canvas': three3dRender.element,
//     });
//     renderer!.setPixelRatio(dpr);
//     renderer!.setSize(width, height, false);
//
//     // scene & camera
//     scene = three.Scene();
//     scene.background = three.Color(0x111111);
//     camera = three.PerspectiveCamera(60, width / height, 1, 1000);
//     camera.position.set(400, 200, 300);
//     camera.lookAt(scene.position);
//
//     // Controls (rotate/pan only; no zoom so page scroll remains normal)
//     _controls = three_jsm.MapControls(camera, _bgKey);
//     _controls.enableZoom = false;
//     _controls.enableDamping = true;
//     _controls.dampingFactor = 0.05;
//
//     // content
//     final geometry = three.BoxGeometry(1, 1, 1)..translate(0, 0.5, 0);
//     final material = three.MeshPhongMaterial({
//       'color': 0x444444,
//       'flatShading': true,
//     });
//     for (var i = 0; i < 400; i++) {
//       final m = three.Mesh(geometry, material);
//       m.position.x = three.Math.random() * 1600 - 800;
//       m.position.y = 0;
//       m.position.z = three.Math.random() * 1600 - 800;
//       m.scale.set(20, three.Math.random() * 80 + 10, 20);
//       m.updateMatrix();
//       m.matrixAutoUpdate = false;
//       scene.add(m);
//     }
//     scene.add(three.DirectionalLight(0xffffff)..position.set(1, 1, 1));
//     scene.add(three.DirectionalLight(0x002288)..position.set(-1, -1, -1));
//     scene.add(three.AmbientLight(0x222222));
//
//     _animate();
//   }
//
//   void _animate() {
//     if (!mounted || disposed) return;
//     // drive rotation by scroll offset mapping
//     if (_scrollRotation.sign == 0.0) {
//       scene.rotation.y += 0.002;
//     } else {
//       scene.rotation.y = _scrollRotation;
//     }
//     _controls.update();
//     renderer!.render(scene, camera);
//     if (!kIsWeb) three3dRender.updateTexture(sourceTexture);
//     three3dRender.gl.flush();
//     Future.delayed(const Duration(milliseconds: 40), _animate);
//   }
//
//   void _initSize(BuildContext context) {
//     if (screenSize != null) return;
//     final mqd = MediaQuery.of(context);
//     screenSize = mqd.size;
//     dpr = mqd.devicePixelRatio;
//     _init();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _initSize(context);
//     return three_jsm.DomLikeListenable(
//       key: _bgKey,
//       builder: (context) {
//         return Container(
//           width: double.infinity,
//           height: double.infinity,
//           child:
//               kIsWeb
//                   ? (three3dRender.isInitialized
//                       ? HtmlElementView(
//                         viewType: three3dRender.textureId!.toString(),
//                       )
//                       : const SizedBox())
//                   : (three3dRender.isInitialized
//                       ? Texture(textureId: three3dRender.textureId!)
//                       : const SizedBox()),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     disposed = true;
//     widget.scrollOffset?.removeListener(_onScrollChanged);
//     three3dRender.dispose();
//     super.dispose();
//   }
// }
