import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../subjects/providers/subjects_provider.dart';
import '../models/practice_test.dart';
import '../models/question.dart';
import '../services/practice_tests_service.dart';
import '../providers/practice_tests_provider.dart';
import '../providers/questions_provider.dart';
import '../widgets/add_question_dialog.dart';
import '../../../core/config/supabase_config.dart';

class ManageTestSubjectsDialog extends ConsumerStatefulWidget {
  final PracticeTest practiceTest;

  const ManageTestSubjectsDialog({super.key, required this.practiceTest});

  @override
  ConsumerState<ManageTestSubjectsDialog> createState() =>
      _ManageTestSubjectsDialogState();
}

class _ManageTestSubjectsDialogState
    extends ConsumerState<ManageTestSubjectsDialog> {
  final _questionCountController = TextEditingController();
  String? _selectedSubjectId;
  bool _isAddingSubject = false;

  @override
  void initState() {
    super.initState();
    // Add listener to text field to update button state
    _questionCountController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _questionCountController.removeListener(_updateButtonState);
    _questionCountController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    // Force rebuild to update button state
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider('IMUCET'));
    final testSubjectsAsync = ref.watch(
      practiceTestSubjectsProvider(widget.practiceTest.id),
    );

    return Dialog(
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Iconsax.book_1, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Test Subjects',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.practiceTest.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Iconsax.close_circle),
                  color: AppColors.gray400,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add Subject Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Subject to Test',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: subjectsAsync.when(
                          data: (subjectsData) {
                            final subjects = subjectsData
                                .map((data) => data['subject'])
                                .cast<dynamic>()
                                .toList();

                            // Filter out already added subjects
                            return testSubjectsAsync.when(
                              data: (testSubjects) {
                                final addedSubjectIds = testSubjects
                                    .map((ts) => ts.subjectId)
                                    .toSet();
                                final availableSubjects = subjects
                                    .where(
                                      (s) => !addedSubjectIds.contains(s.id),
                                    )
                                    .toList();

                                if (availableSubjects.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.gray300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'All subjects already added',
                                    ),
                                  );
                                }

                                return DropdownButtonFormField<String>(
                                  initialValue: _selectedSubjectId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Subject',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: availableSubjects
                                      .map<DropdownMenuItem<String>>((subject) {
                                        return DropdownMenuItem<String>(
                                          value: subject.id,
                                          child: Text(subject.name),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSubjectId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a subject';
                                    }
                                    return null;
                                  },
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) => Text('Error: $error'),
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _questionCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Question Count',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 10',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Question count is required';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Must be a positive number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _canAddSubject() ? _addSubjectToTest : null,
                        icon: _isAddingSubject
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Iconsax.add),
                        label: Text(_isAddingSubject ? 'Adding...' : 'Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current Subjects List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Test Subjects',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: testSubjectsAsync.when(
                      data: (testSubjects) {
                        if (testSubjects.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.book_1,
                                  size: 64,
                                  color: AppColors.gray400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No subjects added yet',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColors.gray600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add subjects above to start building your test',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.gray500),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: testSubjects.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final testSubject = testSubjects[index];
                            return _TestSubjectCard(
                              testSubject: testSubject,
                              onEdit: () => _showEditSubjectDialog(testSubject),
                              onRemove: () =>
                                  _removeSubjectFromTest(testSubject.id),
                              onManageQuestions: () =>
                                  _showManageQuestionsDialog(testSubject),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading subjects',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.error),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.gray600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canAddSubject() {
    return _selectedSubjectId != null &&
        _questionCountController.text.trim().isNotEmpty &&
        int.tryParse(_questionCountController.text.trim()) != null &&
        int.parse(_questionCountController.text.trim()) > 0 &&
        !_isAddingSubject;
  }

  Future<void> _addSubjectToTest() async {
    if (!_canAddSubject()) return;

    setState(() => _isAddingSubject = true);

    try {
      final service = PracticeTestsService(SupabaseConfig.client);
      await service.addSubjectToTest(
        testId: widget.practiceTest.id,
        subjectId: _selectedSubjectId!,
        questionCount: int.parse(_questionCountController.text.trim()),
      );

      // Refresh the test subjects
      ref.invalidate(practiceTestSubjectsProvider(widget.practiceTest.id));

      // Reset form
      setState(() {
        _selectedSubjectId = null;
      });
      _questionCountController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject added to test successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding subject: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingSubject = false);
      }
    }
  }

  Future<void> _removeSubjectFromTest(String testSubjectId) async {
    try {
      final service = PracticeTestsService(SupabaseConfig.client);
      await service.removeSubjectFromTest(testSubjectId);

      // Refresh the test subjects
      ref.invalidate(practiceTestSubjectsProvider(widget.practiceTest.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject removed from test successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing subject: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showEditSubjectDialog(dynamic testSubject) {
    final questionCountController = TextEditingController(
      text: testSubject.questionCount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Subject: ${_getSubjectName(testSubject.subjectId)}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: questionCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Question Count',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Question count is required';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Must be a positive number';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (questionCountController.text.trim().isEmpty) return;

              try {
                final service = PracticeTestsService(SupabaseConfig.client);
                await service.updateTestSubject(
                  testSubjectId: testSubject.id,
                  questionCount: int.parse(questionCountController.text.trim()),
                );

                Navigator.of(context).pop();
                ref.invalidate(
                  practiceTestSubjectsProvider(widget.practiceTest.id),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating subject: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showManageQuestionsDialog(dynamic testSubject) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 1000,
          height: 700,
          child: QuestionsManagementDialog(
            subjectId: testSubject.subjectId,
            testId: widget.practiceTest.id,
            subjectName: _getSubjectName(testSubject.subjectId),
          ),
        ),
      ),
    );
  }

  String _getSubjectName(String subjectId) {
    // This is a simple lookup - in a real app you might want to use a provider
    final subjectsAsync = ref.read(subjectsProvider('IMUCET'));
    if (subjectsAsync.hasValue) {
      final subjects = subjectsAsync.value!
          .map((data) => data['subject'])
          .cast<dynamic>()
          .toList();
      final subject = subjects.firstWhere(
        (s) => s.id == subjectId,
        orElse: () => null,
      );
      return subject?.name ?? 'Unknown Subject';
    }
    return 'Loading...';
  }
}

class _TestSubjectCard extends ConsumerWidget {
  final dynamic testSubject;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onManageQuestions;

  const _TestSubjectCard({
    required this.testSubject,
    required this.onEdit,
    required this.onRemove,
    required this.onManageQuestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Iconsax.book_1, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final subjectsAsync = ref.watch(
                        subjectsProvider('IMUCET'),
                      );
                      return subjectsAsync.when(
                        data: (subjectsData) {
                          final subjects = subjectsData
                              .map((data) => data['subject'])
                              .cast<dynamic>()
                              .toList();
                          final subject = subjects.firstWhere(
                            (s) => s.id == testSubject.subjectId,
                            orElse: () => null,
                          );
                          return Text(
                            subject?.name ?? 'Unknown Subject',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          );
                        },
                        loading: () => const Text('Loading...'),
                        error: (error, stack) => const Text('Error'),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${testSubject.questionCount} questions',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onManageQuestions,
                  icon: const Icon(Iconsax.task_square),
                  color: AppColors.primary,
                  tooltip: 'Manage Questions',
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Iconsax.edit),
                  color: AppColors.warning,
                  tooltip: 'Edit Subject',
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Iconsax.trash),
                  color: AppColors.error,
                  tooltip: 'Remove subject',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionsManagementDialog extends ConsumerWidget {
  final String subjectId;
  final String testId;
  final String subjectName;

  const QuestionsManagementDialog({
    super.key,
    required this.subjectId,
    required this.testId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsFilter = QuestionsFilter(
      subjectId: subjectId,
      sectionType: 'practice_test',
    );

    final questionsAsync = ref.watch(questionsProvider(questionsFilter));
    final statsAsync = ref.watch(questionsStatsProvider(questionsFilter));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Iconsax.task_square, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Questions',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Subject: $subjectName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddQuestionDialog(context, ref),
                icon: const Icon(Iconsax.add),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Iconsax.close_circle),
                color: AppColors.gray400,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Info Card
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
                    'These questions will be used for practice tests. Questions marked as active will be available for test generation.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.gray700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Questions List
          Expanded(
            child: questionsAsync.when(
              data: (questions) {
                if (questions.isEmpty) {
                  return _EmptyQuestionsState(subjectName: subjectName);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats
                    statsAsync.when(
                      data: (stats) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatChip(
                              icon: Iconsax.task_square,
                              label: 'Total Questions',
                              value: '${stats['total']}',
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            _StatChip(
                              icon: Iconsax.flash,
                              label: 'Very Easy',
                              value: '${stats['very_easy'] ?? 0}',
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 12),
                            _StatChip(
                              icon: Iconsax.flash_1,
                              label: 'Easy',
                              value: '${stats['easy'] ?? 0}',
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 12),
                            _StatChip(
                              icon: Iconsax.flash_circle,
                              label: 'Medium',
                              value: '${stats['medium'] ?? 0}',
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 12),
                            _StatChip(
                              icon: Iconsax.flash_circle_1,
                              label: 'Hard',
                              value: '${stats['hard'] ?? 0}',
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 12),
                            _StatChip(
                              icon: Iconsax.flash_circle,
                              label: 'Very Hard',
                              value: '${stats['very_hard'] ?? 0}',
                              color: AppColors.error,
                            ),
                          ],
                        ),
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
                          return _PracticeQuestionCard(question: question);
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(questionsProvider(questionsFilter));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) =>
          AddQuestionDialog(subjectId: subjectId, sectionType: 'practice_test'),
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

class _PracticeQuestionCard extends ConsumerWidget {
  final Question question;

  const _PracticeQuestionCard({required this.question});

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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Practice Test',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
              question.questionText!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
        return AppColors.success;
      case 2:
        return AppColors.success;
      case 3:
        return AppColors.warning;
      case 4:
        return AppColors.error;
      case 5:
        return AppColors.error;
      default:
        return AppColors.gray600;
    }
  }

  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1:
        return 'Very Easy';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
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
        title: const Text('Delete Practice Question'),
        content: const Text(
          'Are you sure you want to delete this practice test question? This action cannot be undone.',
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
                      sectionType: question.sectionType,
                    ),
                  ).notifier,
                );

                await questionsNotifier.deleteQuestion(question.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Practice question deleted successfully'),
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
              Iconsax.clipboard_tick,
              size: 64,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No practice questions yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first practice test question for $subjectName',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
