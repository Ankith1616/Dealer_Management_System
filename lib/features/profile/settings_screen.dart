import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p12),
                
                Card(
                  elevation: 0,
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    side: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                        title: const Text('Theme Mode'),
                        subtitle: Text(_getThemeModeName(themeMode)),
                        trailing: DropdownButton<ThemeMode>(
                          value: themeMode,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (ThemeMode? newMode) {
                            if (newMode != null) {
                              ref.read(themeProvider.notifier).setTheme(newMode);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light Mode'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark Mode'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System Default'),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && isDark),
                        onChanged: (bool value) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                        title: const Text('Dark Mode Toggle'),
                        subtitle: const Text('Quick toggle dark mode styling'),
                        secondary: Icon(
                          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.p24),
                
                const Text(
                  'Store Configuration (Mock)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.p12),
                
                Card(
                  elevation: 0,
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    side: BorderSide(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: true,
                        onChanged: (val) {},
                        title: const Text('Use Mock DB'),
                        subtitle: const Text('Simulate local database repositories'),
                        secondary: const Icon(Icons.storage_outlined, color: AppColors.primary),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        value: false,
                        onChanged: (val) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Firebase integration requires configuration. See implementation_plan.md')),
                          );
                        },
                        title: const Text('Live Firebase Synced'),
                        subtitle: const Text('Sync paint catalog and reviews with Firestore'),
                        secondary: const Icon(Icons.cloud_queue_rounded, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSizes.p32),
                
                const Center(
                  child: Text(
                    'ColorCraft Paints v1.0.0\nDesigned with Flutter & Riverpod',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}
