import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';

class RoadmapPage extends ConsumerWidget {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLayout(
      currentRoute: '/roadmap',
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
                      'Learning Roadmap',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure the learning path for students',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddStepDialog(context),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Step'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Roadmap Options
            Row(
              children: [
                Expanded(
                  child: _RoadmapTypeCard(
                    title: 'Static Roadmap',
                    description: 'A fixed learning path for all students',
                    icon: Iconsax.route_square,
                    color: AppColors.primary,
                    isSelected: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoadmapTypeCard(
                    title: 'Dynamic Roadmap',
                    description: 'Personalized path based on student progress',
                    icon: Iconsax.diagram,
                    color: AppColors.secondary,
                    isSelected: false,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Current Roadmap Steps
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Roadmap Steps',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _RoadmapStepsList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStepDialog(BuildContext context) {
    // TODO: Implement add roadmap step dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add roadmap step functionality coming soon'),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}

class _RoadmapTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoadmapTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Selected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapStepsList extends StatelessWidget {
  // Mock roadmap steps
  final List<Map<String, dynamic>> steps = [
    {
      'title': 'Complete Mathematics Foundation',
      'description': 'Master basic mathematical concepts including algebra and trigonometry',
      'type': 'custom',
      'order': 1,
      'estimatedMinutes': 180,
      'isRequired': true,
    },
    {
      'title': 'Watch Physics Videos',
      'description': 'Complete all physics video lessons',
      'type': 'video',
      'order': 2,
      'estimatedMinutes': 240,
      'isRequired': true,
    },
    {
      'title': 'Practice Question Banks',
      'description': 'Solve practice questions for all subjects',
      'type': 'question_bank',
      'order': 3,
      'estimatedMinutes': 120,
      'isRequired': true,
    },
    {
      'title': 'Take Practice Tests',
      'description': 'Complete timed practice examinations',
      'type': 'practice_test',
      'order': 4,
      'estimatedMinutes': 90,
      'isRequired': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: steps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final step = steps[index];
        return _RoadmapStepCard(step: step);
      },
    );
  }
}

class _RoadmapStepCard extends StatelessWidget {
  final Map<String, dynamic> step;

  const _RoadmapStepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final IconData stepIcon = _getStepIcon(step['type']);
    final Color stepColor = _getStepColor(step['type']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Order number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stepColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${step['order']}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Step icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stepColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                stepIcon,
                color: stepColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Step details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step['title'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (step['isRequired'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Required',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 16,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${step['estimatedMinutes']} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stepColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStepTypeLabel(step['type']),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: stepColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value, step),
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
      ),
    );
  }

  IconData _getStepIcon(String type) {
    switch (type) {
      case 'video':
        return Iconsax.video_play;
      case 'notes':
        return Iconsax.document_text;
      case 'question_bank':
        return Iconsax.task_square;
      case 'practice_test':
        return Iconsax.clipboard_tick;
      default:
        return Iconsax.note;
    }
  }

  Color _getStepColor(String type) {
    switch (type) {
      case 'video':
        return AppColors.success;
      case 'notes':
        return AppColors.warning;
      case 'question_bank':
        return AppColors.primary;
      case 'practice_test':
        return AppColors.secondary;
      default:
        return AppColors.gray600;
    }
  }

  String _getStepTypeLabel(String type) {
    switch (type) {
      case 'video':
        return 'Video';
      case 'notes':
        return 'Notes';
      case 'question_bank':
        return 'Questions';
      case 'practice_test':
        return 'Test';
      default:
        return 'Custom';
    }
  }

  void _handleMenuAction(BuildContext context, String action, Map<String, dynamic> step) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit functionality coming soon'),
            backgroundColor: AppColors.warning,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, step);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> step) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Roadmap Step'),
        content: Text(
          'Are you sure you want to delete "${step['title']}"? This action cannot be undone.',
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
                SnackBar(
                  content: Text('${step['title']} deleted successfully'),
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
