part of '../../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.onTabSelected, super.key});

  final ValueChanged<int> onTabSelected;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String>? _appSettings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final bootstrap = await EventApiService().fetchBootstrap();
      if (mounted) {
        setState(() {
          _appSettings = bootstrap.appSettings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeTopBar(
              onMenuTap: () => widget.onTabSelected(3),
              appSettings: _appSettings,
            ),
            const SizedBox(height: 14),
            BuildingHero(appSettings: _appSettings, isLoading: _isLoading),
            const SizedBox(height: 20),
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                QuickActionCard(
                  label: 'Chanda',
                  icon: Icons.volunteer_activism,
                  color: _maroon,
                  onTap: () => widget.onTabSelected(2),
                ),
                QuickActionCard(
                  label: 'Collections',
                  icon: Icons.account_balance_wallet,
                  color: _gold,
                  onTap: () => _push(context, const TransparencyPage()),
                ),
                QuickActionCard(
                  label: "Today's Schedule",
                  icon: Icons.calendar_month,
                  color: _teal,
                  onTap: () => _push(context, const SchedulePage()),
                ),
                QuickActionCard(
                  label: 'Event Registration',
                  icon: Icons.theater_comedy,
                  color: _violet,
                  onTap: () => _push(context, const EventRegistrationPage()),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ContributionTrackerCard(appSettings: _appSettings),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({required this.onMenuTap, this.appSettings, super.key});

  final VoidCallback onMenuTap;
  final Map<String, String>? appSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Menu',
          onPressed: onMenuTap,
          icon: const Icon(Icons.menu),
        ),
        _buildLogo(),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => _push(context, const AnnouncementsPage()),
          icon: Badge.count(
            count: 3,
            backgroundColor: _maroon,
            child: const Icon(Icons.notifications_none),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    final logoUrl = appSettings?['app_logo'];
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        width: 140,
        height: 50,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/btavani.png',
          width: 140,
          height: 50,
          fit: BoxFit.contain,
        ),
      );
    }
    return Image.asset(
      'assets/images/btavani.png',
      width: 140,
      height: 50,
      fit: BoxFit.contain,
    );
  }
}

class LotusLogo extends StatelessWidget {
  const LotusLogo({this.size = 52, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: CustomPaint(painter: LotusPainter()),
    );
  }
}

class LotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.78);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = -3; i <= 3; i++) {
      final angle = i * 0.36;
      final petal = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          center.dx + (i * size.width * 0.11),
          center.dy - size.height * 0.52,
          center.dx + (i * size.width * 0.05),
          center.dy - size.height * (0.95 - angle.abs() * 0.22),
        )
        ..quadraticBezierTo(
          center.dx - (i * size.width * 0.03),
          center.dy - size.height * 0.52,
          center.dx,
          center.dy,
        );
      paint.color = i == 0 ? _gold : const Color(0xFFE48B18);
      canvas.drawPath(petal, paint);
    }

    paint.color = _leaf;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.34, size.height * 0.78),
        width: size.width * 0.42,
        height: size.height * 0.17,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.66, size.height * 0.78),
        width: size.width * 0.42,
        height: size.height * 0.17,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BuildingHero extends StatelessWidget {
  const BuildingHero({this.appSettings, this.isLoading = false, super.key});

  final Map<String, String>? appSettings;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bannerUrl = appSettings?['home_banner'];

    return Semantics(
      label: 'Avani community buildings and garden',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 1.86,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isLoading)
                Container(color: _surfaceWarm)
              else if (bannerUrl != null)
                Image.network(
                  bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      CustomPaint(painter: BuildingScenePainter()),
                )
              else
                Image.asset(
                  'assets/images/avani_building.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      CustomPaint(painter: BuildingScenePainter()),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      _maroonDark.withValues(alpha: 0.56),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildingScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFBDE7F4), Color(0xFFFFE6B5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.72);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.12, 90, 20),
      cloud,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.67, size.height * 0.09, 110, 24),
      cloud,
    );

    final buildingPaint = Paint()..color = const Color(0xFFE7D6C6);
    final shade = Paint()..color = const Color(0xFFC6A58D);
    final window = Paint()..color = const Color(0xFF566E7C);
    final buildings = [
      Rect.fromLTWH(
        size.width * 0.03,
        size.height * 0.34,
        size.width * 0.18,
        size.height * 0.36,
      ),
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.28,
        size.width * 0.22,
        size.height * 0.43,
      ),
      Rect.fromLTWH(
        size.width * 0.47,
        size.height * 0.31,
        size.width * 0.19,
        size.height * 0.39,
      ),
      Rect.fromLTWH(
        size.width * 0.68,
        size.height * 0.27,
        size.width * 0.24,
        size.height * 0.45,
      ),
    ];

    for (final rect in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        buildingPaint,
      );
      canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 7), shade);
      for (var row = 0; row < 4; row++) {
        for (var col = 0; col < 3; col++) {
          final x = rect.left + 10 + col * (rect.width - 20) / 2;
          final y = rect.top + 17 + row * 18;
          canvas.drawRect(Rect.fromLTWH(x, y, 7, 9), window);
        }
      }
    }

    final lawn = Paint()..color = const Color(0xFF579742);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.70, size.width, size.height * 0.30),
      lawn,
    );
    final path = Path()
      ..moveTo(size.width * 0.05, size.height)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.77,
        size.width * 0.55,
        size.height * 0.89,
        size.width,
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFCDB28A));

    final signRect = Rect.fromLTWH(
      size.width * 0.70,
      size.height * 0.64,
      size.width * 0.22,
      size.height * 0.16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(signRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFF66501E),
    );
    final paragraph = TextPainter(
      text: const TextSpan(
        text: 'AVANI',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: signRect.width);
    paragraph.paint(
      canvas,
      Offset(
        signRect.left + (signRect.width - paragraph.width) / 2,
        signRect.top + signRect.height * 0.30,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WelcomePanel extends StatelessWidget {
  const WelcomePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: panelDecoration(color: _paper.withValues(alpha: 0.94)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_goldLight, _gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: _maroonDark),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, To Vanam',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ],
            ),
          ),
          Badge.count(
            count: 3,
            backgroundColor: _maroon,
            child: Icon(
              Icons.notifications_active_outlined,
              color: _maroon.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.94), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 25, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FestivalRibbon extends StatelessWidget {
  const FestivalRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_maroonDark, _maroon, _gold],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Text(
        'GANPATI BAPPA MORYA',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class ContributionTrackerCard extends StatelessWidget {
  const ContributionTrackerCard({this.appSettings, super.key});

  final Map<String, String>? appSettings;

  @override
  Widget build(BuildContext context) {
    final totalAmount = appSettings?['tracker_total_amount'] ?? '12,48,500';
    final targetPercentage = appSettings?['tracker_target_percentage'] ?? '62';
    final familiesCount = appSettings?['tracker_families_count'] ?? '1,247';
    final lastUpdated = appSettings?['tracker_last_updated'] ?? 'Today, 7:30 PM';
    
    final progressValue = double.tryParse(targetPercentage) != null 
        ? (double.parse(targetPercentage) / 100).clamp(0.0, 1.0) 
        : 0.62;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2E6CD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ganesh Utsav Contribution Tracker',
                  style: TextStyle(
                    color: Color(0xFF8E1119),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ $totalAmount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Contributions Received',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$targetPercentage%',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'of Target',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF2E7D32),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.family_restroom, size: 20, color: Color(0xFFCCA716)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          familiesCount,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Families Contributed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lastUpdated,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Last Updated',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => _push(context, const TransparencyPage()),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8E1119),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'VIEW FULL DETAILS',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
