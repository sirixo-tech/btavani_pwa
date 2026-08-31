import re

with open('lib/src/features/home/home_page.dart', 'r') as f:
    content = f.read()

replacement = """class HomePage extends StatefulWidget {
  const HomePage({required this.onTabSelected, super.key});

  final ValueChanged<int> onTabSelected;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String>? _appSettings;

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
        });
      }
    } catch (e) {
      // Use defaults
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
            HomeTopBar(onMenuTap: () => widget.onTabSelected(3)),
            const SizedBox(height: 6),
            BrandHeader(appSettings: _appSettings),
            const SizedBox(height: 14),
            BuildingHero(appSettings: _appSettings),
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
                  onTap: () => widget.onTabSelected(2),
                ),
"""

content = re.sub(r"class HomePage extends StatelessWidget \{.*?onTap: \(\) => onTabSelected\(2\),\n                \),", replacement, content, flags=re.DOTALL)

brand_header_replacement = """class BrandHeader extends StatelessWidget {
  const BrandHeader({this.appSettings, super.key});
  
  final Map<String, String>? appSettings;

  @override
  Widget build(BuildContext context) {
    final logoUrl = appSettings?['app_logo'];
    return Column(
      children: [
        logoUrl != null 
          ? Image.network(
              logoUrl,
              width: 250,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildFallback(),
            )
          : _buildFallback(),
      ],
    );
  }
  
  Widget _buildFallback() {
    return Image.asset(
      'assets/images/btavani.png',
      width: 250,
      height: 120,
      fit: BoxFit.contain,
    );
  }
}"""

content = re.sub(r"class BrandHeader extends StatelessWidget \{.*?fit: BoxFit\.contain,\n        \),\n      \],\n    \);\n  \}\n\}", brand_header_replacement, content, flags=re.DOTALL)

building_hero_replacement = """class BuildingHero extends StatelessWidget {
  const BuildingHero({this.appSettings, super.key});
  
  final Map<String, String>? appSettings;

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
              bannerUrl != null
                ? Image.network(
                    bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => CustomPaint(painter: BuildingScenePainter()),
                  )
                : Image.asset(
                    'assets/images/avani_building.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => CustomPaint(painter: BuildingScenePainter()),
                  ),"""

content = re.sub(r"class BuildingHero extends StatelessWidget \{.*?CustomPaint\(painter: BuildingScenePainter\(\)\),\n              \),", building_hero_replacement, content, flags=re.DOTALL)

with open('lib/src/features/home/home_page.dart', 'w') as f:
    f.write(content)
