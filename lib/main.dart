import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pose_overlay.dart';
import 'pose_controller.dart';

// DB Setup file that helps with setting up the db
import 'database/database_helper.dart';

// Repositories Path
import 'database/repositories/user_repository.dart';
import 'database/repositories/exercise_repository.dart';
import 'database/repositories/reference_frame_repository.dart';
import 'database/repositories/session_repository.dart';
import 'database/repositories/session_frame_repository.dart';
import 'database/repositories/session_performance_metrics_repository.dart';

// Services Path
import 'servicesbackend/auth_service.dart';
import 'servicesbackend/exercise_service.dart';
import 'servicesbackend/session_service.dart';

// Controllers Path
import 'controllers/auth_controller.dart';
import 'controllers/exercise_controller.dart';
import 'controllers/session_controller.dart';

// Importing Metrics Tracker
import 'utils/metrics_tracker.dart';

late List<CameraDescription> cameras;

// services
late AuthService authService;
late ExerciseService exerciseService;
late SessionService sessionService;

// Controller
late AuthController authController;
late ExerciseController exerciseController;
late SessionController sessionController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reset metrics after each run
  MetricsTracker.instance.reset();

  // Intialize database and repo
  final db = await DatabaseHelper.instance.database;

  
  // Repo are what directly talk or modify the database
  // So any manipulation of the database is done via repo

  // Repos for the 5 main tables of the database
  final userRepo = UserRepository(db);
  final exerciseRepo = ExerciseRepository(db);
  final refRepo = ReferenceFrameRepository(db);
  final sessionRepo = SessionRepository(db);
  final sessionFrameRepo = SessionFrameRepository(db);

  // Repo for the metrics that were added later
  final sessionMetricsRepo = SessionPerformanceMetricsRepository(db);

  // Initialize services
  authService = AuthService(userRepo);
  exerciseService = ExerciseService(db, exerciseRepo, refRepo);

  // So bascially this is the format of things that interact witht he backend - service
  // This is the format that is used to compare it to the excerise refrence frames
  // In order to calculate the accuracy, between both session frames and refrence frames.
  sessionService = SessionService(
    exerciseRepo,
    refRepo,
    sessionRepo,
    sessionFrameRepo,
    sessionMetricsRepo,
    pipelineVersion: 'v1_baseline',
  );

  // Initialize controllers
  authController = AuthController(authService);
  exerciseController = ExerciseController(exerciseService);
  sessionController = SessionController(sessionService);

  // Camera setup
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
