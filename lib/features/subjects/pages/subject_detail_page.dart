import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';
import '../widgets/add_topic_dialog.dart';
import '../models/topic.dart';
import '../providers/subjects_provider.dart';
import '../providers/topics_provider.dart';

class SubjectDetailPage extends ConsumerWidget {
  final String subjectId;

  const SubjectDetailPage({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAsync = ref.watch(subjectProvider(subjectId));
    final topicsAsync = ref.watch(topicsProvider(subjectId));
    
    return AppLayout(
      currentRoute: '/subjects/$subjectId',
      body: subjectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                'Error loading subject',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(subjectProvider(subjectId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (subject) {
          if (subject == null) {
            return const Center(
              child: Text('Subject not found'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with breadcrumb
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.go('/subjects'),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.arrow_left_2,
                            color: AppColors.gray600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Subjects',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      ' / ',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Subject Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subject.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddTopicDialog(context, ref),
                      icon: const Icon(Iconsax.add),
                      label: const Text('Add Topic'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Topics Section
                Row(
                  children: [
                    Text(
                      'Topics',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    topicsAsync.when(
                      loading: () => const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, _) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Error',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      data: (topics) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${topics.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Topics List
                Expanded(
                  child: _TopicsList(subjectId: subjectId),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddTopicDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddTopicDialog(subjectId: subjectId),
    );
  }
}

class _TopicsList extends ConsumerWidget {
  final String subjectId;
  
  const _TopicsList({required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider(subjectId));

    return topicsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
              'Error loading topics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(topicsProvider(subjectId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (topics) {
        if (topics.isEmpty) {
          return _EmptyTopicsState();
        }

        return ListView.separated(
          itemCount: topics.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final topic = topics.reversed.toList()[index];
            return _TopicCard(topic: topic, subjectId: subjectId);
          },
        );
      },
    );
  }
}

class _TopicCard extends ConsumerWidget {
  final Topic topic;
  final String subjectId;

  const _TopicCard({required this.topic, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVideos = topic.videos.isNotEmpty;
    final hasNotes = topic.notesUrl != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                      '${topic.orderIndex}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Topic info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, ref, value, topic),
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

            // Content indicators
            Row(
              children: [
                if (hasVideos) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.video_play,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${topic.videos.length} Video${topic.videos.length != 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (hasNotes) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.document_text,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Notes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!hasVideos && !hasNotes) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'No content',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, Topic topic) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => AddTopicDialog(
            subjectId: topic.subjectId,
            topic: topic,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, topic);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Topic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text(
          'Are you sure you want to delete "${topic.name}"? This action cannot be undone.',
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
                 await ref.read(topicsProvider(subjectId).notifier)
                     .deleteTopic(topic.id);
                 
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text('${topic.name} deleted successfully'),
                       backgroundColor: AppColors.success,
                     ),
                   );
                 }
               } catch (e) {
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       content: Text('Failed to delete topic: $e'),
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

class _EmptyTopicsState extends StatelessWidget {
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
              Iconsax.document_text,
              size: 64,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No topics yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add topics with videos and notes',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
