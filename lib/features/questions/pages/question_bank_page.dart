import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';
import '../../subjects/providers/subjects_provider.dart';
import '../../subjects/providers/topics_provider.dart';
import '../widgets/add_question_dialog.dart';
import '../models/question.dart';
import '../providers/questions_provider.dart';

class QuestionBankPage extends ConsumerStatefulWidget {
  const QuestionBankPage({super.key});

  @override
  ConsumerState<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends ConsumerState<QuestionBankPage> {
  String? selectedSubjectId;
  String? selectedSubjectName;
  String? selectedTopicId;
  String? selectedTopicName;

  @override
  Widget build(BuildContext context) {
    // Watch subjects for IMUCET exam category
    final subjectsAsync = ref.watch(subjectsProvider('IMUCET'));

    return AppLayout(
      currentRoute: '/question-bank',
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question Bank',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage questions for each subject',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed:
                      selectedSubjectId != null && selectedTopicId != null
                      ? () => _showAddQuestionDialog(context)
                      : null,
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Subject Filter
            Row(
              children: [
                Text(
                  'Select Subject:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: subjectsAsync.when(
                      data: (subjectsData) {
                        final subjects = subjectsData
                            .map((data) => data['subject'])
                            .cast<dynamic>()
                            .toList();
                        return DropdownButton<String>(
                          value: selectedSubjectId,
                          hint: const Text('Choose a subject'),
                          items: subjects.map<DropdownMenuItem<String>>((
                            subject,
                          ) {
                            return DropdownMenuItem<String>(
                              value: subject.id,
                              child: Text(subject.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            final selectedSubject = subjects.firstWhere(
                              (s) => s.id == value,
                            );
                            setState(() {
                              selectedSubjectId = value;
                              selectedSubjectName = selectedSubject.name;
                              selectedTopicId = null;
                              selectedTopicName = null;
                            });
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Topic Filter
            if (selectedSubjectId != null)
              Row(
                children: [
                  Text(
                    'Select Topic:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final topicsAsync = ref.watch(
                            topicsProvider(selectedSubjectId!),
                          );
                          return topicsAsync.when(
                            data: (topics) {
                              return DropdownButton<String>(
                                value: selectedTopicId,
                                hint: const Text('Choose a topic'),
                                items: topics.map<DropdownMenuItem<String>>((
                                  topic,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: topic.id,
                                    child: Text(topic.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  final selectedTopic = topics.firstWhere(
                                    (t) => t.id == value,
                                  );
                                  setState(() {
                                    selectedTopicId = value;
                                    selectedTopicName = selectedTopic.name;
                                  });
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => Text('Error: $error'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Filter Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All questions are visible in the admin panel. The Active/Inactive status controls whether questions appear in the user app.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Questions List
            Expanded(
              child: selectedSubjectId != null && selectedTopicId != null
                  ? _QuestionsList(
                      subjectId: selectedSubjectId!,
                      topicId: selectedTopicId!,
                      subjectName: selectedSubjectName!,
                      topicName: selectedTopicName!,
                    )
                  : selectedSubjectId != null
                  ? _NoTopicSelected()
                  : _NoSubjectSelected(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddQuestionDialog(
        subjectId: selectedSubjectId!,
        topicId: selectedTopicId!,
        sectionType: 'question_bank',
      ),
    );
  }
}

class _QuestionsList extends ConsumerWidget {
  final String subjectId;
  final String topicId;
  final String subjectName;
  final String topicName;

  const _QuestionsList({
    required this.subjectId,
    required this.topicId,
    required this.subjectName,
    required this.topicName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsFilter = QuestionsFilter(
      subjectId: subjectId,
      topicId: topicId,
      sectionType: 'question_bank',
    );

    final questionsAsync = ref.watch(questionsProvider(questionsFilter));
    final statsAsync = ref.watch(questionsStatsProvider(questionsFilter));

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return _EmptyQuestionsState(subjectName: subjectName);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats
            statsAsync.when(
              data: (stats) => Row(
                children: [
                  _StatChip(
                    icon: Iconsax.task_square,
                    label: 'Total Questions',
                    value: '${stats['total']}',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Iconsax.flash,
                    label: 'Easy',
                    value: '${stats['easy']}',
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Iconsax.flash_1,
                    label: 'Medium',
                    value: '${stats['medium']}',
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Iconsax.flash_circle,
                    label: 'Hard',
                    value: '${stats['hard']}',
                    color: AppColors.error,
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 40),
              error: (error, stack) => const SizedBox(height: 40),
            ),
            const SizedBox(height: 24),

            // Questions
            Expanded(
              child: ListView.separated(
                itemCount: questions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return _QuestionCard(question: question);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading questions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(questionsProvider(questionsFilter));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final Question question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficultyColor = _getDifficultyColor(question.difficultyLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyLabel(question.difficultyLevel),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: difficultyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(context, ref, value, question),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Iconsax.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Iconsax.trash, color: AppColors.error),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Iconsax.more, color: AppColors.gray400),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              question.questionText,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (question.topicId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final topicAsync = ref.watch(
                      topicProvider(question.topicId!),
                    );
                    return topicAsync.when(
                      data: (topic) => Text(
                        'Topic: ${topic?.name ?? 'Unknown Topic'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      loading: () => Text(
                        'Topic: Loading...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      error: (error, stack) => Text(
                        'Topic: Error',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (question.questionImageUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.image, color: AppColors.gray600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Image attached',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Answer Choices
            ...question.answerChoices.map((choice) {
              final isCorrect = choice.label == question.correctAnswer;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? AppColors.success : AppColors.gray200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.gray300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          choice.label,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isCorrect
                                    ? Colors.white
                                    : AppColors.gray700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        choice.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (isCorrect)
                      Icon(
                        Iconsax.tick_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
      case 2:
        return AppColors.success;
      case 3:
        return AppColors.warning;
      case 4:
      case 5:
        return AppColors.error;
      default:
        return AppColors.gray600;
    }
  }

  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1:
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
      case 5:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Question question,
  ) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => AddQuestionDialog(
            subjectId: question.subjectId,
            topicId: question.topicId,
            sectionType: question.sectionType,
            question: question,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, question);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Question question,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text(
          'Are you sure you want to delete this question? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                final questionsNotifier = ref.read(
                  questionsProvider(
                    QuestionsFilter(
                      subjectId: question.subjectId,
                      topicId: question.topicId,
                      sectionType: question.sectionType,
                    ),
                  ).notifier,
                );

                await questionsNotifier.deleteQuestion(question.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting question: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _NoSubjectSelected extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.book_1, size: 64, color: AppColors.gray400),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a Subject',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a subject from the dropdown to view and manage questions',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}

class _NoTopicSelected extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.folder, size: 64, color: AppColors.gray400),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a Topic',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a topic from the dropdown to view and manage questions',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}

class _EmptyQuestionsState extends StatelessWidget {
  final String subjectName;

  const _EmptyQuestionsState({required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.task_square,
              size: 64,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No questions yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first question for $subjectName',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }
}
