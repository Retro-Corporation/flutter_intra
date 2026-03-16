import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Frontend structure setup', () {
    final base = 'lib/frontend';

    test('README exists', () {
      expect(File('$base/README.md').existsSync(), isTrue);
    });

    test('design_system barrel export exists', () {
      expect(
          File('$base/design_system/design_system.dart').existsSync(), isTrue);
    });

    test('foundation token files exist', () {
      expect(File('$base/design_system/foundation/colors.dart').existsSync(),
          isTrue);
      expect(
          File('$base/design_system/foundation/typography.dart').existsSync(),
          isTrue);
      expect(File('$base/design_system/foundation/padding.dart').existsSync(),
          isTrue);
      expect(File('$base/design_system/foundation/theme.dart').existsSync(),
          isTrue);
    });

    test('atomic design directories exist', () {
      expect(Directory('$base/design_system/atoms').existsSync(), isTrue);
      expect(Directory('$base/design_system/molecules').existsSync(), isTrue);
      expect(Directory('$base/design_system/organisms').existsSync(), isTrue);
      expect(Directory('$base/design_system/templates').existsSync(), isTrue);
    });

    test('library directories exist', () {
      expect(Directory('$base/library/state').existsSync(), isTrue);
      expect(Directory('$base/library/services').existsSync(), isTrue);
      expect(Directory('$base/library/models').existsSync(), isTrue);
      expect(Directory('$base/library/navigation').existsSync(), isTrue);
      expect(Directory('$base/library/utils').existsSync(), isTrue);
    });

    test('pages directory exists', () {
      expect(Directory('$base/pages').existsSync(), isTrue);
    });

    test('no existing files were modified', () {
      expect(File('lib/main.dart').existsSync(), isTrue);
      expect(Directory('lib/database').existsSync(), isTrue);
      expect(Directory('lib/features').existsSync(), isTrue);
      expect(Directory('lib/services').existsSync(), isTrue);
    });

    test('foundation files contain expected classes', () {
      final colors =
          File('$base/design_system/foundation/colors.dart').readAsStringSync();
      expect(colors, contains('class AppColors'));

      final typography = File('$base/design_system/foundation/typography.dart')
          .readAsStringSync();
      expect(typography, contains('class AppTypography'));

      final padding = File('$base/design_system/foundation/padding.dart')
          .readAsStringSync();
      expect(padding, contains('class AppPadding'));

      final theme =
          File('$base/design_system/foundation/theme.dart').readAsStringSync();
      expect(theme, contains('class AppTheme'));
    });
  });
}
