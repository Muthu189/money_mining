import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool isDisabled = onPressed == null;
    return Container(
      width: width ?? double.infinity,
      height: height ?? 56,
      decoration: BoxDecoration(
        gradient: isDisabled 
          ? null 
          : const LinearGradient(
              colors: [
                AppColors.goldHighlight,
                AppColors.luxuryGold,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
        color: isDisabled ? Colors.white12 : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDisabled 
          ? [] 
          : const [
              BoxShadow(
                color: Color(0x33D4AF37),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.matteBlack,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text.toUpperCase(),
                    style: AppTextStyles.button.copyWith(
                      color: isDisabled ? Colors.white24 : AppColors.matteBlack,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: AppColors.matteBlack, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}
