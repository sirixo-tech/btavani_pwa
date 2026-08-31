part of '../../../main.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: "Today's Schedule",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              '5 September 2026',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 16),
          for (final item in scheduleItems) ...[
            ScheduleTile(item: item),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_goldLight.withValues(alpha: 0.62), _surfaceWarm],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: _gold.withValues(alpha: 0.20)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Timings may change.\nPlease check announcements for updates.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleTile extends StatelessWidget {
  const ScheduleTile({required this.item, super.key});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_maroon, _maroonDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              item.time,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
