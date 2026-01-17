import 'package:flutter/material.dart';
import '../../services/tts_service.dart';

/// A scrollbar/progress bar widget for TTS playback
/// Shows current position and allows dragging to seek
class TtsProgressBar extends StatefulWidget {
  final TtsService ttsService;
  final String cleanText; // Clean text for calculating total length

  const TtsProgressBar({
    super.key,
    required this.ttsService,
    required this.cleanText,
  });

  @override
  State<TtsProgressBar> createState() => _TtsProgressBarState();
}

class _TtsProgressBarState extends State<TtsProgressBar> {
  bool _isDragging = false;
  double? _dragPosition;

  @override
  void initState() {
    super.initState();
    // Listen to position changes
    widget.ttsService.onPositionChanged = (start, end) {
      if (!_isDragging && mounted) {
        setState(() {});
      }
    };
  }

  @override
  void dispose() {
    // Don't clear onPositionChanged as it might be used elsewhere
    super.dispose();
  }

  double _getProgress() {
    final currentStart = widget.ttsService.currentWordStart;
    final cleanText = widget.cleanText;
    
    if (cleanText.isEmpty || currentStart == null) {
      return 0.0;
    }
    
    // Calculate progress as percentage
    final progress = currentStart / cleanText.length;
    return progress.clamp(0.0, 1.0);
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    // Account for padding when calculating drag position
    final padding = 20.0;
    final trackWidth = constraints.maxWidth - (padding * 2);
    final localPosition = details.localPosition.dx - padding;
    final progress = (localPosition / trackWidth).clamp(0.0, 1.0);
    
    setState(() {
      _dragPosition = progress;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragPosition != null) {
      // Calculate position in text
      final position = (_dragPosition! * widget.cleanText.length).round();
      
      // Seek to position
      widget.ttsService.seekToPosition(position);
    }
    
    setState(() {
      _isDragging = false;
      _dragPosition = null;
    });
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    // Account for padding when calculating tap position
    final padding = 20.0;
    final trackWidth = constraints.maxWidth - (padding * 2);
    final localPosition = details.localPosition.dx - padding;
    final progress = (localPosition / trackWidth).clamp(0.0, 1.0);
    final position = (progress * widget.cleanText.length).round();
    
    // Seek to tapped position
    widget.ttsService.seekToPosition(position);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Only show if TTS is active
    if (widget.ttsService.isStopped && !_isDragging) {
      return const SizedBox.shrink();
    }

    final progress = _isDragging ? _dragPosition! : _getProgress();
    final currentStart = widget.ttsService.currentWordStart;
    final totalLength = widget.cleanText.length;
    
    // Use teal/cyan color for better visibility
    final progressColor = const Color(0xFF00BCD4); // Teal/Cyan
    final trackColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (details) => _onTapDown(details, constraints),
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: (details) => _onDragUpdate(details, constraints),
              onHorizontalDragEnd: _onDragEnd,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background track
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: trackColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        // Progress indicator
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: progressColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        // Draggable thumb
                        Positioned(
                          left: (progress * (constraints.maxWidth - 40)).clamp(0.0, (constraints.maxWidth - 40) - 20),
                          top: -7,
                          child: GestureDetector(
                            onHorizontalDragStart: _onDragStart,
                            onHorizontalDragUpdate: (details) => _onDragUpdate(details, constraints),
                            onHorizontalDragEnd: _onDragEnd,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: progressColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Position info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatPosition(currentStart, totalLength),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: progressColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatPosition(int? current, int total) {
    if (current == null) return '0 / $total';
    return '$current / $total';
  }
}
