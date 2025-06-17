import 'dart:ui';
import 'package:flutter/material.dart';

/// Un estilo de botón azul con fondo blur, borde resaltado y texto blanco.
class BlurredBlueButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double blurSigma;
  final double? width;
  final double? height;
  final Color? customBackground;

  const BlurredBlueButton({
    super.key,
    required this.child,
    this.onPressed,
    this.icon,
    this.padding,
    this.borderRadius = 14,
    this.borderWidth = 2,
    this.borderColor = const Color(0xFF2256A3),
    this.blurSigma = 12,
    this.width,
    this.height,
    this.customBackground,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = icon == null
        ? child
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              child,
            ],
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo blur azul translúcido
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: customBackground ?? const Color(0x882256A3), // azul translúcido
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor.withOpacity(0.85),
                  width: borderWidth,
                ),
              ),
            ),
          ),
          Material(
            color: customBackground ?? Colors.blue[700]?.withOpacity(onPressed != null ? 0.85 : 0.5),
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onPressed,
              child: Container(
                width: width,
                height: height,
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                alignment: Alignment.center,
                child: buttonContent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
