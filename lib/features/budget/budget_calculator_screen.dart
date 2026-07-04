import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/room_input_card.dart';
import 'widgets/paint_selector.dart';
import 'widgets/budget_summary.dart';
import '../../providers/activity_history_provider.dart';

class BudgetCalculatorScreen extends ConsumerWidget {
  const BudgetCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);
    final notifier = ref.read(budgetProvider.notifier);
    final hasResult = budgetState.computedBudget != null && budgetState.selectedProduct != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: const CustomAppBar(title: 'Paint Budget Estimator'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Hero Banner ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.gradientPrimary,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paint Cost Estimator',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your room dimensions and choose a paint to instantly calculate how much paint you need and the estimated cost.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.format_paint_outlined, color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── STEP 1: Rooms ────────────────────────────────────────────────
            _StepHeader(
              step: 1,
              title: 'Add Your Rooms',
              subtitle: 'Enter each room you want to paint. We\'ll calculate wall area automatically.',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 14),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgetState.rooms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final room = budgetState.rooms[index];
                return RoomInputCard(
                  room: room,
                  roomNumber: index + 1,
                  canDelete: budgetState.rooms.length > 1,
                  onChanged: (updatedRoom) => notifier.updateRoom(updatedRoom),
                  onDelete: () => notifier.removeRoom(room.id),
                );
              },
            ),

            const SizedBox(height: 14),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => notifier.addRoom(),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Another Room'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── STEP 2: Paint Selection ─────────────────────────────────────
            _StepHeader(
              step: 2,
              title: 'Choose Your Paint',
              subtitle: 'Select the paint product. Each paint has a different price and coverage rate.',
              icon: Icons.palette_outlined,
            ),
            const SizedBox(height: 14),
            PaintSelector(
              selectedProduct: budgetState.selectedProduct,
              onSelect: (product) {
                notifier.setProduct(product);
                ref.read(activityHistoryProvider.notifier).addActivity(
                  'Estimated Paint Budget for "${product.name}"',
                  Icons.calculate_outlined,
                );
              },
            ),

            const SizedBox(height: 32),

            // ── STEP 3: Number of Coats ─────────────────────────────────────
            _StepHeader(
              step: 3,
              title: 'Number of Coats',
              subtitle: 'More coats = better coverage and colour depth, but more paint needed.',
              icon: Icons.layers_outlined,
            ),
            const SizedBox(height: 14),
            _CoatsSelector(
              coats: budgetState.coats,
              onChanged: (v) => notifier.setCoats(v),
            ),

            const SizedBox(height: 32),

            // ── STEP 4: Summary ─────────────────────────────────────────────
            if (hasResult) ...[
              _StepHeader(
                step: 4,
                title: 'Your Estimate',
                subtitle: 'Here\'s a detailed breakdown of the cost and paint needed.',
                icon: Icons.receipt_long_outlined,
                isLast: true,
              ),
              const SizedBox(height: 14),
              BudgetSummary(
                budget: budgetState.computedBudget!,
                selectedProduct: budgetState.selectedProduct,
              ),
              const SizedBox(height: 20),
              Center(
                child: FilledButton.icon(
                  onPressed: () async {
                    final repo = ref.read(budgetRepositoryProvider);
                    final currentUser = ref.read(currentUserProvider);
                    final budgetToSave = budgetState.computedBudget!.copyWith(userId: currentUser?.uid);
                    await repo.saveBudget(budgetToSave);
                    ref.invalidate(savedBudgetsProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.bookmark_added_outlined, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Estimate saved to your profile!'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.bookmark_added_outlined),
                  label: const Text('Save This Estimate'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else ...[
              // Placeholder when nothing computed yet
              _PendingStepsCard(
                hasProduct: budgetState.selectedProduct != null,
                hasRooms: budgetState.rooms.isNotEmpty,
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Step Header ─────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLast;

  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Center(
                child: Text('$step',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2, height: 20,
                color: AppColors.primary.withValues(alpha: 0.2),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Coats Selector ──────────────────────────────────────────────────────────

class _CoatsSelector extends StatelessWidget {
  final int coats;
  final ValueChanged<int> onChanged;

  const _CoatsSelector({required this.coats, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      (1, '1 Coat', 'Thin coverage\nfor light touch-ups'),
      (2, '2 Coats', 'Standard — recommended\nfor most rooms'),
      (3, '3 Coats', 'Maximum coverage\nfor dark or rough walls'),
    ];

    return Row(
      children: options.map((opt) {
        final (value, label, desc) = opt;
        final isSelected = coats == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.layers,
                    size: 28,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Pending Steps placeholder ────────────────────────────────────────────────

class _PendingStepsCard extends StatelessWidget {
  final bool hasProduct;
  final bool hasRooms;

  const _PendingStepsCard({required this.hasProduct, required this.hasRooms});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.pending_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Complete the steps above to see your estimate',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _ChecklistItem(
            label: 'Add at least one room with dimensions',
            done: hasRooms,
          ),
          _ChecklistItem(
            label: 'Select a paint product',
            done: hasProduct,
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool done;
  const _ChecklistItem({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? AppColors.success : Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: done ? AppColors.success : Colors.grey.shade600,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
