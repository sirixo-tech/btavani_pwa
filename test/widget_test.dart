import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('festival app renders home and opens events tab', (tester) async {
    await _pumpFestivalApp(tester);

    expect(
      find.image(const AssetImage('assets/images/btavani.png')),
      findsOneWidget,
    );
    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Contribute'), findsWidgets);

    await tester.tap(find.text('Events').last);
    await tester.pumpAndSettle();

    expect(find.text('Grand Cultural Evening'), findsOneWidget);
    expect(find.text('Kids Activity and Competitions'), findsOneWidget);
    expect(find.byIcon(Icons.event_note), findsOneWidget);
  });

  testWidgets('home quick actions open core screens', (tester) async {
    await _pumpFestivalApp(tester);

    await tester.tap(find.text("Today's Schedule"));
    await tester.pumpAndSettle();
    expect(find.text('Ganesh Pooja'), findsOneWidget);
    await _goBack(tester);

    await tester.tap(find.text('Announcements'));
    await tester.pumpAndSettle();
    expect(find.text('Water Supply Maintenance'), findsOneWidget);
    await _goBack(tester);

    await tester.tap(find.text('Volunteer'));
    await tester.pumpAndSettle();
    expect(find.text('Pooja and Rituals'), findsOneWidget);
    await tester.tap(find.text('Decoration'));
    await tester.pump();
    expect(find.byType(CheckboxListTile), findsWidgets);
    await _goBack(tester);

    await _tapQuickAction(tester, 'Events');
    await tester.pumpAndSettle();
    expect(find.text('Event Registration'), findsOneWidget);
    expect(find.text('REGISTER'), findsOneWidget);
    await tester.tap(find.text('REGISTER'));
    await tester.pumpAndSettle();
    expect(find.text('Please select an event.'), findsOneWidget);
    expect(find.text('Please enter the participant name.'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grand Cultural Evening').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Arjun Rao');
    await tester.enterText(find.byType(TextFormField).at(1), 'I-1204');
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('11 - 15 years').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '9876543210');
    await _goBack(tester);
  });

  testWidgets('gallery is simple and photo preview works', (tester) async {
    await _pumpFestivalApp(tester);

    await _tapQuickAction(tester, 'Gallery');
    await tester.pumpAndSettle();

    expect(find.text('Festival Moments'), findsOneWidget);
    expect(find.text('Ganesh Alankaram'), findsWidgets);
    expect(find.text('9 photos'), findsOneWidget);

    await tester.tap(find.text('Evening Darshan').last);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Aarti decor'), findsWidgets);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(find.text('Videos'));
    await tester.pumpAndSettle();
    expect(find.text('Videos will appear here soon'), findsOneWidget);
  });

  testWidgets('more menu opens auction and contribution tab works', (
    tester,
  ) async {
    await _pumpFestivalApp(tester);

    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    expect(find.text('Laddoo Auction'), findsOneWidget);

    await tester.tap(find.text('Laddoo Auction'));
    await tester.pumpAndSettle();
    expect(find.text('Rs 11,501'), findsOneWidget);
    await tester.tap(find.text('PLACE YOUR BID'));
    await tester.pumpAndSettle();
    expect(find.text('Place Your Bid'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), '12001');
    await tester.enterText(find.byType(TextFormField).at(1), 'i-1302');
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.text('Rs 11,501'), findsOneWidget);
    expect(find.text('by I-1204'), findsOneWidget);
    await _goBack(tester);
    await tester.pump(const Duration(seconds: 4));

    await tester.tap(find.text('Contribute').last);
    await tester.pumpAndSettle();
    expect(find.text('Contribute to Avani Ganesh Utsav 2026'), findsOneWidget);
    expect(find.text('₹5,001'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Quick Access'), findsOneWidget);
  });
}

Future<void> _pumpFestivalApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const TulasiVanamApp());
}

Future<void> _goBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
  await tester.pumpAndSettle();
}

Future<void> _tapQuickAction(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(QuickActionCard, label));
  await tester.pumpAndSettle();
}
