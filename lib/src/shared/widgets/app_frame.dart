part of '../../../main.dart';

class AppFrame extends StatelessWidget {
  const AppFrame({required this.child, this.maxWidth = 430, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cream,
        gradient: RadialGradient(
          center: Alignment(-0.9, -1.0),
          radius: 1.35,
          colors: [_goldLight, _cream, Color(0xFFEAF7F0)],
          stops: [0, 0.43, 1],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: Colors.white.withValues(alpha: 0.54),
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
