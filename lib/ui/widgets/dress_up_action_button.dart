import 'package:flutter/material.dart';

/// Shared Phase / Habitat / Help control on the dress-up screen.
class DressUpActionButton extends StatelessWidget {
  const DressUpActionButton({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final foreground =
        isLight ? colorScheme.primary : colorScheme.onPrimaryContainer;
    final subtitleColor =
        isLight
            ? colorScheme.primary.withValues(alpha: 0.65)
            : colorScheme.onPrimaryContainer.withValues(alpha: 0.75);
    final background =
        isLight
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.primaryContainer;
    final borderColor =
        isLight
            ? colorScheme.primary.withValues(alpha: 0.6)
            : colorScheme.primary.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: IconTheme(
          data: IconThemeData(color: foreground, size: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 6),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle ?? '',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
