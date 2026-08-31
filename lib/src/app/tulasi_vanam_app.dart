part of '../../main.dart';

class TulasiVanamApp extends StatelessWidget {
  const TulasiVanamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BTAOWA Ganesh Utsav',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _maroon,
          primary: _maroon,
          secondary: _gold,
          surface: _paper,
          brightness: Brightness.light,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.72),
            foregroundColor: _maroonDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: _line.withValues(alpha: 0.88)),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          elevation: 0,
          backgroundColor: _paper.withValues(alpha: 0.96),
          indicatorColor: _maroon.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected) ? _maroon : _muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w900,
            color: _ink,
            letterSpacing: 0,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w900,
            color: _ink,
            letterSpacing: 0,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w900,
            color: _ink,
            letterSpacing: 0,
          ),
          bodyMedium: TextStyle(color: _ink, height: 1.42),
          labelLarge: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      home: const FestivalShell(),
    );
  }
}
