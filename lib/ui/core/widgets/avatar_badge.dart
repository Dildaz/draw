import 'package:flutter/material.dart';
import '../app_theme.dart';

const List<Color> kFrameColors = [
  AppColors.coral,
  AppColors.amber,
  AppColors.sky,
  AppColors.purple,
  AppColors.green,
];

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.avatarIndex,
    this.size = 48,
    this.frameIndex = 0,
    this.showOnlineDot = false,
    this.isOnline = false,
  });

  final int avatarIndex;
  final double size;
  final int frameIndex;
  final bool showOnlineDot;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final safeIdx = avatarIndex.clamp(0, 15).toString().padLeft(2, '0');
    final ringColor = kFrameColors[frameIndex % kFrameColors.length];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.06),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: ringColor, width: (size * 0.065).clamp(2.0, 4.5)),
            boxShadow: [
              BoxShadow(
                color: ringColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/avatars/avatar_$safeIdx.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showOnlineDot)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.green : const Color(0xFFB5A9A0),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
