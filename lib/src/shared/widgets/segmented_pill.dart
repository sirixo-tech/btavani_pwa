part of '../../../main.dart';

class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _maroonDark.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? _maroon : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: i == selectedIndex
                        ? [
                            BoxShadow(
                              color: _maroon.withValues(alpha: 0.20),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: i == selectedIndex ? Colors.white : _ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
