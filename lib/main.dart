import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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

// Import Pages
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/sign_up.dart';

late List<CameraDescription> cameras;

// services
late AuthService authService;
late ExerciseService exerciseService;
late SystemMetricsService systemMetricsService;

// controllers
late AuthController authController;
late ExerciseController exerciseController;
late PoseController poseController;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reset metrics after each run
  MetricsTracker.instance.reset();

  // Intialize database and repo
  final db = await DatabaseHelper.instance.database;

  
  // Repo are what directly talk or modify the database
  // So any manipulation of the database is done via repo

// Repositories for database tables
final userRepo = UserRepository(db);
final exerciseRepo = ExerciseRepository(db);
final systemMetricsRepo = SystemMetricsRepository(db);

// Initialize services
authService = AuthService(userRepo);
exerciseService = ExerciseService(exerciseRepo);
systemMetricsService = SystemMetricsService(systemMetricsRepo);

  // So bascially this is the format of things that interact witht he backend - service
  // This is the format that is used to compare it to the excerise refrence frames
  // In order to calculate the accuracy, between both session frames and refrence frames.

// Initialize services
authService = AuthService(userRepo);
exerciseService = ExerciseService(exerciseRepo);
systemMetricsService = SystemMetricsService(systemMetricsRepo);

// Initialize controllers
authController = AuthController(authService);
exerciseController = ExerciseController(exerciseService);


  // Camera setup
  cameras = await availableCameras();

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
class 
PosePage extends StatefulWidget {
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
    _feedbackController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      debugPrint('Recording started');
    } else {
      debugPrint('Recording stopped');
      debugPrint('Feedback: ${_feedbackController.text}');

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

          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 48,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.025),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 96,
                        offset: const Offset(0, 48),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFB4FF3C),
                                    Color(0xFF7ECF00),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _lime.withValues(alpha: 0.35),
                                    blurRadius: 40,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Color(0xFF0D0D0D),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'LIVE FORM ANALYSIS',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      const Text(
                        'Track your pose.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xE6FFFFFF),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Visualize your motion in real time and log quick feedback.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const _SectionLabel('LIVE VIEW'),
                      const SizedBox(height: 10),

                      // Camera preview card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.06),
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
                                // Small LIVE badge
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

                      const SizedBox(height: 24),

                      const _SectionLabel('SESSION CONTROLS'),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
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
                                blurRadius: 28,
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

                      const SizedBox(height: 22),

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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Same label vibe as your `_FieldLabel` on SignUp
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