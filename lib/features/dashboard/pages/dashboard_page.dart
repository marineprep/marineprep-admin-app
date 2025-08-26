import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_layout.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  // Format number with commas for better readability
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                ),
                Consumer(
                  builder: (context, ref, child) {
                    return IconButton(
                      onPressed: () {
                        ref.invalidate(dashboardStatsProvider);
                      },
                      icon: const Icon(Iconsax.refresh),
                      tooltip: 'Refresh Stats',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Stats
            Consumer(
              builder: (context, ref, child) {
                final statsAsync = ref.watch(dashboardStatsProvider);

                return statsAsync.when(
                  data: (stats) => GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        title: 'Total Subjects',
                        value: _formatNumber(stats['subjects'] ?? 0),
                        icon: Iconsax.book_1,
                        color: AppColors.primary,
                      ),
                      _StatCard(
                        title: 'Total Topics',
                        value: _formatNumber(stats['topics'] ?? 0),
                        icon: Iconsax.document_text,
                        color: AppColors.success,
                      ),
                      _StatCard(
                        title: 'Questions Bank',
                        value: _formatNumber(stats['questions'] ?? 0),
                        icon: Iconsax.task_square,
                        color: AppColors.warning,
                      ),
                      _StatCard(
                        title: 'Practice Tests',
                        value: _formatNumber(stats['practiceTests'] ?? 0),
                        icon: Iconsax.clipboard_tick,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  loading: () => GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _StatCard(
                        title: 'Total Subjects',
                        value: 'Loading...',
                        icon: Iconsax.book_1,
                        color: AppColors.primary,
                        isLoading: true,
                      ),
                      _StatCard(
                        title: 'Total Topics',
                        value: 'Loading...',
                        icon: Iconsax.document_text,
                        color: AppColors.success,
                        isLoading: true,
                      ),
                      _StatCard(
                        title: 'Questions Bank',
                        value: 'Loading...',
                        icon: Iconsax.task_square,
                        color: AppColors.warning,
                        isLoading: true,
                      ),
                      _StatCard(
                        title: 'Practice Tests',
                        value: 'Loading...',
                        icon: Iconsax.clipboard_tick,
                        color: AppColors.secondary,
                        isLoading: true,
                      ),
                    ],
                  ),
                  error: (error, stack) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Failed to load dashboard statistics',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.error),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.invalidate(dashboardStatsProvider);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            value: '--',
                            icon: Iconsax.book_1,
                            color: AppColors.gray400,
                          ),
                          _StatCard(
                            title: 'Total Topics',
                            value: '--',
                            icon: Iconsax.document_text,
                            color: AppColors.gray400,
                          ),
                          _StatCard(
                            title: 'Questions Bank',
                            value: '--',
                            icon: Iconsax.task_square,
                            color: AppColors.gray400,
                          ),
                          _StatCard(
                            title: 'Practice Tests',
                            value: '--',
                            icon: Iconsax.clipboard_tick,
                            color: AppColors.gray400,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Last updated timestamp
            Consumer(
              builder: (context, ref, child) {
                final statsAsync = ref.watch(dashboardStatsProvider);
                return statsAsync.when(
                  data: (stats) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Last updated: ${DateTime.now().toString().substring(0, 19)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 40),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
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
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const Spacer(),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            else
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
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
                child: Icon(icon, color: color, size: 24),
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              Icon(Iconsax.arrow_right_3, color: AppColors.gray400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
