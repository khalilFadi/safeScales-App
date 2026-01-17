import 'package:flutter/material.dart';
import 'package:safe_scales/ui/widgets/dragon_image_widget.dart';

class ReadingResultScreen extends StatefulWidget {
  const ReadingResultScreen({super.key, required this.modeuleId});

  final String modeuleId;

  @override
  State<ReadingResultScreen> createState() => _ReadingResultScreenState();
}

class _ReadingResultScreenState extends State<ReadingResultScreen> {
  bool _isNavigating = false;

  void _handleReturnToLesson() {
    // Prevent multiple taps
    if (_isNavigating || !mounted) return;
    
    setState(() {
      _isNavigating = true;
    });
    
    // Pop immediately after setting state
    // The mounted check ensures we don't pop if widget is disposed
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Complete'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Great job completing the reading!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              Text(
                'Your new dragon is now a teenage dragon!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),

              SizedBox(height: 30),

              DragonImageWidget(
                moduleId: widget.modeuleId,
                phase: 'stage2',
                size: 300,
              ),

              SizedBox(height: 30),

              Text(
                'Complete the Post-Quiz with a passing score for your dragon to become a full adult.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),

              SizedBox(height: 30),

              Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isNavigating ? null : _handleReturnToLesson,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                  ),
                  child: _isNavigating
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onSecondary,
                            ),
                          ),
                        )
                      : Text(
                          'Return to lesson'.toUpperCase(),
                          style: TextStyle(
                            fontSize: theme.textTheme.bodyMedium?.fontSize,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
