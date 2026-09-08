import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_scales/ui/widgets/scrollable_completion_body.dart';

void main() {
  testWidgets(
    'ScrollableCompletionBody keeps action reachable on a short viewport',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScrollableCompletionBody(
              content: SizedBox(
                height: 420,
                child: Text('Completion content'),
              ),
              action: ElevatedButton(
                onPressed: null,
                child: Text('RETURN TO LESSON'),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final Finder action = find.text('RETURN TO LESSON');
      expect(action, findsOneWidget);

      await tester.ensureVisible(action);
      await tester.pumpAndSettle();

      expect(tester.getRect(action).bottom, lessThanOrEqualTo(500));
    },
  );

  testWidgets(
    'ScrollableCompletionBody does not overflow on a tall viewport',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScrollableCompletionBody(
              content: Text('Completion content'),
              action: ElevatedButton(
                onPressed: null,
                child: Text('RETURN TO LESSON'),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('RETURN TO LESSON'), findsOneWidget);
      expect(find.byType(ScrollableCompletionBody), findsOneWidget);
    },
  );
}
