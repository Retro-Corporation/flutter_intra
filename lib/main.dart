import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';

// ✅ DB helper
import 'database/database_helper.dart';

// ✅ Repositories
import 'database/repositories/user_repository.dart';
import 'database/repositories/exercise_repository.dart';
import 'database/repositories/reference_frame_repository.dart';
import 'database/repositories/session_repository.dart';
import 'database/repositories/session_frame_repository.dart';
import 'database/repositories/session_performance_metrics_repository.dart';

// ✅ Services
import 'servicesbackend/auth_service.dart';
import 'servicesbackend/exercise_service.dart';
import 'servicesbackend/session_service.dart';

// ✅ Controllers
import 'controllers/auth_controller.dart';
import 'controllers/exercise_controller.dart';
import 'controllers/session_controller.dart';

// ✅ Metrics (canonical location)
import 'utils/metrics_tracker.dart';

late List<CameraDescription> cameras;

// ✅ Services (global for MVP)
late AuthService authService;
late ExerciseService exerciseService;
late SessionService sessionService;

// ✅ Controllers (global for MVP)
late AuthController authController;
late ExerciseController exerciseController;
late SessionController sessionController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Reset metrics each run (optional but recommended)
  MetricsTracker.instance.reset();

  // ✅ Initialize SQLite database (Flutter mobile)
  final db = await DatabaseHelper.instance.database;

  // ✅ Initialize repositories
  final userRepo = UserRepository(db);
  final exerciseRepo = ExerciseRepository(db);
  final refRepo = ReferenceFrameRepository(db);
  final sessionRepo = SessionRepository(db);
  final sessionFrameRepo = SessionFrameRepository(db);

  // ✅ NEW: persisted metrics repo
  final sessionMetricsRepo = SessionPerformanceMetricsRepository(db);

  // ✅ Initialize services
  authService = AuthService(userRepo);
  exerciseService = ExerciseService(db, exerciseRepo, refRepo);

  // ✅ UPDATED: SessionService now takes metrics repo + optional pipelineVersion
  sessionService = SessionService(
    exerciseRepo,
    refRepo,
    sessionRepo,
    sessionFrameRepo,
    sessionMetricsRepo,
    pipelineVersion: 'v1_baseline',
  );

  // ✅ Initialize controllers
  authController = AuthController(authService);
  exerciseController = ExerciseController(exerciseService);
  sessionController = SessionController(sessionService);

  // ✅ Camera setup
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

// --- your PosePage code stays the same below ---
class PosePage extends StatefulWidget {
  const PosePage({super.key});

  @override
  State<PosePage> createState() => _PosePageState();
}

class _PosePageState extends State<PosePage> {
  CameraController? _cameraController;
  final NpuPoseDetector _detector = NpuPoseDetector();

  bool _isProcessing = false;
  List<PoseLandmark>? _landmarks;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _detector.initialize();

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processCameraImage);

    setState(() {});
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || !_detector.isInitialized) return;
    _isProcessing = true;

    try {
      final planes = image.planes
          .map(
            (p) => {
              'bytes': p.bytes,
              'bytesPerRow': p.bytesPerRow,
              'bytesPerPixel': p.bytesPerPixel,
            },
          )
          .toList();

      final result = await _detector.processFrame(
        planes: planes,
        width: image.width,
        height: image.height,
        format: 'yuv420',
        rotation: _cameraController!.description.sensorOrientation,
      );

      if (result.hasPoses) {
        final pose = result.firstPose!;
        setState(() {
          _landmarks = pose.landmarks;
        });
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          if (_landmarks != null)
            CustomPaint(
              painter: PosePainter(
                _landmarks!,
                _cameraController!.value.previewSize!,
              ),
              size: Size.infinite,
            ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<PoseLandmark> landmarks;
  final Size imageSize;

  PosePainter(this.landmarks, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;

    for (final landmark in landmarks) {
      final dx = landmark.x * size.width;
      final dy = landmark.y * size.height;
      canvas.drawCircle(Offset(dx, dy), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}