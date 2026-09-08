import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_scales/services/dragon_service.dart';
import 'package:safe_scales/ui/widgets/dress_up_action_button.dart';

void main() {
  test('phase display names map internal ids to Egg, Baby, Teen, Adult', () {
    expect(DragonService.phaseDisplayNames['egg'], 'Egg');
    expect(DragonService.phaseDisplayNames['stage1'], 'Baby');
    expect(DragonService.phaseDisplayNames['stage2'], 'Teen');
    expect(DragonService.phaseDisplayNames['final'], 'Adult');
  });

  testWidgets('Phase button shows title and current phase subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DressUpActionButton(
            icon: const Icon(Icons.pets),
            title: 'Phase',
            subtitle: 'Egg',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Phase'), findsOneWidget);
    expect(find.text('Egg'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsNothing);
  });

  testWidgets('Habitat button keeps title plus habitat subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DressUpActionButton(
            icon: const Icon(Icons.home_outlined),
            title: 'Habitat',
            subtitle: 'Dark Cave',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Habitat'), findsOneWidget);
    expect(find.text('Dark Cave'), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}
