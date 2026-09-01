part of '../../../main.dart';

class MorePage extends StatelessWidget {
  const MorePage({required this.onTabSelected, super.key});

  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTopBar(
              title: 'More',
              compact: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => onTabSelected(0),
              ),
            ),
            const SizedBox(height: 4),
            const BrandMiniHeader(),
            const SizedBox(height: 20),
            MenuTile(
              icon: Icons.calendar_month,
              title: "Today's Schedule",
              subtitle: 'Pooja, aarti, cultural program and prasadam',
              onTap: () => _push(context, const SchedulePage()),
            ),
            MenuTile(
              icon: Icons.campaign,
              title: 'Announcements',
              subtitle: 'Society notices and festival updates',
              onTap: () => _push(context, const AnnouncementsPage()),
            ),
            MenuTile(
              icon: Icons.photo_library,
              title: 'Utsav Gallery',
              subtitle: 'Photos and videos from celebrations',
              onTap: () => _push(context, const GalleryPage()),
            ),
            MenuTile(
              icon: Icons.account_balance_wallet,
              title: 'Collections',
              subtitle: 'Block-wise verified collection and expenses',
              onTap: () => _push(context, const TransparencyPage()),
            ),
            MenuTile(
              icon: Icons.gavel,
              title: 'Laddoo Auction',
              subtitle: 'Live bidding opens during the event',
              onTap: () => _push(context, const AuctionPage()),
            ),
            MenuTile(
              icon: Icons.assignment_turned_in,
              title: 'Participation Form',
              subtitle: 'Register for singing, dance, skits and kids events',
              onTap: () => _push(context, const EventRegistrationPage()),
            ),
            MenuTile(
              icon: Icons.handshake,
              title: 'Volunteer',
              subtitle: 'Choose the area where you can help',
              onTap: () => _push(context, const VolunteerPage()),
            ),
            MenuTile(
              icon: Icons.favorite,
              title: 'Contribution',
              subtitle: 'Support Avani Ganesh Utsav 2026',
              onTap: () => onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandMiniHeader extends StatefulWidget {
  const BrandMiniHeader({super.key});

  @override
  State<BrandMiniHeader> createState() => _BrandMiniHeaderState();
}

class _BrandMiniHeaderState extends State<BrandMiniHeader> {
  String? _appLogoUrl;

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
          _appLogoUrl = bootstrap.appSettings['app_logo'];
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_maroonDark, _maroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _maroon.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _appLogoUrl != null && _appLogoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: _appLogoUrl!,
              height: 86,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/btavani.png',
                height: 86,
                fit: BoxFit.contain,
              ),
            )
          : Image.asset(
              'assets/images/btavani.png',
              height: 86,
              fit: BoxFit.contain,
            ),
    );
  }
}

class MenuTile extends StatelessWidget {
  const MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: panelDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _surfaceWarm,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _maroon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _maroon.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.chevron_right, color: _maroon, size: 20),
        ),
        onTap: onTap,
      ),
    );
  }
}
