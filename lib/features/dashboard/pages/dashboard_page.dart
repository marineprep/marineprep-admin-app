import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/',
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
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your IMUCET exam content',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Stats
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: const [
                _StatCard(
                  title: 'Total Subjects',
                  value: '12',
                  icon: Iconsax.book_1,
                  color: AppColors.primary,
                ),
                _StatCard(
                  title: 'Total Topics',
                  value: '145',
                  icon: Iconsax.document_text,
                  color: AppColors.success,
                ),
                _StatCard(
                  title: 'Questions Bank',
                  value: '2,456',
                  icon: Iconsax.task_square,
                  color: AppColors.warning,
                ),
                _StatCard(
                  title: 'Practice Tests',
                  value: '89',
                  icon: Iconsax.clipboard_tick,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2,
                children: [
                  _ActionCard(
                    title: 'Manage Subjects',
                    description: 'Add subjects and topics with videos & notes',
                    icon: Iconsax.book_1,
                    color: AppColors.primary,
                    onTap: () => context.go('/subjects'),
                  ),
                  _ActionCard(
                    title: 'Question Bank',
                    description: 'Create and manage question banks',
                    icon: Iconsax.task_square,
                    color: AppColors.warning,
                    onTap: () => context.go('/question-bank'),
                  ),
                  _ActionCard(
                    title: 'Practice Tests',
                    description: 'Set up practice test questions',
                    icon: Iconsax.clipboard_tick,
                    color: AppColors.secondary,
                    onTap: () => context.go('/practice-test'),
                  ),
                  _ActionCard(
                    title: 'Roadmap',
                    description: 'Configure learning roadmap steps',
                    icon: Iconsax.route_square,
                    color: AppColors.success,
                    onTap: () => context.go('/roadmap'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: AppColors.gray400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
