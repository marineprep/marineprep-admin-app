import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';
import '../widgets/add_question_dialog.dart';
import '../models/question.dart';

class QuestionBankPage extends ConsumerStatefulWidget {
  const QuestionBankPage({super.key});

  @override
  ConsumerState<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends ConsumerState<QuestionBankPage> {
  String? selectedSubjectId;
  
  // Mock subjects data
  final List<Map<String, String>> subjects = [
    {'id': '1', 'name': 'Mathematics'},
    {'id': '2', 'name': 'Physics'},
    {'id': '3', 'name': 'Chemistry'},
    {'id': '4', 'name': 'English'},
  ];

  @override
  Widget build(BuildContext context) {
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
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage questions for each subject',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: selectedSubjectId != null 
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
                    child: DropdownButton<String>(
                      value: selectedSubjectId,
                      hint: const Text('Choose a subject'),
                      items: subjects.map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject['id'],
                          child: Text(subject['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSubjectId = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Questions List
            Expanded(
              child: selectedSubjectId != null
                  ? _QuestionsList(subjectId: selectedSubjectId!)
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
        sectionType: 'question_bank',
      ),
    );
  }
}

class _QuestionsList extends StatelessWidget {
  final String subjectId;

  const _QuestionsList({required this.subjectId});

  // Mock questions data
  List<Question> get questions => [
    Question(
      id: '1',
      questionText: 'What is the derivative of x²?',
      subjectId: subjectId,
      sectionType: 'question_bank',
      answerChoices: const [
        AnswerChoice(label: 'A', text: 'x'),
        AnswerChoice(label: 'B', text: '2x'),
        AnswerChoice(label: 'C', text: 'x²'),
        AnswerChoice(label: 'D', text: '2x²'),
      ],
      correctAnswer: 'B',
      explanationText: 'The derivative of x² is 2x using the power rule.',
      difficultyLevel: 2,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Question(
      id: '2',
      questionText: 'Which of the following is the quadratic formula?',
      questionImageUrl: 'https://example.com/quadratic_formula.png',
      subjectId: subjectId,
      sectionType: 'question_bank',
      answerChoices: const [
        AnswerChoice(label: 'A', text: 'x = -b ± √(b² - 4ac) / 2a'),
        AnswerChoice(label: 'B', text: 'x = b ± √(b² + 4ac) / 2a'),
        AnswerChoice(label: 'C', text: 'x = -b ± √(b² + 4ac) / 2a'),
        AnswerChoice(label: 'D', text: 'x = b ± √(b² - 4ac) / 2a'),
      ],
      correctAnswer: 'A',
      explanationText: 'The quadratic formula is used to solve equations of the form ax² + bx + c = 0.',
      difficultyLevel: 3,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return _EmptyQuestionsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats
        Row(
          children: [
            _StatChip(
              icon: Iconsax.task_square,
              label: 'Total Questions',
              value: '${questions.length}',
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            _StatChip(
              icon: Iconsax.flash,
              label: 'Easy',
              value: '${questions.where((q) => q.difficultyLevel <= 2).length}',
              color: AppColors.success,
            ),
            const SizedBox(width: 16),
            _StatChip(
              icon: Iconsax.flash_1,
              label: 'Medium',
              value: '${questions.where((q) => q.difficultyLevel == 3).length}',
              color: AppColors.warning,
            ),
            const SizedBox(width: 16),
            _StatChip(
              icon: Iconsax.flash_circle,
              label: 'Hard',
              value: '${questions.where((q) => q.difficultyLevel >= 4).length}',
              color: AppColors.error,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Questions
        Expanded(
          child: ListView.separated(
            itemCount: questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final question = questions[index];
              return _QuestionCard(question: question);
            },
          ),
        ),
      ],
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  onSelected: (value) => _handleMenuAction(context, value, question),
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
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(
                    Iconsax.more,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
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
                    Icon(
                      Iconsax.image,
                      color: AppColors.gray600,
                      size: 20,
                    ),
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
                    color: isCorrect 
                        ? AppColors.success 
                        : AppColors.gray200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.success : AppColors.gray300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          choice.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isCorrect ? Colors.white : AppColors.gray700,
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

  void _handleMenuAction(BuildContext context, String action, Question question) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => AddQuestionDialog(
            subjectId: question.subjectId,
            sectionType: question.sectionType!,
            question: question,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, question);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Question question) {
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
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
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
            child: Icon(
              Iconsax.book_1,
              size: 64,
              color: AppColors.gray400,
            ),
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQuestionsState extends StatelessWidget {
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
            'Add your first question for this subject',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
