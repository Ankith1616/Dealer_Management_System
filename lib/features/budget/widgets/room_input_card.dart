import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/budget_model.dart';

class RoomInputCard extends StatefulWidget {
  final RoomModel room;
  final int roomNumber;
  final bool canDelete;
  final ValueChanged<RoomModel> onChanged;
  final VoidCallback onDelete;

  const RoomInputCard({
    super.key,
    required this.room,
    required this.roomNumber,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<RoomInputCard> createState() => _RoomInputCardState();
}

class _RoomInputCardState extends State<RoomInputCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  late TextEditingController _nameCtrl;
  late TextEditingController _lengthCtrl;
  late TextEditingController _widthCtrl;
  late TextEditingController _heightCtrl;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    _nameCtrl = TextEditingController(text: widget.room.name);
    _lengthCtrl = TextEditingController(text: _fmt(widget.room.length));
    _widthCtrl = TextEditingController(text: _fmt(widget.room.width));
    _heightCtrl = TextEditingController(text: _fmt(widget.room.height));
  }

  String _fmt(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _emitChange({String? name, double? length, double? width, double? height, int? doors, int? windows}) {
    widget.onChanged(widget.room.copyWith(
      name: name,
      length: length,
      width: width,
      height: height,
      doorsCount: doors,
      windowsCount: windows,
    ));
  }

  Widget _dimField(TextEditingController ctrl, String label, IconData icon, Function(double) onDone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          decoration: InputDecoration(
            suffixText: 'ft',
            suffixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val);
            if (parsed != null && parsed > 0) onDone(parsed);
          },
        ),
      ],
    );
  }

  Widget _stepperWidget(String label, String hint, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(hint, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepBtn(Icons.remove, value > 0 ? () => onChanged(value - 1) : null, AppColors.error),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              ),
              _stepBtn(Icons.add, () => onChanged(value + 1), AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap != null ? color.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: onTap != null ? color.withValues(alpha: 0.3) : Colors.grey.shade200),
        ),
        child: Icon(icon, size: 18, color: onTap != null ? color : Colors.grey.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallArea = widget.room.wallArea;
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.gradientPrimary),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                    child: Center(
                      child: Text('${widget.roomNumber}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Room name (e.g., Bedroom)',
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) => _emitChange(name: val),
                    ),
                  ),
                  if (widget.canDelete)
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white70, size: 18),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dimension hint
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Measure the length & width of your room floor. Height is ceiling height (usually 9–10 ft).',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dimensions row
                  Row(
                    children: [
                      Expanded(child: _dimField(_lengthCtrl, 'Length', Icons.straighten, (v) => _emitChange(length: v))),
                      const SizedBox(width: 8),
                      Expanded(child: _dimField(_widthCtrl, 'Width', Icons.straighten, (v) => _emitChange(width: v))),
                      const SizedBox(width: 8),
                      Expanded(child: _dimField(_heightCtrl, 'Height', Icons.height, (v) => _emitChange(height: v))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Formula hint
                  Text(
                    'Wall Area = 2 × (Length + Width) × Height  –  door & window openings',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 14),

                  // Doors / Windows steppers
                  const Text('Subtract Openings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    'Doors and windows are not painted — we subtract their area automatically.',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _stepperWidget(
                          '🚪 Doors',
                          '–20 sq ft each',
                          widget.room.doorsCount,
                          (v) => _emitChange(doors: v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _stepperWidget(
                          '🪟 Windows',
                          '–15 sq ft each',
                          widget.room.windowsCount,
                          (v) => _emitChange(windows: v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Computed wall area pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.primaryLight.withValues(alpha: 0.05)],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Net Paintable Wall Area:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Text(
                          '${wallArea.toStringAsFixed(1)} sq ft',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
