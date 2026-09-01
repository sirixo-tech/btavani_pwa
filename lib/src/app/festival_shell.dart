part of '../../main.dart';

class FestivalShell extends StatefulWidget {
  const FestivalShell({this.initialIndex = 0, super.key});
  final int initialIndex;

  @override
  State<FestivalShell> createState() => _FestivalShellState();
}

class _FestivalShellState extends State<FestivalShell> {
  late int _selectedIndex = widget.initialIndex;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onTabSelected: _selectTab),
      const GalleryPage(),
      ContributePage(onBackToHome: () => _selectTab(0)),
      MorePage(onTabSelected: _selectTab),
    ];

    return AppFrame(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: DecoratedBox(
              decoration: panelDecoration(radius: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: NavigationBar(
                  height: 68,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectTab,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home, color: _maroon),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.photo_library_outlined),
                      selectedIcon: Icon(Icons.photo_library, color: _maroon),
                      label: 'Gallery',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.favorite_border),
                      selectedIcon: Icon(Icons.favorite, color: _maroon),
                      label: 'Contribute',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu),
                      selectedIcon: Icon(Icons.menu, color: _maroon),
                      label: 'More',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
