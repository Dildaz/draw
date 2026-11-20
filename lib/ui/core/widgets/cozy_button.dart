import 'package:flutter/material.dart';
import '../app_theme.dart';

class CozyButton extends StatefulWidget {
  const CozyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.coral,
    this.shadowColor,
    this.textColor = Colors.white,
    this.icon,
    this.height = 54,
    this.expanded = true,
    this.fontSize = 18,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color? shadowColor;
  final Color textColor;
  final IconData? icon;
  final double height;
  final bool expanded;
  final double fontSize;

  @override
  State<CozyButton> createState() => _CozyButtonState();
}

class _CozyButtonState extends State<CozyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final bg = enabled ? widget.color : const Color(0xFFD9CFC7);
    final lip = enabled
        ? (widget.shadowColor ??
            HSLColor.fromColor(widget.color)
                .withLightness(
                  (HSLColor.fromColor(widget.color).lightness - 0.14).clamp(0.0, 1.0),
                )
                .toColor())
        : const Color(0xFFBDB1A8);

    final child = GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        height: widget.height,
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: lip,
              offset: Offset(0, _pressed ? 1 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.textColor, size: 22),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Baloo',
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: widget.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return widget.expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}
