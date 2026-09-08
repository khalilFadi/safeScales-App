import 'package:flutter/material.dart';

enum LessonActivityStatus { locked, active, completed }

/// Reading/Quiz (and other lesson activities) card with locked, active, and
/// completed visual states matching the Lesson page mockups.
class LessonActivityCard extends StatelessWidget {
  const LessonActivityCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final LessonActivityStatus status;
  final VoidCallback onTap;

  static const Color _paleGreen = Color(0xffDCFCE7);
  static const Color _green = Color(0xff0DB563);

  bool get _isCompleted => status == LessonActivityStatus.completed;
  bool get _isLocked => status == LessonActivityStatus.locked;
  bool get _isActive => status == LessonActivityStatus.active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;
    final Color titleColor = _isLocked ? muted : theme.colorScheme.onSurface;
    final Color subtitleColor =
        _isLocked ? muted.withValues(alpha: 0.8) : muted;

    final Color background =
        _isCompleted
            ? _paleGreen
            : _isLocked
            ? theme.colorScheme.surfaceContainer
            : theme.colorScheme.surfaceBright;

    final Border? border =
        _isActive
            ? Border.all(color: theme.colorScheme.primary, width: 1)
            : _isCompleted
            ? Border.all(color: _green.withValues(alpha: 0.35), width: 1)
            : null;

    final Color iconTileColor =
        _isCompleted
            ? _green
            : _isLocked
            ? muted.withValues(alpha: 0.25)
            : theme.colorScheme.primary.withValues(alpha: 0.12);

    final Color iconColor =
        _isCompleted
            ? Colors.white
            : _isLocked
            ? muted
            : theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconTileColor,
                    borderRadius:
                        _isCompleted ? null : BorderRadius.circular(12),
                    shape:
                        _isCompleted ? BoxShape.circle : BoxShape.rectangle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isCompleted ? Icons.check : icon,
                    size: _isCompleted ? 22 : 20,
                    color: iconColor,
                    key: Key(
                      _isCompleted
                          ? 'activity-check-$title'
                          : 'activity-icon-$title',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 16,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isLocked ? Icons.lock : Icons.chevron_right,
                  size: _isLocked ? 20 : 22,
                  color: muted,
                  key: Key(
                    _isLocked
                        ? 'activity-lock-$title'
                        : 'activity-chevron-$title',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
