import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the dress-up body Column: leftover height goes to the habitat,
/// and the item tray is packed against the bottom with a safe-area inset.
void main() {
  testWidgets('habitat fills leftover height and tray sits on the bottom', (
    tester,
  ) async {
    const screenSize = Size(390, 844);
    const bottomInset = 34.0;
    await tester.binding.setSurfaceSize(screenSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: screenSize,
          padding: EdgeInsets.only(bottom: bottomInset),
        ),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Jack')),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Text('Dress up your dragon'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      Expanded(child: Text('Phase')),
                      Expanded(child: Text('Habitat')),
                      Expanded(child: Text('Help')),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    key: Key('habitat'),
                    color: Color(0xFF123456),
                  ),
                ),
                Container(
                  key: Key('item-tray'),
                  width: double.infinity,
                  color: Color(0xFF2A2A3A),
                  child: SafeArea(
                    top: false,
                    minimum: EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      height: 120,
                      child: Text(
                        'Long press items to drag them onto your dragon',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dress up your dragon'), findsOneWidget);
    expect(find.text('Phase'), findsOneWidget);
    expect(find.text('Habitat'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);

    final habitat = tester.getRect(find.byKey(const Key('habitat')));
    final tray = tester.getRect(find.byKey(const Key('item-tray')));

    expect(habitat.bottom, closeTo(tray.top, 0.5));
    expect(tray.bottom, screenSize.height);
    expect(habitat.height, greaterThan(400));

    final hint = tester.getRect(
      find.text('Long press items to drag them onto your dragon'),
    );
    expect(hint.bottom, lessThanOrEqualTo(screenSize.height - bottomInset));
  });
}
