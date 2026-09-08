import 'package:flutter/material.dart';

/// Scrollable completion-screen layout.
///
/// On tall viewports, [action] sits at the bottom. On short viewports
/// (phones with a large illustration), the body scrolls so the action
/// remains reachable. Safe-area insets are applied by the caller via
/// [SafeArea] wrapping this widget, or by using [wrapWithSafeArea].
class ScrollableCompletionBody extends StatelessWidget {
  const ScrollableCompletionBody({
    super.key,
    required this.content,
    required this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
    this.wrapWithSafeArea = true,
  });

  final Widget content;
  final Widget action;
  final EdgeInsets padding;
  final bool wrapWithSafeArea;

  @override
  Widget build(BuildContext context) {
    final Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final double minHeight = (constraints.maxHeight - padding.vertical)
            .clamp(0.0, double.infinity);

        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                content,
                action,
              ],
            ),
          ),
        );
      },
    );

    if (!wrapWithSafeArea) {
      return body;
    }

    return SafeArea(child: body);
  }
}
