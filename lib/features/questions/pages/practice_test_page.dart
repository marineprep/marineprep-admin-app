import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';
import '../../subjects/providers/subjects_provider.dart';
import '../models/practice_test.dart';
import '../providers/practice_tests_provider.dart';
import '../widgets/create_practice_test_dialog.dart';
import '../widgets/manage_test_subjects_dialog.dart';

class PracticeTestPage extends ConsumerWidget {
  const PracticeTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch practice tests for IMUCET exam category
    final testsAsync = ref.watch(practiceTestsProvider('IMUCET'));

    return AppLayout(
      currentRoute: '/practice-test',
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
                      'Practice Tests',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create and manage practice tests',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTestDialog(context, ref),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Create Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                      'Create practice tests with multiple subjects. Each test can include questions from different subjects to provide comprehensive coverage.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tests List
            Expanded(
              child: testsAsync.when(
                data: (tests) {
                  if (tests.isEmpty) {
                    return _EmptyTestsState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Practice Tests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: tests.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final test = tests[index];
                            return _PracticeTestCard(test: test);
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
                        'Error loading practice tests',
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
                          ref
                              .read(
                                practiceTestsNotifierProvider(
                                  'IMUCET',
                                ).notifier,
                              )
                              .refresh();
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
      ),
    );
  }

  void _showCreateTestDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) =>
          const CreatePracticeTestDialog(examCategoryId: 'IMUCET'),
    );
  }
}

class _PracticeTestCard extends ConsumerWidget {
  final PracticeTest test;

  const _PracticeTestCard({required this.test});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testSubjectsAsync = ref.watch(practiceTestSubjectsProvider(test.id));

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.clipboard_tick,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (test.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          test.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.gray600),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, ref, value),
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
                      value: 'subjects',
                      child: Row(
                        children: [
                          Icon(Iconsax.book_1),
                          SizedBox(width: 8),
                          Text('Manage Subjects'),
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
            const SizedBox(height: 20),

            // Test Details
            Row(
              children: [
                _DetailChip(
                  icon: Iconsax.task_square,
                  label: 'Total Questions',
                  value: '${test.totalQuestions}',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                if (test.timeLimitMinutes != null) ...[
                  _DetailChip(
                    icon: Iconsax.clock,
                    label: 'Time Limit',
                    value: '${test.timeLimitMinutes} min',
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 16),
                ],
                if (test.passingScore != null) ...[
                  _DetailChip(
                    icon: Iconsax.tick_circle,
                    label: 'Passing Score',
                    value: '${test.passingScore}%',
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 16),
                ],
                _DetailChip(
                  icon: test.isActive
                      ? Iconsax.tick_circle
                      : Iconsax.close_circle,
                  label: 'Status',
                  value: test.isActive ? 'Active' : 'Inactive',
                  color: test.isActive ? AppColors.success : AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subjects Section
            Row(
              children: [
                Text(
                  'Test Subjects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showManageSubjectsDialog(context, ref),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Subject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Subjects List
            testSubjectsAsync.when(
              data: (testSubjects) {
                if (testSubjects.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.book_1,
                            size: 48,
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
                            'Add subjects to start building your test',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.gray500),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: testSubjects.map((testSubject) {
                    return _TestSubjectItem(
                      testSubject: testSubject,
                      onRemove: () =>
                          _removeSubject(context, ref, testSubject.id),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Iconsax.warning_2, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading subjects',
                        style: Theme.of(context).textTheme.titleMedium
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        // TODO: Implement edit test functionality
        break;
      case 'subjects':
        _showManageSubjectsDialog(context, ref);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
    }
  }

  void _showManageSubjectsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ManageTestSubjectsDialog(practiceTest: test),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Practice Test'),
        content: Text(
          'Are you sure you want to delete "${test.name}"? This action cannot be undone.',
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
                final notifier = ref.read(
                  practiceTestsNotifierProvider('IMUCET').notifier,
                );
                await notifier.deleteTest(test.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Practice test deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting test: $e'),
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

  Future<void> _removeSubject(
    BuildContext context,
    WidgetRef ref,
    String testSubjectId,
  ) async {
    try {
      final service = ref.read(practiceTestsServiceProvider);
      await service.removeSubjectFromTest(testSubjectId);

      // Refresh the test subjects
      ref.invalidate(practiceTestSubjectsProvider(test.id));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subject removed from test successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing subject: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestSubjectItem extends ConsumerWidget {
  final dynamic testSubject;
  final VoidCallback onRemove;

  const _TestSubjectItem({required this.testSubject, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Icon(Iconsax.book_1, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final subjectsAsync = ref.watch(subjectsProvider('IMUCET'));
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        );
                      },
                      loading: () => const Text('Loading...'),
                      error: (error, stack) => const Text('Error'),
                    );
                  },
                ),
                Text(
                  '${testSubject.questionCount} questions',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showManageQuestionsDialog(context, ref),
                icon: const Icon(Iconsax.task_square),
                color: AppColors.primary,
                tooltip: 'Manage Questions',
              ),
              IconButton(
                onPressed: () => _showEditSubjectDialog(context, ref),
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
    );
  }

  void _showManageQuestionsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 1000,
          height: 700,
          child: QuestionsManagementDialog(
            subjectId: testSubject.subjectId,
            testId: testSubject.practiceTestId,
            subjectName: _getSubjectName(testSubject.subjectId, ref),
          ),
        ),
      ),
    );
  }

  String _getSubjectName(String subjectId, WidgetRef ref) {
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

  void _showEditSubjectDialog(BuildContext context, WidgetRef ref) {
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
            Consumer(
              builder: (context, ref, child) {
                final subjectsAsync = ref.watch(subjectsProvider('IMUCET'));
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
                      'Subject: ${subject?.name ?? 'Unknown Subject'}',
                    );
                  },
                  loading: () => const Text('Subject: Loading...'),
                  error: (error, stack) => const Text('Subject: Error'),
                );
              },
            ),
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
                final service = ref.read(practiceTestsServiceProvider);
                await service.updateTestSubject(
                  testSubjectId: testSubject.id,
                  questionCount: int.parse(questionCountController.text.trim()),
                );

                Navigator.of(context).pop();
                // Refresh the test subjects
                ref.invalidate(
                  practiceTestSubjectsProvider(testSubject.practiceTestId),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
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
}

class _EmptyTestsState extends StatelessWidget {
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
            'No practice tests yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first practice test to get started',
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
