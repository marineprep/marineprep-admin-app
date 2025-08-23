import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';
import '../widgets/add_subject_dialog.dart';
import '../models/subject.dart';
import '../providers/subjects_provider.dart';

class SubjectsPage extends ConsumerStatefulWidget {
  const SubjectsPage({super.key});

  @override
  ConsumerState<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends ConsumerState<SubjectsPage> {
  bool showInactiveItems = true; // Admin always shows all by default

  @override
  Widget build(BuildContext context) {
    // For now, using IMUCET as default exam category
    // In the future, you can make this dynamic based on user selection
    const examCategoryId = 'IMUCET';

    return AppLayout(
      currentRoute: '/subjects',
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
                      'Subjects',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage subjects and their topics',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          ref.refresh(subjectsProvider(examCategoryId)),
                      icon: const Icon(Iconsax.refresh),
                      tooltip: 'Refresh subjects',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.gray100,
                        foregroundColor: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddSubjectDialog(context, ref, examCategoryId),
                      icon: const Icon(Iconsax.add),
                      label: const Text('Add Subject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Filter Toggle
            Row(
              children: [
                Text(
                  'Show Inactive Items:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: showInactiveItems,
                  onChanged: (value) {
                    setState(() {
                      showInactiveItems = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  showInactiveItems
                      ? 'All items visible (Admin view)'
                      : 'Only active items visible',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active/Inactive status controls user app visibility',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subjects Grid
            Expanded(
              child: _SubjectsGrid(
                examCategoryId: examCategoryId,
                showInactiveItems: showInactiveItems,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubjectDialog(
    BuildContext context,
    WidgetRef ref,
    String examCategoryId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(examCategoryId: examCategoryId),
    );
  }
}

class _SubjectsGrid extends ConsumerWidget {
  final String examCategoryId;
  final bool showInactiveItems;

  const _SubjectsGrid({
    required this.examCategoryId,
    required this.showInactiveItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider(examCategoryId));

    return subjectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading subjects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(subjectsProvider(examCategoryId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (subjects) {
        // Filter subjects based on the toggle
        final filteredSubjects = showInactiveItems
            ? subjects
            : subjects.where((subjectData) {
                final subject = subjectData['subject'] as Subject;
                return subject.isActive;
              }).toList();

        if (filteredSubjects.isEmpty) {
          return _EmptyState();
        }

        return ListView.builder(
          itemCount: filteredSubjects.length,
          itemBuilder: (context, index) {
            final subjectData = filteredSubjects.reversed.toList()[index];
            final subject = subjectData['subject'] as Subject;
            final topicsCount = subjectData['topicsCount'] as int;

            return Padding(
              key: ValueKey(subject.id),
              padding: const EdgeInsets.only(bottom: 16),
              child: _SubjectCard(
                subject: subject,
                topicsCount: topicsCount,
                examCategoryId: examCategoryId,
                position: index + 1,
              ),
            );
          },
        );
      },
    );
  }
}

class _SubjectCard extends ConsumerWidget {
  final Subject subject;
  final int topicsCount;
  final String examCategoryId;
  final int position;

  const _SubjectCard({
    required this.subject,
    required this.topicsCount,
    required this.examCategoryId,
    required this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/subjects/${subject.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 200, // Fixed height to avoid unbounded constraints
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Order indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${position}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Active/Inactive Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: subject.isActive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: subject.isActive
                            ? AppColors.success
                            : AppColors.warning,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          subject.isActive
                              ? Iconsax.tick_circle
                              : Iconsax.close_circle,
                          size: 12,
                          color: subject.isActive
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subject.isActive ? 'Active' : 'Inactive',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: subject.isActive
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuAction(context, ref, value, subject),
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

              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  subject.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$topicsCount Topic${topicsCount != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Iconsax.arrow_right_3,
                    color: AppColors.gray400,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Subject subject,
  ) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => AddSubjectDialog(
            examCategoryId: examCategoryId,
            subject: subject,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, subject);
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Subject subject,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete "${subject.name}"? This will also delete all topics and questions associated with this subject.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.of(context).pop();

                // Use the provider directly for deletion
                await ref
                    .read(subjectsProvider(examCategoryId).notifier)
                    .deleteSubject(subject.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${subject.name} deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete subject: $e'),
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

class _EmptyState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'No subjects yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first subject to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    const AddSubjectDialog(examCategoryId: 'IMUCET'),
              );
            },
            icon: const Icon(Iconsax.add),
            label: const Text('Add Subject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
