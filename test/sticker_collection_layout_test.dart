import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_scales/models/sticker_item_model.dart';
import 'package:safe_scales/ui/widgets/sticker_collection_widget.dart';

void main() {
  testWidgets('item tray sits at the bottom and keeps items above the safe area',
      (tester) async {
    const screenSize = Size(390, 844);
    const bottomInset = 34.0;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: screenSize,
          padding: EdgeInsets.only(bottom: bottomInset),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: ColoredBox(color: Colors.blue)),
                StickerCollectionWidget(
                  isLoadingAccessories: false,
                  userAccessories: [
                    Item(
                      id: 'cap',
                      type: ItemType.item,
                      name: 'Cap',
                      imageUrl: 'https://example.com/cap.png',
                      cost: 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Long press items to drag them onto your dragon'),
      findsOneWidget,
    );
    expect(find.byType(LongPressDraggable<Map<String, dynamic>>), findsOneWidget);

    final tray = tester.getRect(find.byType(StickerCollectionWidget));
    expect(tray.bottom, screenSize.height);

    final grid = tester.getRect(find.byType(GridView));
    expect(grid.bottom, lessThanOrEqualTo(screenSize.height - bottomInset));
  });
}
