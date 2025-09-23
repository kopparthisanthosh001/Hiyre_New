import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar variants for different screens
enum CustomAppBarVariant {
  standard,
  search,
  profile,
  back,
  transparent,
}

/// A custom app bar widget that provides consistent styling and functionality
/// across the job matching application with professional confidence design
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.variant = CustomAppBarVariant.standard,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.showProfileButton = false,
    this.showSearchButton = false,
    this.showNotificationButton = false,
    this.onBackPressed,
    this.onProfilePressed,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.actions,
    this.bottom,
  });

  /// The variant of the app bar
  final CustomAppBarVariant variant;

  /// The title text to display
  final String? title;

  /// The subtitle text to display (optional)
  final String? subtitle;

  /// Whether to show the back button
  final bool showBackButton;

  /// Whether to show the profile button
  final bool showProfileButton;

  /// Whether to show the search button
  final bool showSearchButton;

  /// Whether to show the notification button
  final bool showNotificationButton;

  /// Callback for back button press
  final VoidCallback? onBackPressed;

  /// Callback for profile button press
  final VoidCallback? onProfilePressed;

  /// Callback for search button press
  final VoidCallback? onSearchPressed;

  /// Callback for notification button press
  final VoidCallback? onNotificationPressed;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color
  final Color? foregroundColor;

  /// Custom elevation
  final double? elevation;

  /// Whether to center the title
  final bool centerTitle;

  /// Additional action widgets
  final List<Widget>? actions;

  /// Bottom widget (like TabBar)
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant
    Color? appBarBackgroundColor;
    Color? appBarForegroundColor;
    double appBarElevation = 2.0;

    switch (variant) {
      case CustomAppBarVariant.transparent:
        appBarBackgroundColor = Colors.transparent;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = 0.0;
        break;
      case CustomAppBarVariant.search:
      case CustomAppBarVariant.profile:
      case CustomAppBarVariant.back:
      case CustomAppBarVariant.standard:
        appBarBackgroundColor = backgroundColor ?? colorScheme.surface;
        appBarForegroundColor = foregroundColor ?? colorScheme.onSurface;
        appBarElevation = elevation ?? 2.0;
        break;
    }

    return AppBar(
      backgroundColor: appBarBackgroundColor,
      foregroundColor: appBarForegroundColor,
      elevation: appBarElevation,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
      bottom: bottom,
    );
  }

  /// Build the leading widget
  Widget? _buildLeading(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
        splashRadius: 24,
      );
    }

    if (variant == CustomAppBarVariant.profile) {
      return IconButton(
        icon: CircleAvatar(
          radius: 16,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        onPressed: onProfilePressed ??
            () => Navigator.pushNamed(context, '/profile-creation'),
        tooltip: 'Profile',
        splashRadius: 24,
      );
    }

    return null;
  }

  /// Build the title widget
  Widget? _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (title == null && subtitle == null) return null;

    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              letterSpacing: 0.4,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Text(
      title!,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build the actions list
  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Widget> actionWidgets = [];

    // Add search button
    if (showSearchButton || variant == CustomAppBarVariant.search) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: onSearchPressed ??
              () => Navigator.pushNamed(context, '/job-swipe-deck'),
          tooltip: 'Search Jobs',
          splashRadius: 24,
        ),
      );
    }

    // Add notification button
    if (showNotificationButton) {
      actionWidgets.add(
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationPressed ??
                  () => Navigator.pushNamed(context, '/applied-jobs'),
              tooltip: 'Notifications',
              splashRadius: 24,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Add profile button (if not already in leading)
    if (showProfileButton && variant != CustomAppBarVariant.profile) {
      actionWidgets.add(
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.person_outline_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          onPressed: onProfilePressed ??
              () => Navigator.pushNamed(context, '/profile-creation'),
          tooltip: 'Profile',
          splashRadius: 24,
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  /// Factory constructor for home screen app bar
  factory CustomAppBar.home({
    Key? key,
    String? title = 'Job Match',
    bool showNotificationButton = true,
    bool showProfileButton = true,
    VoidCallback? onNotificationPressed,
    VoidCallback? onProfilePressed,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.standard,
      title: title,
      showNotificationButton: showNotificationButton,
      showProfileButton: showProfileButton,
      onNotificationPressed: onNotificationPressed,
      onProfilePressed: onProfilePressed,
      centerTitle: false,
    );
  }

  /// Factory constructor for search screen app bar
  factory CustomAppBar.search({
    Key? key,
    String? title = 'Find Jobs',
    bool showBackButton = true,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.search,
      title: title,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
    );
  }

  /// Factory constructor for profile screen app bar
  factory CustomAppBar.profile({
    Key? key,
    String? title = 'Profile',
    String? subtitle,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.profile,
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
    );
  }

  /// Factory constructor for detail screens with back button
  factory CustomAppBar.detail({
    Key? key,
    String? title,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.back,
      title: title,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      actions: actions,
    );
  }

  /// Factory constructor for transparent app bar (splash, onboarding)
  factory CustomAppBar.transparent({
    Key? key,
    String? title,
    Color? foregroundColor,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      variant: CustomAppBarVariant.transparent,
      title: title,
      foregroundColor: foregroundColor,
      actions: actions,
    );
  }
}
