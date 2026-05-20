import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool loading;
  final EdgeInsets padding;
  final double fontSize;
  final double borderRadius;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.loading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.fontSize = 16,
    this.borderRadius = 14,
    this.fullWidth = false,
  });

  /// --- SMALL BUTTON ---
  factory PrimaryButton.small({
    required String text,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return PrimaryButton(
      text: text,
      onTap: onTap,
      loading: loading,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      fontSize: 14,
      borderRadius: 10,
    );
  }

  /// --- FULL WIDTH BUTTON ---
  factory PrimaryButton.fullWidth({
    required String text,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return PrimaryButton(
      text: text,
      onTap: onTap,
      loading: loading,
      fullWidth: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        padding: padding,
        minimumSize: fullWidth ? const Size(double.infinity, 0) : Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: loading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
