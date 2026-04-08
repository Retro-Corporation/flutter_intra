import 'package:flutter/material.dart';

// Pose
import 'features/pose/widgets/pose_overlay.dart';
import 'features/pose/pose_controller.dart';
import 'features/pose/pose_sequence.dart';
import 'features/pose/pose_frame.dart';

// ML
import 'features/ml/rep_counter.dart';

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

  // Pose controller (uses NativeMotionEngine / FFI)
  poseController = PoseController();
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
  
  // Rep counter for live comparison
  RepCounter? _repCounter;
  bool _isCounting = false;

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
    // Process frames for rep counting if active
    if (_isCounting && _repCounter != null && _controller.worldLandmarks != null) {
      final frame = PoseFrame.fromWorldLandmarks(
        worldLandmarks: _controller.worldLandmarks!,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _repCounter!.processFrame(frame);
    }
    
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

  /// "Compare" button - Start/stop rep counting using the recorded sequence
  Future<void> _toggleRepCounting() async {
    if (_isCounting) {
      // Stop counting
      setState(() => _isCounting = false);
      
      final reps = _repCounter?.repCount ?? 0;
      debugPrint('=== [POSE] Rep counting stopped ===');
      debugPrint('Total reps completed: $reps');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rep counting stopped. Total: $reps reps')),
      );
      
      _repCounter = null;
    } else {
      // Start counting
      if (_lastSequence == null) {
        debugPrint('[POSE] No reference sequence available.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record a reference sequence first!'),
          ),
        );
        return;
      }

      if (_lastSequence!.frames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reference sequence has no frames!'),
          ),
        );
        return;
      }

      debugPrint('=== [POSE] Starting rep counter ===');
      debugPrint('Reference: ${_lastSequence!.frames.length} frames');
      
      _repCounter = RepCounter(referenceSequence: _lastSequence!);
      setState(() => _isCounting = true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rep counting started!')),
      );
    }
  }

  /// Save PoseSequence + metadata via ExerciseController
  Future<void> _saveSequenceAsExercise({
    required PoseSequence sequence,
    required String exerciseName,
    required String description,
  }) async {
    final poseReferenceJson = sequence.toJsonString();

    debugPrint('=== [POSE] Saving Exercise Reference ===');
    debugPrint('Name        : $exerciseName');
    debugPrint('Description : $description');
    debugPrint('Frames      : ${sequence.frames.length}');
    debugPrint('Duration    : ${sequence.durationMs} ms');
    debugPrint('FPS         : ${sequence.fps.toStringAsFixed(2)}');
    debugPrint('JSON length : ${poseReferenceJson.length}');

    try {
      final result = await exerciseController.createExercise(
        name: exerciseName,
        description: description,
        referencePoseJson: poseReferenceJson,
      );

      if (result['success'] == true) {
        debugPrint('✓ Exercise saved with ID: ${result['exerciseId']}');
      } else {
        debugPrint('✗ Failed to save: ${result['error']}');
        throw Exception(result['error']);
      }
    } catch (e) {
      debugPrint('✗ Error saving exercise: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isReady) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                        child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Texture(textureId: _controller.textureId!),
                              if (_controller.poseLandmarks != null)
                                PoseOverlay(
                                  landmarks: _controller.poseLandmarks!,
                                  previewSize: MediaQuery.of(context).size,
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
                              // Rep counter display
                              if (_isCounting)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF641E),
                                          Color(0xFFD94E00),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF641E)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_repCounter?.repCount ?? 0}',
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            height: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'REPS',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white.withValues(alpha: 0.8),
                                            letterSpacing: 1.5,
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
                                onPressed: _lastSequence == null 
                                    ? null 
                                    : _toggleRepCounting,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _isCounting
                                        ? const Color(0xFFFF641E)
                                        : Colors.white.withValues(alpha: 0.25),
                                  ),
                                  backgroundColor: _isCounting
                                      ? const Color(0xFFFF641E).withValues(alpha: 0.15)
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: Icon(
                                  _isCounting 
                                      ? Icons.stop_circle_outlined
                                      : Icons.compare_arrows_rounded,
                                  size: 18,
                                  color: _lastSequence == null
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : _isCounting
                                          ? const Color(0xFFFF641E)
                                          : Colors.white.withValues(alpha: 0.85),
                                ),
                                label: Text(
                                  _isCounting ? 'STOP' : 'COUNT REPS',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: _lastSequence == null
                                        ? Colors.white.withValues(alpha: 0.35)
                                        : _isCounting
                                            ? const Color(0xFFFF641E)
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