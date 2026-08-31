part of '../../../main.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onTabSelected, super.key});

  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeTopBar(onMenuTap: () => onTabSelected(3)),
            const SizedBox(height: 6),
            const BrandHeader(),
            const SizedBox(height: 14),
            const BuildingHero(),
            const SizedBox(height: 16),
            const WelcomePanel(),
            const SizedBox(height: 20),
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.94,
              children: [
                QuickActionCard(
                  label: 'Contribute',
                  icon: Icons.volunteer_activism,
                  color: _maroon,
                  onTap: () => onTabSelected(2),
                ),
                QuickActionCard(
                  label: 'Participate',
                  icon: Icons.theater_comedy,
                  color: _gold,
                  onTap: () => _push(context, const EventRegistrationPage()),
                ),
                QuickActionCard(
                  label: 'Volunteer',
                  icon: Icons.diversity_3,
                  color: _leaf,
                  onTap: () => _push(context, const VolunteerPage()),
                ),
                QuickActionCard(
                  label: "Today's Schedule",
                  icon: Icons.calendar_month,
                  color: _teal,
                  onTap: () => _push(context, const SchedulePage()),
                ),
                QuickActionCard(
                  label: 'Announcements',
                  icon: Icons.campaign,
                  color: _violet,
                  onTap: () => _push(context, const AnnouncementsPage()),
                ),
                QuickActionCard(
                  label: 'Utsav Gallery',
                  icon: Icons.photo_library,
                  color: const Color(0xFFE08912),
                  onTap: () => _push(context, const GalleryPage()),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const FestivalRibbon(),
          ],
        ),
      ),
    );
  }
}

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({required this.onMenuTap, super.key});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Menu',
          onPressed: onMenuTap,
          icon: const Icon(Icons.menu),
        ),
        const Spacer(),
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
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/btavani.png',
          width: 250,
          height: 120,
          fit: BoxFit.contain,
        ),
      ],
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
  const BuildingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Avani community buildings and garden',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 1.86,
          child: Stack(
            fit: StackFit.expand,
            children: [
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
              const Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ganesh Utsav 2026',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Bhavya Tulasi Vanam, Avani',
                      style: TextStyle(
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
                  'Welcome, Nagesh Gadde',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  'I-1204, Block I',
                  style: TextStyle(color: _muted, fontWeight: FontWeight.w600),
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
