import 'package:flutter/material.dart';
import 'package:safe_scales/models/question.dart';

/// Shared pre-quiz / post-quiz intro: title card, Details, and START.
///
/// The body is scrollable so START stays reachable on short viewports
/// (and when text scale is large). Text below the Details header uses
/// [TextTheme.bodySmall]; the Details header itself keeps headline size.
class QuizStartBody extends StatelessWidget {
  const QuizStartBody({
    super.key,
    required this.questionSet,
    required this.onStart,
    this.showTableOfContentsHint = false,
  });

  final QuestionSet questionSet;
  final VoidCallback onStart;
  final bool showTableOfContentsHint;

  static int requiredCorrectAnswers({
    required int passingScorePercent,
    required int totalQuestions,
  }) {
    if (totalQuestions <= 0) return 0;
    return ((passingScorePercent / 100) * totalQuestions).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? detailsBodyStyle = theme.textTheme.bodySmall;

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuizTitleCard(questionSet: questionSet),
        const SizedBox(height: 24),
        Text(
          'Details',
          key: const Key('quiz-start-details-header'),
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        DefaultTextStyle.merge(
          key: const Key('quiz-start-details-body'),
          style: detailsBodyStyle ?? const TextStyle(fontSize: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (questionSet.passingScore > 0) ...[
                _PassingCard(questionSet: questionSet),
                const SizedBox(height: 12),
              ],
              _InstructionsCard(
                showTableOfContentsHint: showTableOfContentsHint,
              ),
            ],
          ),
        ),
      ],
    );

    final Widget startButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onStart,
        child: Text(
          'Start'.toUpperCase(),
          style: TextStyle(
            fontSize: theme.textTheme.bodyMedium?.fontSize,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );

    const EdgeInsets padding = EdgeInsets.fromLTRB(24, 16, 24, 8);

    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double minHeight = (constraints.maxHeight - padding.vertical)
              .clamp(0.0, double.infinity);

          return SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  content,
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: startButton,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuizTitleCard extends StatelessWidget {
  const _QuizTitleCard({required this.questionSet});

  final QuestionSet questionSet;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionSet.title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${questionSet.questions.length} Multiple Choice Questions',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _PassingCard extends StatelessWidget {
  const _PassingCard({required this.questionSet});

  final QuestionSet questionSet;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int total = questionSet.questions.length;
    final int needed = QuizStartBody.requiredCorrectAnswers(
      passingScorePercent: questionSet.passingScore,
      totalQuestions: total,
    );
    final TextStyle bodyStyle =
        DefaultTextStyle.of(context).style;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To Pass this Quiz',
            style: bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'You need to get '),
                TextSpan(
                  text: '$needed out of $total',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' questions right to pass.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard({required this.showTableOfContentsHint});

  final bool showTableOfContentsHint;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          if (showTableOfContentsHint)
            const _InstructionRow(
              icon: Icons.list,
              text:
                  'You can use the table of contents to return to previous questions',
            ),
          if (showTableOfContentsHint)
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant,
            ),
          const _InstructionRow(
            icon: Icons.volume_up,
            text:
                'You can use the audio feature to listen to the question instead of reading.',
          ),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color iconColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
