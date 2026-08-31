part of '../../../main.dart';

class PageTopBar extends StatelessWidget {
  const PageTopBar({
    required this.title,
    this.leading,
    this.trailing,
    this.compact = false,
    super.key,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: SizedBox(
        height: compact ? 48 : 54,
        child: Row(
          children: [
            SizedBox(width: 48, child: leading),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _maroonDark,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 17 : 18,
                  letterSpacing: 0,
                ),
              ),
            ),
            SizedBox(width: 48, child: trailing),
          ],
        ),
      ),
    );
  }
}
