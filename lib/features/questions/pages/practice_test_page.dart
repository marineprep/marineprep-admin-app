import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';
import '../widgets/add_question_dialog.dart';

class PracticeTestPage extends ConsumerWidget {
  const PracticeTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage practice test questions',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddQuestionDialog(context),
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

            // Coming Soon Message
            Expanded(
              child: Center(
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
                      'Practice Test Management',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This section will have similar functionality to Question Bank\nbut specifically for practice test questions.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddQuestionDialog(
        subjectId: 'temp-subject-id',
        sectionType: 'practice_test',
      ),
    );
  }
}
