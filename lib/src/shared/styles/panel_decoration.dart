part of '../../../main.dart';

BoxDecoration panelDecoration({
  Color color = _paper,
  Color borderColor = _line,
  double radius = 16,
  bool elevated = true,
}) {
  return BoxDecoration(
    color: color,
    border: Border.all(color: borderColor.withValues(alpha: 0.88)),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: elevated
        ? [
            BoxShadow(
              color: _maroonDark.withValues(alpha: 0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.62),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ]
        : null,
  );
}
