import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Pose
import 'features/pose/widgets/pose_overlay.dart';
import 'features/pose/pose_controller.dart';
import 'features/pose/pose_sequence.dart';

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
  await poseController.initialize(); 

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

  // store last recorded sequence so we can compare / debug it
  PoseSequence? _lastSequence;

  static const _lime = Color(0xFFB4FF3C);
  static const _bg = Color(0xFF0D0D0D);

  @override
  void initState() {
    super.initState();
    // use the global poseController that main() initialized
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
      
      debugPrint('=== [POSE] Stop recording requested ===');
      setState(() => _isRecording = false);

      // Build a PoseSequence from the frames collected in PoseController
      final sequence = _controller.stopRecording();
      _lastSequence = sequence;

      debugPrint('=== [POSE] Recording stopped ===');
      debugPrint('Sequence summary: ${sequence.toString()}');
      debugPrint('  • Frames   : ${sequence.frames.length}');
      debugPrint('  • Duration : ${sequence.durationMs} ms');
      debugPrint('  • FPS      : ${sequence.fps.toStringAsFixed(2)}');

      if (sequence.frames.isNotEmpty) {
        debugPrint(
            '  • First frame timestamp : ${sequence.frames.first.timestamp} ms');
        debugPrint(
            '  • Last frame timestamp  : ${sequence.frames.last.timestamp} ms');
      }

      // Ask user: exercise name
      final exerciseName = await _promptForText(
        context: context,
        title: 'Name this exercise',
        hint: 'e.g., Barbell Squat Reference',
      );

      if (exerciseName == null || exerciseName.trim().isEmpty) {
        debugPrint(
            '[POSE] No exercise name provided — sequence not saved to DB.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise not saved (no name provided).'),
          ),
        );
        return;
      }

      
      final description = await _promptForText(
        context: context,
        title: 'Describe this exercise',
        hint: 'e.g., Baseline reference for my squat form.',
      );

      await _saveSequenceAsExercise(
        sequence: sequence,
        exerciseName: exerciseName.trim(),
        description: description?.trim() ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise reference saved.')),
      );
    } else {
      
      debugPrint('=== [POSE] Start recording requested ===');
      _controller.startRecording();
      setState(() => _isRecording = true);
      debugPrint('=== [POSE] Recording started ===');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording started')),
      );
    }
  }

  /// "Compare" button – right now used to debug that our sequence + JSON are valid.
  ///
  /// Later this can:
  ///  1) Load a stored reference sequence from DB
  ///  2) Capture a new live sequence
  ///  3) Run a comparison algorithm
  Future<void> _debugCompare() async {
    debugPrint('=== [POSE] Compare button pressed ===');

    if (_lastSequence == null) {
      debugPrint('[POSE] No last sequence available to compare.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No recorded sequence yet. Record once first.'),
        ),
      );
      return;
    }

    final seq = _lastSequence!;
    debugPrint('=== [POSE] Debugging last recorded sequence ===');
    debugPrint('Sequence summary: ${seq.toString()}');
    debugPrint('  • Frames   : ${seq.frames.length}');
    debugPrint('  • Duration : ${seq.durationMs} ms');
    debugPrint('  • FPS      : ${seq.fps.toStringAsFixed(2)}');

    if (seq.frames.isNotEmpty) {
      final first = seq.frames.first;
      final last = seq.frames.last;
      debugPrint(
          '  • First frame timestamp : ${first.timestamp} ms, angles: ${first.anglesInDegrees.keys.take(3).toList()}');
      debugPrint(
          '  • Last frame timestamp  : ${last.timestamp} ms, angles: ${last.anglesInDegrees.keys.take(3).toList()}');
    }

    // Also test JSON conversion round-trip length
    final jsonString = seq.toJsonString();
    debugPrint('  • JSON length: ${jsonString.length}');
    debugPrint('  • JSON preview (first 400 chars):');
    debugPrint(jsonString.length > 400
        ? jsonString.substring(0, 400)
        : jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compare debug logged to console.'),
      ),
    );
  }

  /// Save PoseSequence + metadata via ExerciseController (hook point)
  Future<void> _saveSequenceAsExercise({
    required PoseSequence sequence,
    required String exerciseName,
    required String description,
  }) async {
    final poseReferenceJson = sequence.toJsonString();
    final feedback = _feedbackController.text.trim();

    debugPrint('=== [POSE] Saving Exercise Reference ===');
    debugPrint('Name        : $exerciseName');
    debugPrint('Description : $description');
    debugPrint('Feedback    : $feedback');
    debugPrint('Frames      : ${sequence.frames.length}');
    debugPrint('Duration    : ${sequence.durationMs} ms');
    debugPrint('FPS         : ${sequence.fps.toStringAsFixed(2)}');
    debugPrint('JSON length : ${poseReferenceJson.length}');
    debugPrint('JSON preview (first 400 chars):');
    debugPrint(poseReferenceJson.length > 400
        ? poseReferenceJson.substring(0, 400)
        : poseReferenceJson);

    // TODO: plug into your real controller method.
    // Example (adjust to your actual API & model):
    //
    // await exerciseController.createExerciseReference(
    //   name: exerciseName,
    //   description: description,
    //   poseJson: poseReferenceJson,
    //   feedback: feedback,
    // );
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
          // Background
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
                // Header Comp.
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

                // Camera Area
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

                // CONTROLS + FEEDBACK (bottom panel) 
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

                      // RECORD + COMPARE buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed:
                                    _lastSequence == null ? null : _debugCompare,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.compare_arrows_rounded,
                                  size: 18,
                                  color: _lastSequence == null
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : Colors.white.withValues(alpha: 0.85),
                                ),
                                label: Text(
                                  'COMPARE',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: _lastSequence == null
                                        ? Colors.white.withValues(alpha: 0.35)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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



Future<String?> _promptForText({
  required BuildContext context,
  required String title,
  required String hint,
}) async {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0x66FFFFFF), fontSize: 14),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0x33FFFFFF)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB4FF3C)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
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