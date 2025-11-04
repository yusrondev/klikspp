import 'package:flutter/material.dart';
import 'package:klikspp/constraint/app_colors.dart';

enum CustomButtonType { primary, secondary, text, icon }

class CustomButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool fullWidth;
  final double? height;
  final double? width;

  const CustomButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.fullWidth = true,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CustomButtonType.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : width,
          height: height ?? 48,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: Offset(0, 4), // arah bayangan ke bawah
                ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0, // hilangkan default shadow
              ),
              onPressed: onPressed,
              child: Text(label ?? 'Button', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
        );

      case CustomButtonType.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : width,
          height: height ?? 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              side: const BorderSide(color: Colors.blueAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: onPressed,
            child: Text(label ?? 'Button'),
          ),
        );

      case CustomButtonType.text:
        return TextButton(
          onPressed: onPressed,
          child: Text(
            label ?? 'Button',
            style: const TextStyle(color: Colors.blueAccent),
          ),
        );

      case CustomButtonType.icon:
        return IconButton(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.ac_unit, color: Colors.blueAccent),
        );
    }
  }
}
