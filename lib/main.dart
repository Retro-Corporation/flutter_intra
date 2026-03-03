import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pose_overlay.dart';
import 'pose_controller.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PosePage(),
    );
  }
}

class PosePage extends StatefulWidget {
  const PosePage({super.key});

  @override
  State<PosePage> createState() => _PosePageState();
}

class _PosePageState extends State<PosePage> {
  late final PoseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PoseController(cameras.first);
    _controller.addListener(_onUpdate);
    _controller.initialize();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.disposeController();
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cam = _controller.cameraController;

    if (cam == null || !cam.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final previewSize = cam.value.previewSize!;

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: cam.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(cam),
              if (_controller.landmarks != null)
                PoseOverlay(
                  landmarks: _controller.landmarks!,
                  previewSize: previewSize,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
