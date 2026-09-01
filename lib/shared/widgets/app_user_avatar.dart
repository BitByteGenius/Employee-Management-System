import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class AppUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final VoidCallback? onTap;

  const AppUserAvatar({
    super.key,
    this.imageUrl,
    this.name = 'User',
    this.radius = 16,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.onTap,
  });

  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasValidImage = imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

    final effectiveBg = backgroundColor ?? AppColors.primaryContainer;
    final effectiveText = textColor ?? AppColors.onPrimaryContainer;
    final effectiveFontSize = fontSize ?? (radius * 0.75);

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBg,
      backgroundImage: hasValidImage
          ? CachedNetworkImageProvider(imageUrl!.trim())
          : null,
      child: !hasValidImage
          ? Text(
              initials,
              style: AppTypography.labelSm(color: effectiveText).copyWith(
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: avatar,
      );
    }

    return avatar;
  }
}
