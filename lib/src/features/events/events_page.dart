part of '../../../main.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({this.onTabSelected, super.key});

  final ValueChanged<int>? onTabSelected;

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  int filter = 0;
  List<EventItem>? _events;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _error = null;
        _events = null;
      });
      final bootstrap = await EventApiService().fetchBootstrap();
      setState(() {
        _events = bootstrap.events;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events. Using fallback data.';
        _events = fallbackEventItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEvents = _events ?? fallbackEventItems;
    final visibleEvents = switch (filter) {
      1 => const <EventItem>[],
      2 => currentEvents,
      _ => currentEvents,
    };

    return SafeArea(
      child: Column(
        children: [
          PageTopBar(
            title: 'Events',
            leading: IconButton(
              tooltip: 'Menu',
              onPressed: () => widget.onTabSelected?.call(3),
              icon: const Icon(Icons.menu),
            ),
            trailing: IconButton(
              tooltip: 'Search',
              onPressed: () => _snack(context, 'Search ready for integration'),
              icon: const Icon(Icons.search),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: SegmentedPill(
              labels: const ['Upcoming', 'Past', 'All'],
              selectedIndex: filter,
              onChanged: (value) => setState(() => filter = value),
            ),
          ),
          Expanded(
            child: _events == null && _error == null
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C1D45)))
                : visibleEvents.isEmpty
                    ? const EventsEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        itemCount: visibleEvents.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = visibleEvents[index];
                          return EventCard(
                            item: item,
                            onTap: () =>
                                _push(context, EventDetailsPage(item: item)),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class EventsEmptyState extends StatelessWidget {
  const EventsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: panelDecoration(),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy_outlined, color: _maroon, size: 34),
              SizedBox(height: 10),
              Text(
                'No past events yet',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 4),
              Text(
                'Completed events will appear here after the utsav.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({required this.item, required this.onTap, super.key});

  final EventItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: panelDecoration(),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color.withValues(alpha: 0.18),
                      item.color.withValues(alpha: 0.07),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: item.color.withValues(alpha: 0.16)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _maroon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.date,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.venue,
                      style: const TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _surfaceWarm,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: _maroon,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({required this.item, super.key});

  final EventItem item;

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Event Details',
      trailing: IconButton(
        tooltip: 'Share',
        onPressed: () => _snack(context, 'Share link ready for integration'),
        icon: const Icon(Icons.share_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EventHero(item: item),
          const SizedBox(height: 16),
          InfoSection(
            title: 'About',
            child: Text(
              item.description,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const InfoSection(
            title: 'Highlights',
            child: Column(
              children: [
                CheckLine('Music and dance'),
                CheckLine('Skits and talents'),
                CheckLine('Kids performances'),
                CheckLine('Fun and prizes'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'REGISTER NOW',
            onPressed: () =>
                _push(context, EventRegistrationPage(initialEvent: item.title)),
          ),
        ],
      ),
    );
  }
}

class EventHero extends StatelessWidget {
  const EventHero({required this.item, super.key});

  final EventItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 188,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    EventHeroFallback(item: item),
              )
            else if (item.imageAsset case final imageAsset?)
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    EventHeroFallback(item: item),
              )
            else
              EventHeroFallback(item: item),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _maroonDark.withValues(alpha: 0.74),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelPill(label: item.venue, color: _goldLight),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventHeroFallback extends StatelessWidget {
  const EventHeroFallback({required this.item, super.key});

  final EventItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_maroonDark, item.color.withValues(alpha: 0.84)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -24,
            child: Icon(
              item.icon,
              color: Colors.white.withValues(alpha: 0.10),
              size: 154,
            ),
          ),
          Positioned(
            left: 18,
            top: 22,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(item.icon, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

class StageFigure extends StatelessWidget {
  const StageFigure({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 8, backgroundColor: color),
        const SizedBox(height: 3),
        Container(
          width: 18,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}
