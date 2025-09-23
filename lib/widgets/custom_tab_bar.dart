import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab bar variants for different use cases
enum CustomTabBarVariant {
  standard,
  pills,
  underline,
  segmented,
}

/// Tab item data class
class TabItem {
  const TabItem({
    required this.label,
    this.icon,
    this.badge,
    this.route,
  });

  final String label;
  final IconData? icon;
  final String? badge;
  final String? route;
}

/// A custom tab bar widget that provides consistent styling and functionality
/// for job matching application with progressive information disclosure
class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.variant = CustomTabBarVariant.standard,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.backgroundColor,
    this.enableHapticFeedback = true,
    this.onTap,
  });

  /// List of tab items
  final List<TabItem> tabs;

  /// Tab controller
  final TabController controller;

  /// The variant of the tab bar
  final CustomTabBarVariant variant;

  /// Whether the tab bar is scrollable
  final bool isScrollable;

  /// Custom indicator color
  final Color? indicatorColor;

  /// Custom label color
  final Color? labelColor;

  /// Custom unselected label color
  final Color? unselectedLabelColor;

  /// Custom background color
  final Color? backgroundColor;

  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;

  /// Callback when tab is tapped
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.underline:
        return _buildUnderlineTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context, theme, colorScheme);
      case CustomTabBarVariant.standard:
      default:
        return _buildStandardTabBar(context, theme, colorScheme);
    }
  }

  /// Build standard tab bar
  Widget _buildStandardTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => _buildStandardTab(context, theme, colorScheme, tab))
            .toList(),
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor: unselectedLabelColor ??
            colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: _handleTap,
      ),
    );
  }

  /// Build pills tab bar
  Widget _buildPillsTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return TabBar(
      controller: controller,
      tabs: tabs
          .map((tab) => _buildPillTab(context, theme, colorScheme, tab))
          .toList(),
      isScrollable: isScrollable,
      indicator: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.all(4),
      labelColor: colorScheme.onPrimary,
      unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.7),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      dividerColor: Colors.transparent,
      onTap: _handleTap,
    );
  }

  /// Build underline tab bar
  Widget _buildUnderlineTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => _buildUnderlineTab(context, theme, colorScheme, tab))
            .toList(),
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.onSurface,
        unselectedLabelColor: unselectedLabelColor ??
            colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorWeight: 2.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        dividerColor: Colors.transparent,
        onTap: _handleTap,
      ),
    );
  }

  /// Build segmented tab bar
  Widget _buildSegmentedTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map((tab) => _buildSegmentedTab(context, theme, colorScheme, tab))
            .toList(),
        isScrollable: false,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.7),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        dividerColor: Colors.transparent,
        onTap: _handleTap,
      ),
    );
  }

  /// Build standard tab
  Widget _buildStandardTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TabItem tab,
  ) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tab.icon != null) ...[
            Icon(tab.icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(tab.label),
          if (tab.badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tab.badge!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build pill tab
  Widget _buildPillTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TabItem tab,
  ) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(tab.label),
            if (tab.badge != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build underline tab
  Widget _buildUnderlineTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TabItem tab,
  ) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tab.icon != null) ...[
            Icon(tab.icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(tab.label),
          if (tab.badge != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build segmented tab
  Widget _buildSegmentedTab(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TabItem tab,
  ) {
    return Tab(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                tab.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (tab.badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tab.badge!,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onError,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle tab tap with haptic feedback and navigation
  void _handleTap(int index) {
    if (enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Call the onTap callback if provided
    onTap?.call(index);

    // Navigate to route if specified
    final tab = tabs[index];
    if (tab.route != null) {
      // Note: Navigation would typically be handled by the parent widget
      // This is just for demonstration of the route capability
    }
  }

  /// Factory constructor for job categories tabs
  factory CustomTabBar.jobCategories({
    Key? key,
    required TabController controller,
    bool isScrollable = true,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      key: key,
      controller: controller,
      variant: CustomTabBarVariant.pills,
      isScrollable: isScrollable,
      onTap: onTap,
      tabs: const [
        TabItem(label: 'All Jobs', icon: Icons.work_outline_rounded),
        TabItem(label: 'Tech', icon: Icons.computer_outlined),
        TabItem(label: 'Design', icon: Icons.palette_outlined),
        TabItem(label: 'Marketing', icon: Icons.campaign_outlined),
        TabItem(label: 'Sales', icon: Icons.trending_up_rounded),
        TabItem(label: 'Finance', icon: Icons.account_balance_outlined),
      ],
    );
  }

  /// Factory constructor for application status tabs
  factory CustomTabBar.applicationStatus({
    Key? key,
    required TabController controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      key: key,
      controller: controller,
      variant: CustomTabBarVariant.segmented,
      onTap: onTap,
      tabs: const [
        TabItem(label: 'Applied', badge: '5'),
        TabItem(label: 'Interviews', badge: '2'),
        TabItem(label: 'Offers', badge: '1'),
      ],
    );
  }

  /// Factory constructor for profile sections tabs
  factory CustomTabBar.profileSections({
    Key? key,
    required TabController controller,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      key: key,
      controller: controller,
      variant: CustomTabBarVariant.underline,
      onTap: onTap,
      tabs: const [
        TabItem(label: 'Overview', icon: Icons.person_outline_rounded),
        TabItem(label: 'Experience', icon: Icons.work_history_outlined),
        TabItem(label: 'Skills', icon: Icons.star_outline_rounded),
        TabItem(label: 'Education', icon: Icons.school_outlined),
      ],
    );
  }

  /// Factory constructor for match filters tabs
  factory CustomTabBar.matchFilters({
    Key? key,
    required TabController controller,
    bool isScrollable = true,
    ValueChanged<int>? onTap,
  }) {
    return CustomTabBar(
      key: key,
      controller: controller,
      variant: CustomTabBarVariant.standard,
      isScrollable: isScrollable,
      onTap: onTap,
      tabs: const [
        TabItem(label: 'Great Match', icon: Icons.favorite_rounded),
        TabItem(label: 'Good Match', icon: Icons.thumb_up_outlined),
        TabItem(label: 'Okay Match', icon: Icons.thumbs_up_down_outlined),
        TabItem(label: 'All Matches', icon: Icons.list_rounded),
      ],
    );
  }
}
