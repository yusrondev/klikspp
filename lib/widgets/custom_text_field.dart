import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klikspp/constraint/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final bool obscureText;
  final bool isNumber;
  final Function(String)? onChanged;
  final VoidCallback? onTapForgotPassword;
  final VoidCallback? toggleVisibility;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  final String? errorText; // 👈 Tambahan untuk error

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.obscureText = false,
    this.isNumber = false,
    this.onChanged,
    this.onTapForgotPassword,
    this.toggleVisibility,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.errorText, // 👈 Tambahan
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = AppColors.text;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.border),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            errorText: errorText, // 👈 ini yang bikin ada tulisan merah
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: toggleVisibility,
                  )
                : suffixIcon,
          ),
        ),
        if (isPassword && onTapForgotPassword != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTapForgotPassword,
              child: const Text(
                "Lupa Password?",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

