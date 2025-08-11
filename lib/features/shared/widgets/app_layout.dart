import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class AppLayout extends ConsumerWidget {
  final Widget body;
  final String currentRoute;

  const AppLayout({
    super.key,
    required this.body,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _Sidebar(
            currentRoute: currentRoute,
            currentUser: currentUser,
          ),
          // Main Content
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  final String currentRoute;
  final dynamic currentUser;

  const _Sidebar({
    required this.currentRoute,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      _MenuItem(
        icon: Iconsax.element_3,
        label: 'Dashboard',
        route: '/',
        isActive: currentRoute == '/',
      ),
      _MenuItem(
        icon: Iconsax.book_1,
        label: 'Subjects',
        route: '/subjects',
        isActive: currentRoute.startsWith('/subjects'),
      ),
      _MenuItem(
        icon: Iconsax.task_square,
        label: 'Question Bank',
        route: '/question-bank',
        isActive: currentRoute == '/question-bank',
      ),
      _MenuItem(
        icon: Iconsax.clipboard_tick,
        label: 'Practice Tests',
        route: '/practice-test',
        isActive: currentRoute == '/practice-test',
      ),
      _MenuItem(
        icon: Iconsax.route_square,
        label: 'Roadmap',
        route: '/roadmap',
        isActive: currentRoute == '/roadmap',
      ),
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.ship,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _MenuItemWidget(
                  item: item,
                  onTap: () => context.go(item.route),
                );
              },
            ),
          ),

          // Footer with User Profile
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Divider(color: AppColors.gray200),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Iconsax.user,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.fullName ?? 'Admin User',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            currentUser?.email ?? 'admin@marineprep.com',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(context, ref, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Iconsax.user),
                              SizedBox(width: 8),
                              Text('Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'signout',
                          child: Row(
                            children: [
                              Icon(Iconsax.logout, color: AppColors.error),
                              SizedBox(width: 8),
                              Text(
                                'Sign Out',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'profile':
        // TODO: Navigate to profile page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile page coming soon!'),
            backgroundColor: AppColors.warning,
          ),
        );
        break;
      case 'signout':
        _showSignOutDialog(context, ref);
        break;
    }
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/auth/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign out failed: $e'),
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
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });
}

class _MenuItemWidget extends StatelessWidget {
  final _MenuItem item;
  final VoidCallback onTap;

  const _MenuItemWidget({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          item.icon,
          color: item.isActive ? AppColors.primary : AppColors.gray600,
          size: 20,
        ),
        title: Text(
          item.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: item.isActive ? AppColors.primary : AppColors.gray700,
            fontWeight: item.isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: item.isActive 
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        selectedTileColor: AppColors.primary.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
