part of '../../../main.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<ScheduleItem>? _schedule;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      setState(() {
        _error = null;
        _schedule = null;
      });
      final bootstrap = await EventApiService().fetchBootstrap();
      setState(() {
        _schedule = bootstrap.schedule;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load schedule. Using fallback data.';
          _schedule = scheduleItems; // fallback
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSchedule = _schedule ?? scheduleItems;

    return DetailScaffold(
      title: "Today's Schedule",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          const Center(
            child: Text(
              '5 September 2026',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 16),
          if (_schedule == null && _error == null)
            const Center(child: CircularProgressIndicator())
          else if (currentSchedule.isEmpty)
            const Center(child: Text('No schedule available today.'))
          else
            for (final item in currentSchedule) ...[
              ScheduleTile(item: item),
              const SizedBox(height: 12),
            ],
          if (_schedule != null || _error != null)
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
