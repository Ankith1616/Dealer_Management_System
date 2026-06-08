import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool gradient;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradient
          ? const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientPrimary,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            )
          : null,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: showBackButton,
        iconTheme: IconThemeData(
          color: gradient ? Colors.white : Theme.of(context).iconTheme.color,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: gradient ? Colors.white : Theme.of(context).textTheme.headlineMedium?.color,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
