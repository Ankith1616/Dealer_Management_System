import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';

class DashboardGrid extends ConsumerWidget {
  const DashboardGrid({super.key});

  void _showComplaintsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ComplaintsBottomSheet(),
    );
  }

  void _showWarrantyModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _WarrantyDialog(),
    );
  }

  void _showHistoryModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _HistoryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final columns = size.width > 900 ? 4 : (size.width > 600 ? 3 : 2);

    final List<_GridItemData> items = [
      _GridItemData(
        title: 'Search Product',
        subtitle: 'Explore paints & primers',
        icon: Icons.format_paint_outlined,
        color: AppColors.primary,
        onTap: () => context.go('/products'),
      ),
      _GridItemData(
        title: 'Feedback',
        subtitle: 'Read & write reviews',
        icon: Icons.rate_review_outlined,
        color: Colors.amber.shade700,
        onTap: () => context.push('/reviews'),
      ),
      _GridItemData(
        title: 'Comparison',
        subtitle: 'Compare side by side',
        icon: Icons.compare_arrows_rounded,
        color: AppColors.accent,
        onTap: () => context.go('/compare'),
      ),
      _GridItemData(
        title: 'Complaints & Queries',
        subtitle: 'Get support or log issues',
        icon: Icons.support_agent_outlined,
        color: Colors.red.shade600,
        onTap: () => _showComplaintsModal(context),
      ),
      _GridItemData(
        title: 'Warranty',
        subtitle: 'Check coverage & terms',
        icon: Icons.gpp_good_outlined,
        color: Colors.teal.shade600,
        onTap: () => _showWarrantyModal(context),
      ),
      _GridItemData(
        title: 'Calculate Budget',
        subtitle: 'Estimate quantity & cost',
        icon: Icons.calculate_outlined,
        color: Colors.purple.shade600,
        onTap: () => context.go('/budget'),
      ),
      _GridItemData(
        title: 'History',
        subtitle: 'View recent activities',
        icon: Icons.history_rounded,
        color: Colors.blue.shade600,
        onTap: () => _showHistoryModal(context),
      ),
      _GridItemData(
        title: 'Profile',
        subtitle: 'Manage account details',
        icon: Icons.person_outline_rounded,
        color: Colors.indigo.shade600,
        onTap: () => context.go('/profile'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Tools',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSizes.p16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSizes.p16,
            mainAxisSpacing: AppSizes.p16,
            childAspectRatio: size.width > 900 ? 1.25 : 1.15,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _DashboardGridItem(data: item);
          },
        ),
      ],
    );
  }
}

class _GridItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _GridItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _DashboardGridItem extends StatefulWidget {
  final _GridItemData data;

  const _DashboardGridItem({required this.data});

  @override
  State<_DashboardGridItem> createState() => _DashboardGridItemState();
}

class _DashboardGridItemState extends State<_DashboardGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -4, 0)..scale(1.02))
            : Matrix4.identity(),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: widget.data.onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p8),
                    decoration: BoxDecoration(
                      color: widget.data.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.data.color.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.data.subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComplaintsBottomSheet extends StatefulWidget {
  const _ComplaintsBottomSheet();

  @override
  State<_ComplaintsBottomSheet> createState() => _ComplaintsBottomSheetState();
}

class _ComplaintsBottomSheetState extends State<_ComplaintsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _queryController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedType = 'Inquiry';

  @override
  void dispose() {
    _queryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Support request submitted! We will contact you within 24 hours.'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161426) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXL),
          topRight: Radius.circular(AppSizes.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: AppSizes.p24,
        right: AppSizes.p24,
        top: AppSizes.p24,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.p24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Complaints & Queries',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type of Query'),
                items: const [
                  DropdownMenuItem(value: 'Inquiry', child: Text('General Inquiry')),
                  DropdownMenuItem(value: 'Complaint', child: Text('Register a Complaint')),
                  DropdownMenuItem(value: 'Dealer request', child: Text('Store Partnership')),
                  DropdownMenuItem(value: 'Other', child: Text('Other support')),
                ],
                onChanged: (val) => setState(() => _selectedType = val ?? 'Inquiry'),
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  hintText: 'Enter your 10-digit number',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Mobile number is required';
                  if (val.trim().length != 10 || int.tryParse(val) == null) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _queryController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Explain your concern *',
                  hintText: 'Please detail your complaint or query here...',
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter some details';
                  if (val.trim().length < 10) return 'Please describe in at least 10 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p24),
              GradientButton(
                text: 'Submit Request',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarrantyDialog extends StatelessWidget {
  const _WarrantyDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.gpp_good_outlined, color: Colors.teal),
          SizedBox(width: 8),
          Text('Warranty Guidelines'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'ColorCraft partners with leading manufacturers to provide paint warranties ranging from 2 to 15 years.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.p12),
            _WarrantyBullet(title: 'Super Premium Paints', value: '10 - 15 Years (e.g. Everlast 12)'),
            _WarrantyBullet(title: 'Premium Brands', value: '5 - 8 Years (e.g. Royale Emulsion, Easy Clean)'),
            _WarrantyBullet(title: 'Eco/Budget Paints', value: '2 - 4 Years (e.g. Tractor Emulsion, Swagat Emulsion)'),
            _WarrantyBullet(title: 'Primers', value: '0 Years (Primers carry no standalone warranty)'),
            SizedBox(height: AppSizes.p16),
            Divider(),
            SizedBox(height: AppSizes.p8),
            Text(
              'How to Claim:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.p4),
            Text('• Make sure walls were treated with exterior/interior primer beforehand.\n• Retain the purchase invoice/bill generated by the dealer.\n• Claims must be reported to the store customer service within 30 days of paint distress.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _WarrantyBullet extends StatelessWidget {
  final String title;
  final String value;

  const _WarrantyBullet({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          children: [
            TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _HistoryDialog extends StatelessWidget {
  const _HistoryDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.history_rounded, color: Colors.blue),
          SizedBox(width: 8),
          Text('Activity History'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: ListView(
          shrinkWrap: true,
          children: const [
            _HistoryItem(
              title: 'Searched "Nexon Paints"',
              time: '15 mins ago',
              icon: Icons.search,
            ),
            _HistoryItem(
              title: 'Compared "Swagat Emulsion" vs "Royale"',
              time: '1 hour ago',
              icon: Icons.compare_arrows,
            ),
            _HistoryItem(
              title: 'Estimated Paint Budget for living room',
              time: 'Yesterday',
              icon: Icons.calculate_outlined,
            ),
            _HistoryItem(
              title: 'Submitted review for "Royale Emulsion"',
              time: '3 days ago',
              icon: Icons.rate_review_outlined,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _HistoryItem({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
