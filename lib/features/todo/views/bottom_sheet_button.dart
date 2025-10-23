import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_colors.dart';

class BottomSheetButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const BottomSheetButton({
    super.key,
    required this.onPressed,
    this.text = "my button",
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'elevated_button_bottom_sheet',
      container: true,
      excludeSemantics: true,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
        ),
        onPressed: onPressed,
        child: const Text("my button"),
      ),
    );
  }
}
