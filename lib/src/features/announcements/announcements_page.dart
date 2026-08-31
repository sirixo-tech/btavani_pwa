part of '../../../main.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  int filter = 0;

  @override
  Widget build(BuildContext context) {
    final visibleAnnouncements = switch (filter) {
      1 =>
        announcements
            .where((item) => item.label.toLowerCase() == 'notice')
            .toList(),
      2 =>
        announcements
            .where((item) => item.label.toLowerCase() == 'event')
            .toList(),
      3 =>
        announcements
            .where((item) => item.label.toLowerCase() == 'important')
            .toList(),
      _ => announcements,
    };

    return DetailScaffold(
      title: 'Announcements',
      useScroll: false,
      trailing: IconButton(
        tooltip: 'Search',
        onPressed: () {},
        icon: Badge(
          backgroundColor: _maroon,
          smallSize: 8,
          child: const Icon(Icons.search),
        ),
      ),
      child: Column(
        children: [
          SegmentedPill(
            labels: const ['All', 'General', 'Events', 'Important'],
            selectedIndex: filter,
            onChanged: (value) => setState(() => filter = value),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: visibleAnnouncements.isEmpty
                ? const AnnouncementsEmptyState()
                : ListView.separated(
                    itemCount: visibleAnnouncements.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        AnnouncementCard(item: visibleAnnouncements[index]),
                  ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => filter = 0),
            child: const Text('View All Announcements'),
          ),
        ],
      ),
    );
  }
}

class AnnouncementsEmptyState extends StatelessWidget {
  const AnnouncementsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: panelDecoration(),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, color: _maroon, size: 34),
            SizedBox(height: 10),
            Text(
              'No announcements',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 4),
            Text(
              'Updates for this category will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({required this.item, super.key});

  final AnnouncementItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: panelDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelPill(label: item.label, color: item.color),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: _maroonDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.date,
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.11),
              border: Border.all(color: item.color.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(item.icon, color: item.color, size: 29),
          ),
        ],
      ),
    );
  }
}
