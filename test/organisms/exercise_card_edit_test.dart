import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_account/exercise_card_edit.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/score_badge_types.dart';
import 'package:flutter_intra/frontend/design_system/molecules/form_fields/equipment_field_types.dart';
import 'package:flutter_intra/frontend/design_system/icons/app_icons.dart';

class _TestHarness extends StatefulWidget {
  final EquipmentFieldType equipmentType;
  final String? staticEquipmentValue;
  final VoidCallback? onDelete;
  final VoidCallback? onSwap;
  final String exerciseName;
  final String muscleGroup;

  const _TestHarness({
    required this.equipmentType,
    this.staticEquipmentValue,
    this.onDelete,
    this.onSwap,
    this.exerciseName = 'Shoulder Press',
    this.muscleGroup = 'Shoulder flexion',
  });

  @override
  State<_TestHarness> createState() => _TestHarnessState();
}

class _TestHarnessState extends State<_TestHarness> {
  final _repController = TextEditingController();
  final _setsController = TextEditingController();
  final _repFocusNode = FocusNode();
  final _setsFocusNode = FocusNode();
  final _equipController = TextEditingController();
  final _equipFocusNode = FocusNode();

  @override
  void dispose() {
    _repController.dispose();
    _setsController.dispose();
    _repFocusNode.dispose();
    _setsFocusNode.dispose();
    _equipController.dispose();
    _equipFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseCardEdit(
      thumbnails: const [null],
      currentIndex: 0,
      onIndexChanged: (_) {},
      score: 82,
      scoreColor: Colors.orange,
      scoreVariant: ScoreBadgeVariant.plain,
      exerciseName: widget.exerciseName,
      muscleGroup: widget.muscleGroup,
      repController: _repController,
      repFocusNode: _repFocusNode,
      setsController: _setsController,
      setsFocusNode: _setsFocusNode,
      equipmentLabel: 'Equipment',
      equipmentType: widget.equipmentType,
      equipmentController: widget.equipmentType == EquipmentFieldType.numbered
          ? _equipController
          : null,
      equipmentFocusNode: widget.equipmentType == EquipmentFieldType.numbered
          ? _equipFocusNode
          : null,
      staticEquipmentValue: widget.staticEquipmentValue,
      onDelete: widget.onDelete ?? () {},
      onSwap: widget.onSwap ?? () {},
    );
  }
}

Widget build({
  String exerciseName = 'Shoulder Press',
  String muscleGroup = 'Shoulder flexion',
  EquipmentFieldType equipmentType = EquipmentFieldType.staticDisplay,
  String? staticEquipmentValue = 'No equipment',
  VoidCallback? onDelete,
  VoidCallback? onSwap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: _TestHarness(
          equipmentType: equipmentType,
          staticEquipmentValue: staticEquipmentValue,
          exerciseName: exerciseName,
          muscleGroup: muscleGroup,
          onDelete: onDelete,
          onSwap: onSwap,
        ),
      ),
    ),
  );
}

void main() {
  group('ExerciseCardEdit rendering', () {
    testWidgets('renders exercise name', (tester) async {
      await tester.pumpWidget(build(exerciseName: 'Shoulder Press'));

      expect(find.text('Shoulder Press'), findsOneWidget);
    });

    testWidgets('renders muscle group', (tester) async {
      await tester.pumpWidget(build(muscleGroup: 'Shoulder flexion'));

      expect(find.text('Shoulder flexion'), findsOneWidget);
    });

    testWidgets('renders Rep label', (tester) async {
      await tester.pumpWidget(build());

      expect(find.text('Rep'), findsOneWidget);
    });

    testWidgets('renders Sets label', (tester) async {
      await tester.pumpWidget(build());

      expect(find.text('Sets'), findsOneWidget);
    });

    testWidgets('renders Swap label', (tester) async {
      await tester.pumpWidget(build());

      expect(find.text('Swap'), findsOneWidget);
    });

    testWidgets('renders ScoreBadge', (tester) async {
      await tester.pumpWidget(build());

      expect(find.byType(ScoreBadge), findsOneWidget);
    });

    testWidgets('renders ExerciseFlowCarousel', (tester) async {
      await tester.pumpWidget(build());

      expect(find.byType(ExerciseFlowCarousel), findsOneWidget);
    });
  });

  group('ExerciseCardEdit equipment variants', () {
    testWidgets('staticDisplay variant renders without error', (tester) async {
      await tester.pumpWidget(build(
        equipmentType: EquipmentFieldType.staticDisplay,
        staticEquipmentValue: 'No equipment',
      ));

      expect(find.byType(ExerciseCardEdit), findsOneWidget);
    });

    testWidgets('selectable variant renders without error', (tester) async {
      await tester.pumpWidget(build(
        equipmentType: EquipmentFieldType.selectable,
        staticEquipmentValue: null,
      ));

      expect(find.byType(ExerciseCardEdit), findsOneWidget);
    });

    testWidgets('numbered variant renders without error', (tester) async {
      await tester.pumpWidget(build(
        equipmentType: EquipmentFieldType.numbered,
        staticEquipmentValue: null,
      ));

      expect(find.byType(ExerciseCardEdit), findsOneWidget);
    });
  });

  group('ExerciseCardEdit actions', () {
    testWidgets('onDelete fires when delete icon tapped', (tester) async {
      bool deleted = false;
      await tester.pumpWidget(build(onDelete: () => deleted = true));

      // Tap the delete icon directly — GestureDetector wrapping it will fire
      final deleteIcon = find.byWidgetPredicate(
        (w) => w is AppIcon && w.icon == AppIcons.delete,
      );
      expect(deleteIcon, findsOneWidget);
      await tester.tap(deleteIcon);
      await tester.pump();

      expect(deleted, isTrue);
    });

    testWidgets('onSwap fires when swap icon tapped', (tester) async {
      bool swapped = false;
      await tester.pumpWidget(build(onSwap: () => swapped = true));

      // Tap the refresh icon inside PressableSurface
      final swapIcon = find.byWidgetPredicate(
        (w) => w is AppIcon && w.icon == AppIcons.refresh,
      );
      expect(swapIcon, findsOneWidget);
      await tester.tap(swapIcon);
      await tester.pump();

      expect(swapped, isTrue);
    });
  });
}
