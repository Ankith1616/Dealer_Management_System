import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../providers/budget_provider.dart';
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

    return Scaffold(
      appBar: const CustomAppBar(title: 'Budget Calculator'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculate Your Paint Budget',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSizes.p8),
            Text(
              'Add your rooms and select a paint to get an estimated cost.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.p24),

            // 1. Rooms Section
            Text(
              '1. Your Rooms',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budgetState.rooms.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p16),
              itemBuilder: (context, index) {
                final room = budgetState.rooms[index];
                return RoomInputCard(
                  room: room,
                  canDelete: budgetState.rooms.length > 1,
                  onChanged: (updatedRoom) => notifier.updateRoom(updatedRoom),
                  onDelete: () => notifier.removeRoom(room.id),
                );
              },
            ),
            const SizedBox(height: AppSizes.p16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => notifier.addRoom(),
                icon: const Icon(Icons.add),
                label: const Text('Add Another Room'),
              ),
            ),

            const SizedBox(height: AppSizes.p32),

            // 2. Paint Selection
            Text(
              '2. Select Paint',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p16),
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

            const SizedBox(height: AppSizes.p32),

            // 3. Coats Selection
            Text(
              '3. Number of Coats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.p16),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 Coat')),
                ButtonSegment(value: 2, label: Text('2 Coats')),
                ButtonSegment(value: 3, label: Text('3 Coats')),
              ],
              selected: {budgetState.coats},
              onSelectionChanged: (Set<int> newSelection) {
                notifier.setCoats(newSelection.first);
              },
            ),

            const SizedBox(height: AppSizes.p32),

            // 4. Summary
            if (budgetState.computedBudget != null && budgetState.selectedProduct != null)
              BudgetSummary(budget: budgetState.computedBudget!),
              
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }
}
