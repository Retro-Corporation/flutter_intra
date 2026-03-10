import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'features/pose/widgets/pose_overlay.dart';
import 'features/pose/pose_controller.dart';
import 'features/pose/pose_sequence.dart';
import 'features/pose/pose_frame.dart';

import 'features/ml/rep_counter.dart';

import 'database/database_helper.dart';
import 'database/repositories.dart';

import 'features/auth/auth_service.dart';
import 'features/exercise/exercise_service.dart';
import 'services/system_metrics_service.dart';

import 'features/auth/auth_controller.dart';
import 'features/exercise/exercise_controller.dart';

import 'core/metrics_tracker.dart';

import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/sign_up.dart';

late List<CameraDescription> cameras;

late AuthService authService;
late ExerciseService exerciseService;
late SystemMetricsService systemMetricsService;

late AuthController authController;
late ExerciseController exerciseController;
late PoseController poseController;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MetricsTracker.instance.reset();

  final db = await DatabaseHelper.instance.database;

  final userRepo = UserRepository(db);
  final exerciseRepo = ExerciseRepository(db);
  final systemMetricsRepo = SystemMetricsRepository(db);

  authService = AuthService(userRepo);
  exerciseService = ExerciseService(exerciseRepo);
  systemMetricsService = SystemMetricsService(systemMetricsRepo);

  authController = AuthController(authService);
  exerciseController = ExerciseController(exerciseService);

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
  bool _isCounting = false;

  PoseSequence? _lastSequence;
  PoseSequence? _activeReferenceSequence;
  RepCounter? _repCounter;

  List<Map<String, Object?>> _savedExercises = [];
  int? _selectedExerciseId;

  static const _lime = Color(0xFFB4FF3C);
  static const _bg = Color(0xFF0D0D0D);

  @override
  void initState() {
    super.initState();
    _controller = poseController;
    _controller.addListener(_onUpdate);
    _loadExercises();
  }

  void _onUpdate() {
    if (_isCounting && _repCounter != null && _controller.landmarks != null) {
      final frame = PoseFrame.fromPoseLandmarks(
        poseLandmarks: _controller.landmarks!,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _repCounter!.processFrame(frame);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await exerciseController.getAllExercises();
      exercises.sort((a, b) {
        final idA = (a['id'] as int?) ?? 0;
        final idB = (b['id'] as int?) ?? 0;
        return idB.compareTo(idA);
      });
      _savedExercises = exercises.take(4).toList();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    }
  }

  Future<void> _selectExercise(Map<String, Object?> exercise) async {
    final id = exercise['id'] as int?;
    final poseJsonDynamic =
        exercise['referencePoseJson'] ?? exercise['reference_pose_json'];
    if (poseJsonDynamic is! String) {
      debugPrint('Missing reference pose json for exercise $id');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load exercise pose data.')),
      );
      return;
    }

    try {
      final sequence = PoseSequence.fromJsonString(poseJsonDynamic);
      setState(() {
        _selectedExerciseId = id;
        _activeReferenceSequence = sequence;
        _lastSequence = sequence;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exercise ${id ?? ''} selected as reference.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error parsing pose json: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to parse exercise pose data.')),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() => _isRecording = false);

      final sequence = _controller.stopRecording();
      _lastSequence = sequence;

      if (sequence.frames.isNotEmpty) {
        debugPrint('Recording stopped with ${sequence.frames.length} frames');
      }

      final exerciseName = await _promptForText(
        context: context,
        title: 'Name this exercise',
        hint: 'e.g., Barbell Squat Reference',
      );

      if (!mounted) return;

      if (exerciseName == null || exerciseName.trim().isEmpty) {
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

      if (!mounted) return;

      await _saveSequenceAsExercise(
        sequence: sequence,
        exerciseName: exerciseName.trim(),
        description: description?.trim() ?? '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise reference saved.')),
      );
    } else {
      _controller.startRecording();
      setState(() => _isRecording = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording started')),
      );
    }
  }

  Future<void> _toggleRepCounting() async {
    if (_activeReferenceSequence == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a reference exercise first.')),
      );
      return;
    }

    if (_isCounting) {
      setState(() => _isCounting = false);

      final reps = _repCounter?.repCount ?? 0;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rep counting stopped. Total: $reps reps')),
      );

      _repCounter = null;
    } else {
      _repCounter = RepCounter(referenceSequence: _activeReferenceSequence!);
      setState(() => _isCounting = true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rep counting started!')),
      );
    }
  }

  Future<void> _saveSequenceAsExercise({
    required PoseSequence sequence,
    required String exerciseName,
    required String description,
  }) async {
    final poseReferenceJson = sequence.toJsonString();

    try {
      final result = await exerciseController.createExercise(
        name: exerciseName,
        description: description,
        referencePoseJson: poseReferenceJson,
      );

      if (result['success'] == true) {
        final newId = result['exerciseId'] as int?;
        setState(() {
          _selectedExerciseId = newId;
          _activeReferenceSequence = sequence;
          _lastSequence = sequence;
        });
        await _loadExercises();
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      debugPrint('Error saving exercise: $e');
      rethrow;
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
                            shaderCallback: (bounds) => const LinearGradient(
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
                                    borderRadius: BorderRadius.circular(999),
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
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
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
                                onPressed: _activeReferenceSequence == null
                                    ? null
                                    : _toggleRepCounting,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _isCounting
                                        ? const Color(0xFFFF641E)
                                        : Colors.white
                                            .withValues(alpha: 0.25),
                                  ),
                                  backgroundColor: _isCounting
                                      ? const Color(0xFFFF641E)
                                          .withValues(alpha: 0.15)
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
                                  color: _activeReferenceSequence == null
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : _isCounting
                                          ? const Color(0xFFFF641E)
                                          : Colors.white
                                              .withValues(alpha: 0.85),
                                ),
                                label: Text(
                                  _isCounting ? 'STOP' : 'COUNT REPS',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: _activeReferenceSequence == null
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
                      const _SectionLabel('REFERENCE EXERCISES'),
                      const SizedBox(height: 8),
                      if (_savedExercises.isEmpty)
                        Text(
                          'No saved exercises yet.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        )
                      else
                        Row(
                          children: _savedExercises.map((exercise) {
                            final id = exercise['id'];
                            final name = exercise['name'] ?? '';
                            final selected = id == _selectedExerciseId;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: _ExerciseCube(
                                  title: 'ID: $id',
                                  subtitle: '$name',
                                  selected: selected,
                                  onTap: () => _selectExercise(exercise),
                                ),
                              ),
                            );
                          }).toList(),
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
            hintStyle: const TextStyle(
              color: Color(0x66FFFFFF),
              fontSize: 14,
            ),
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

class _ExerciseCube extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ExerciseCube({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFFB4FF3C)
        : Colors.white.withValues(alpha: 0.15);
    final bgColor = selected
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.03);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFFB4FF3C)
                    : Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
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