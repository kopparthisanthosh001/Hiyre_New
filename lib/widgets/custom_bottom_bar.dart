import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom navigation bar variants
enum CustomBottomBarVariant { standard, floating, minimal }

/// Navigation item data class
class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String? badge;
}

/// A custom bottom navigation bar widget optimized for mobile job matching
/// with gesture-first navigation and contextual feedback
class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
    this.enableHapticFeedback = true,
  });

  /// Current selected index
  final int currentIndex;

  /// Callback when item is tapped
  final ValueChanged<int> onTap;

  /// The variant of the bottom bar
  final CustomBottomBarVariant variant;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected item color
  final Color? selectedItemColor;

  /// Custom unselected item color
  final Color? unselectedItemColor;

  /// Custom elevation
  final double? elevation;

  /// Whether to show labels
  final bool showLabels;

  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;

  /// Navigation items with hardcoded routes
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      label: 'Matched Jobs',
      route: '/job-swipe-deck',
    ),
    BottomNavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: 'Applications',
      route: '/applied-jobs',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildBottomBarItem(
              context: context,
              index: index,
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              isSelected: currentIndex == index,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color:
                  isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle navigation item tap with haptic feedback
  void _handleTap(BuildContext context, int index, String route) {
    if (enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Call the onTap callback
    onTap(index);

    // Navigate to the route if different from current
    if (currentIndex != index) {
      Navigator.pushNamed(context, route);
    }
  }

  /// Factory constructor for standard bottom bar
  factory CustomBottomBar.standard({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool showLabels = true,
    bool enableHapticFeedback = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.standard,
      showLabels: showLabels,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Factory constructor for floating bottom bar
  factory CustomBottomBar.floating({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool showLabels = true,
    bool enableHapticFeedback = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.floating,
      showLabels: showLabels,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Factory constructor for minimal bottom bar
  factory CustomBottomBar.minimal({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
    bool enableHapticFeedback = true,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomBottomBarVariant.minimal,
      showLabels: false,
      enableHapticFeedback: enableHapticFeedback,
    );
  }
}
