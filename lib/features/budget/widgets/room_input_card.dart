import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/budget_model.dart';

class RoomInputCard extends StatelessWidget {
  final RoomModel room;
  final bool canDelete;
  final ValueChanged<RoomModel> onChanged;
  final VoidCallback onDelete;

  const RoomInputCard({
    super.key,
    required this.room,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: room.name,
                  decoration: const InputDecoration(
                    labelText: 'Room Name',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) => onChanged(room.copyWith(name: val)),
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: onDelete,
                ),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  context, 
                  'Length (ft)', 
                  room.length, 
                  (val) => onChanged(room.copyWith(length: val))
                ),
              ),
              const SizedBox(width: AppSizes.p8),
              Expanded(
                child: _buildNumberInput(
                  context, 
                  'Width (ft)', 
                  room.width, 
                  (val) => onChanged(room.copyWith(width: val))
                ),
              ),
              const SizedBox(width: AppSizes.p8),
              Expanded(
                child: _buildNumberInput(
                  context, 
                  'Height (ft)', 
                  room.height, 
                  (val) => onChanged(room.copyWith(height: val))
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          Row(
            children: [
              Expanded(
                child: _buildStepper(
                  context, 
                  'Doors', 
                  room.doorsCount, 
                  (val) => onChanged(room.copyWith(doorsCount: val))
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              Expanded(
                child: _buildStepper(
                  context, 
                  'Windows', 
                  room.windowsCount, 
                  (val) => onChanged(room.copyWith(windowsCount: val))
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Computed Wall Area:'),
                Text(
                  '${room.wallArea.toStringAsFixed(1)} sq ft',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(BuildContext context, String label, double value, ValueChanged<double> onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (val) {
        final parsed = double.tryParse(val);
        if (parsed != null) onChanged(parsed);
      },
    );
  }

  Widget _buildStepper(BuildContext context, String label, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            InkWell(
              onTap: value > 0 ? () => onChanged(value - 1) : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.remove, size: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            InkWell(
              onTap: () => onChanged(value + 1),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add, size: 16, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
