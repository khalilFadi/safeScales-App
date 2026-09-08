import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safe_scales/models/lesson_progress.dart';
import 'package:safe_scales/models/question.dart';
import 'package:safe_scales/ui/screens/pre_quiz/pre_quiz_screen.dart';
import 'package:safe_scales/ui/screens/post_quiz/post_quiz_screen.dart';
import 'package:safe_scales/ui/screens/reading/reading_activity_screen.dart';

import '../../../models/lesson.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/dragon_provider.dart';
import '../../widgets/dragon_image_widget.dart';
import '../../widgets/lesson_activity_card.dart';
import '../review_set/review_screen.dart';

class LessonScreen extends StatefulWidget {
  final String moduleId;
  final String? topic; // Keep for backward compatibility

  const LessonScreen({super.key, required this.moduleId, this.topic});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Lesson? _lesson;
  LessonProgress? _lessonProgress;
  bool _isLoading = true;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    if (!courseProvider.isInitialized) {
      await courseProvider.initialize();
    }

    setState(() {
      _lesson = courseProvider.lessons[widget.moduleId];
      _lessonProgress = courseProvider.lessonProgress[widget.moduleId];
    });

    if (_lesson == null || _lessonProgress == null) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lesson not found or not properly initialized',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            );
            Navigator.pop(context);
          }
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  LessonActivityStatus _activityStatus({
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    if (isCompleted) return LessonActivityStatus.completed;
    if (!isUnlocked) return LessonActivityStatus.locked;
    return LessonActivityStatus.active;
  }

  void _showLockedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<DragonProvider, CourseProvider>(
      builder: (context, dragonProvider, courseProvider, child) {
        final lesson = courseProvider.lessons[widget.moduleId] ?? _lesson;
        final lessonProgress =
            courseProvider.lessonProgress[widget.moduleId] ?? _lessonProgress;

        if (_isLoading || lesson == null || lessonProgress == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.topic ?? 'Loading...'),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final nextLesson = courseProvider.getNextLesson(widget.moduleId);
        final activitiesComplete = lessonProgress.areAllActivitiesComplete;
        final completedCount = lessonProgress.completedActivityCount;
        final totalCount = LessonProgress.totalActivities;
        final bestQuiz = lessonProgress.getHighestPostQuizScore();

        final dragon = dragonProvider.getDragonByModuleId(widget.moduleId);
        final phaseName =
            dragon == null
                ? ''
                : dragonProvider.getPhaseDisplayName(
                  dragonProvider.getDragonHighestPhase(dragon.id),
                );

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.topic ?? lesson.title),
            centerTitle: true,
          ),
          body:
              courseProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGrowthCard(
                          theme: theme,
                          phaseName: phaseName,
                          completedCount: completedCount,
                          totalCount: totalCount,
                          bestQuizPercent: bestQuiz,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Lesson Activities',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        LessonActivityCard(
                          key: const Key('activity-card-pre-quiz'),
                          title: 'Pre-Quiz',
                          description: 'Test your knowledge before starting',
                          icon: FontAwesomeIcons.clipboardQuestion,
                          status: _activityStatus(
                            isCompleted: lessonProgress.isPreQuizComplete,
                            isUnlocked: true,
                          ),
                          onTap: () {
                            if (lessonProgress.isPreQuizComplete) {
                              _showLockedMessage(
                                'Pre-Quiz has already been completed',
                              );
                              return;
                            }
                            _startQuiz(lesson.preQuiz);
                          },
                        ),
                        const SizedBox(height: 12),
                        LessonActivityCard(
                          key: const Key('activity-card-reading'),
                          title: 'Reading',
                          description:
                              'Learn about ${widget.topic ?? lesson.title}',
                          icon: FontAwesomeIcons.fileLines,
                          status: _activityStatus(
                            isCompleted: lessonProgress.isReadingComplete,
                            isUnlocked: lessonProgress.isPreQuizComplete,
                          ),
                          onTap: () {
                            if (!lessonProgress.isPreQuizComplete) {
                              _showLockedMessage(
                                'Please complete the Pre-Quiz activity first',
                              );
                              return;
                            }
                            _openReading();
                          },
                        ),
                        const SizedBox(height: 12),
                        LessonActivityCard(
                          key: const Key('activity-card-quiz'),
                          title: 'Quiz',
                          description: 'Test what you\'ve learned',
                          icon: FontAwesomeIcons.penRuler,
                          status: _activityStatus(
                            isCompleted: lessonProgress.isPostQuizComplete(),
                            isUnlocked: lessonProgress.isReadingComplete,
                          ),
                          onTap: () {
                            if (!lessonProgress.isReadingComplete) {
                              _showLockedMessage(
                                'Please complete the Reading activity first',
                              );
                              return;
                            }
                            _startQuiz(lesson.postQuiz);
                          },
                        ),
                        const SizedBox(height: 28),
                        _buildFooterActions(
                          theme: theme,
                          activitiesComplete: activitiesComplete,
                          nextLesson: nextLesson,
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildGrowthCard({
    required ThemeData theme,
    required String phaseName,
    required int completedCount,
    required int totalCount,
    required double bestQuizPercent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          DragonImageWidget(moduleId: widget.moduleId, size: 88),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (phaseName.isNotEmpty)
                  Text(
                    phaseName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Progress', style: theme.textTheme.labelMedium),
                    const SizedBox(width: 8),
                    ...List.generate(totalCount, (index) {
                      final filled = index < completedCount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                filled
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '$completedCount/$totalCount',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bestQuizPercent > 0
                        ? 'Best Quiz: ${bestQuizPercent.toInt()}%'
                        : 'Best Quiz: --',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions({
    required ThemeData theme,
    required bool activitiesComplete,
    required Lesson? nextLesson,
  }) {
    if (!activitiesComplete) {
      return Column(
        children: [
          Text(
            'Complete all activities to unlock the next lesson and review.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _lockedFooterButton(
            theme: theme,
            icon: FontAwesomeIcons.graduationCap,
            label: 'Next Lesson',
          ),
          const SizedBox(height: 12),
          _lockedFooterButton(
            theme: theme,
            icon: FontAwesomeIcons.clipboardList,
            label: 'Review this Lesson',
          ),
        ],
      );
    }

    return Column(
      children: [
        if (nextLesson != null) ...[
          _primaryNextLessonButton(theme: theme, nextLesson: nextLesson),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: theme.textTheme.labelSmall),
              ),
              Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _reviewLessonButton(theme: theme),
      ],
    );
  }

  Widget _lockedFooterButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
  }) {
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 16,
                color: muted,
              ),
            ),
          ),
          Icon(FontAwesomeIcons.lock, size: 16, color: muted),
        ],
      ),
    );
  }

  Widget _primaryNextLessonButton({
    required ThemeData theme,
    required Lesson nextLesson,
  }) {
    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LessonScreen(moduleId: nextLesson.lessonId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.graduationCap,
                size: 18,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Lesson',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      nextLesson.title,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewLessonButton({required ThemeData theme}) {
    return Material(
      color: theme.colorScheme.surfaceBright,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary, width: 1),
      ),
      child: InkWell(
        onTap: () async {
          await _startReviewSet(widget.moduleId);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                FontAwesomeIcons.clipboardList,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Review this Lesson',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReading() async {
    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingActivityScreen(moduleId: widget.moduleId),
      ),
    ).then((completed) async {
      if (completed == true) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Updating progress...',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            },
          );
        }

        try {
          final courseProvider = Provider.of<CourseProvider>(
            context,
            listen: false,
          );
          await courseProvider.loadSingleLessonProgress(widget.moduleId);

          await Provider.of<DragonProvider>(
            context,
            listen: false,
          ).updateAllDragonProgress();

          if (mounted) {
            setState(() {
              _lessonProgress = courseProvider.lessonProgress[widget.moduleId];
              _isLoading = false;
            });
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating progress: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _startReviewSet(String lessonId) async {
    try {
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );

      final questionSet = await courseProvider.getReviewQuestionSetForLesson(
        lessonId,
      );

      if (questionSet == null || questionSet.questions.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(
              'The Teacher has not created a review set for this lesson',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final completed = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ReviewScreen(questionSet: questionSet, needToShowShop: true),
        ),
      );

      if (completed == true) {
        bool dialogShown = false;

        if (mounted) {
          dialogShown = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Updating progress...',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            },
          );
        }

        try {
          if (mounted) {
            if (dialogShown) {
              Navigator.of(context).pop();
            }
            setState(() {
              _isLoading = false;
            });
          }
        } catch (e) {
          if (mounted) {
            if (dialogShown) {
              Navigator.of(context).pop();
            }
            setState(() {
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating progress: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error starting review set: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load review set')),
        );
      }
    }
  }

  void _startQuiz(QuestionSet quiz) {
    if (quiz.questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This quiz is not available yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        ),
      );
      return;
    }

    if (quiz.activityType == ActivityType.preQuiz &&
        _lessonProgress!.isPreQuizComplete) {
      _showLockedMessage('Pre-Quiz has already been completed');
      return;
    }

    if (quiz.activityType == ActivityType.postQuiz &&
        !_lessonProgress!.isReadingComplete) {
      _showLockedMessage('Please complete the Reading activity first');
      return;
    }

    Widget quizScreen;
    if (quiz.activityType == ActivityType.preQuiz) {
      quizScreen = PreQuizScreen(moduleId: widget.moduleId, questionSet: quiz);
    } else {
      quizScreen = PostQuizScreen(moduleId: widget.moduleId, questionSet: quiz);
    }

    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => quizScreen),
    ).then((completed) async {
      await _onQuizRouteClosed(completed == true);
    });
  }

  Future<void> _onQuizRouteClosed(bool completed) async {
    if (!mounted) return;

    if (!completed) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final courseProvider = Provider.of<CourseProvider>(
      context,
      listen: false,
    );

    try {
      await courseProvider.loadSingleLessonProgress(widget.moduleId);
      if (!mounted) return;
      await Provider.of<DragonProvider>(
        context,
        listen: false,
      ).updateDragonPhases(widget.moduleId);

      if (mounted) {
        setState(() {
          _lessonProgress =
              courseProvider.lessonProgress[widget.moduleId] ?? _lessonProgress;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating progress: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
