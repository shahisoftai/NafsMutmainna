import 'package:flutter/material.dart';
import 'package:nafsmutmainna/src/presentation/theme/colors.dart';
import 'package:nafsmutmainna/src/presentation/theme/typography.dart';

/// Custom app bar widget following Single Responsibility Principle
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTypography.h6.copyWith(color: AppColors.textOnPrimary),
      ),
      backgroundColor: backgroundColor,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}