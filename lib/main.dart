import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Pose
import 'features/pose/widgets/pose_overlay.dart';
import 'features/pose/pose_controller.dart'; 

// DB setup
import 'database/database_helper.dart';

// repositories
import 'database/repositories.dart';

// services
import 'features/auth/auth_service.dart';
import 'features/exercise/exercise_service.dart';
import 'services/system_metrics_service.dart';

// controllers
import 'features/auth/auth_controller.dart';
import 'features/exercise/exercise_controller.dart';

// metrics
import 'core/metrics_tracker.dart';

// pages
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/sign_up.dart';

// ───────── GLOBALS ─────────

late List<CameraDescription> cameras;

// services
late AuthService authService;
late ExerciseService exerciseService;
late SystemMetricsService systemMetricsService;

// controllers
late AuthController authController;
late ExerciseController exerciseController;
late PoseController poseController;

// ───────── MAIN ─────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reset metrics after each run
  MetricsTracker.instance.reset();

  // Initialize database
  final db = await DatabaseHelper.instance.database;

  // Repositories
  final userRepo = UserRepository(db);
  final exerciseRepo = ExerciseRepository(db);
  final systemMetricsRepo = SystemMetricsRepository(db);

  // Services
  authService = AuthService(userRepo);
  exerciseService = ExerciseService(exerciseRepo);
  systemMetricsService = SystemMetricsService(systemMetricsRepo);

  // Controllers
  authController = AuthController(authService);
  exerciseController = ExerciseController(exerciseService);

  // Camera + Pose controller
  cameras = await availableCameras();
  poseController = PoseController(cameras.first);
  await poseController.initialize(); // starts camera + pose detector

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: authController.isLoggedIn ? '/pose' : '/',
      routes: {
        '/': (context) => LoginScreen(authController: authController),
        '/signup': (context) => SignUpScreen(authController: authController),
        '/pose': (context) => const PosePage(),
      },
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

  bool _isRecording = false;
  final TextEditingController _feedbackController = TextEditingController();

  static const _lime = Color(0xFFB4FF3C);
  static const _bg = Color(0xFF0D0D0D);

  @override
  void initState() {
    super.initState();
    _controller = poseController;
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
  
      setState(() => _isRecording = false);

      // Build a PoseSequence from the frames collected in PoseController
      final sequence = _controller.stopRecording();

      // For now, just log it; later you’ll POST sequence.toJsonString() to your endpoint
      debugPrint(sequence.toString());
      debugPrint('JSON length: ${sequence.toJsonString().length}');
      debugPrint('Feedback: ${_feedbackController.text}');
    } else {
      _controller.startRecording();
      setState(() => _isRecording = true);
      debugPrint('Recording started');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cam = _controller.cameraController;

    if (cam == null || !cam.value.isInitialized) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final previewSize = cam.value.previewSize!;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomPaint(
            painter: _GridPainter(),
            size: MediaQuery.of(context).size,
          ),
          Positioned(
            top: -60,
            left: -60,
            child: _Orb(color: _lime.withValues(alpha: 0.09), size: 420),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: _Orb(
              color: const Color(0xFFFF641E).withValues(alpha: 0.08),
              size: 380,
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFB4FF3C),
                              Color(0xFF7ECF00),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _lime.withValues(alpha: 0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Color(0xFF0D0D0D),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                              colors: [Colors.white, Color(0x66FFFFFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'Pose Coach',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'LIVE FORM ANALYSIS',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
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
                              // LIVE badge
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent
                                        .withValues(alpha: 0.85),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
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
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SectionLabel('SESSION CONTROLS'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: _isRecording
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B6B),
                                      Color(0xFFFF3B3B),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFB4FF3C),
                                      Color(0xFF89D400),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording
                                        ? Colors.redAccent
                                        : _lime)
                                    .withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: _toggleRecording,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: Icon(
                              _isRecording
                                  ? Icons.stop_rounded
                                  : Icons.fiber_manual_record_rounded,
                              color: const Color(0xFF0D0D0D),
                              size: 18,
                            ),
                            label: Text(
                              _isRecording
                                  ? 'FINISH RECORDING'
                                  : 'START RECORDING',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D0D0D),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _SectionLabel('FEEDBACK'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xE0FFFFFF),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Write quick notes about this set (e.g., back rounded, knees tracking in)...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.26),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.35),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double size;

  const _Orb({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB4FF3C).withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const step = 48.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}