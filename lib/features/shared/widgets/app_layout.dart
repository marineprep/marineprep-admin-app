import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final String currentRoute;

  const AppLayout({
    super.key,
    required this.body,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _Sidebar(currentRoute: currentRoute),
          // Main Content
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String currentRoute;

  const _Sidebar({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
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

          // Footer
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
                            'Admin User',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'admin@marineprep.com',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
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
