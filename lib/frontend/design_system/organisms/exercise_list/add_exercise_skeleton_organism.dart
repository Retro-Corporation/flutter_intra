import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';

/// Organism: static (no animation) loading skeleton for the Add Exercise page.
/// Mirrors the real page's section structure: three titled sections — one row
/// of large cards, two grids of small cards.
class AddExerciseSkeletonOrganism extends StatelessWidget {
  const AddExerciseSkeletonOrganism({super.key});

  // ── Explicit layout dimensions (not semantic tokens) ──

  static const double _headerWidth = 160;
  static const double _largeCardSize = 128;
  static const double _smallCardSize = 100;

  // ── Private builders ──

  Widget _buildHeaderPlaceholder() {
    return Container(
      height: AppGrid.grid24,
      width: _headerWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }

  Widget _buildLargeCard() {
    return Container(
      width: _largeCardSize,
      height: _largeCardSize,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }

  Widget _buildSmallCard() {
    return Container(
      width: _smallCardSize,
      height: _smallCardSize,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    );
  }

  Widget _buildLargeCardRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildLargeCard(),
          const SizedBox(width: AppGrid.grid16),
          _buildLargeCard(),
          const SizedBox(width: AppGrid.grid16),
          _buildLargeCard(),
          const SizedBox(width: AppGrid.grid16),
          _buildLargeCard(),
        ],
      ),
    );
  }

  Widget _buildSmallCardRow() {
    return Row(
      children: [
        _buildSmallCard(),
        const SizedBox(width: AppGrid.grid16),
        _buildSmallCard(),
        const SizedBox(width: AppGrid.grid16),
        _buildSmallCard(),
        const SizedBox(width: AppGrid.grid16),
        _buildSmallCard(),
      ],
    );
  }

  Widget _buildSmallCardGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          _buildSmallCardRow(),
          const SizedBox(height: AppGrid.grid16),
          _buildSmallCardRow(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section 1: row of large cards ──
          _buildHeaderPlaceholder(),
          const SizedBox(height: AppGrid.grid8),
          _buildLargeCardRow(),

          const SizedBox(height: AppGrid.grid16),

          // ── Section 2: grid of small cards ──
          _buildHeaderPlaceholder(),
          const SizedBox(height: AppGrid.grid8),
          _buildSmallCardGrid(),

          const SizedBox(height: AppGrid.grid16),

          // ── Section 3: grid of small cards ──
          _buildHeaderPlaceholder(),
          const SizedBox(height: AppGrid.grid8),
          _buildSmallCardGrid(),
        ],
      ),
    );
  }
}
