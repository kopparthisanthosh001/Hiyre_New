import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './job_card_widget.dart';

class SwipeCardStack extends StatefulWidget {
  final List<Map<String, dynamic>> jobs;
  final Function(Map<String, dynamic>) onSwipeRight;
  final Function(Map<String, dynamic>) onSwipeLeft;
  final Function(Map<String, dynamic>) onCardTap;

  const SwipeCardStack({
    super.key,
    required this.jobs,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.onCardTap,
  });

  @override
  State<SwipeCardStack> createState() => _SwipeCardStackState();
}

class _SwipeCardStackState extends State<SwipeCardStack>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final threshold = 30.w;
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (_dragOffset.dx.abs() > threshold || velocity.abs() > 500) {
      // Determine swipe direction
      final isRightSwipe = _dragOffset.dx > 0 || velocity > 0;
      _performSwipe(isRightSwipe);
    } else {
      // Return to center
      _resetCard();
    }
  }

  void _performSwipe(bool isRight) {
    if (_currentIndex >= widget.jobs.length) return;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Animate card out
    _animationController.forward().then((_) {
      final currentJob = widget.jobs[_currentIndex];

      if (isRight) {
        widget.onSwipeRight(currentJob);
      } else {
        widget.onSwipeLeft(currentJob);
      }

      setState(() {
        _currentIndex++;
        _dragOffset = Offset.zero;
        _isDragging = false;
      });

      _animationController.reset();
    });
  }

  void _resetCard() {
    setState(() {
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  void swipeRight() {
    _performSwipe(true);
  }

  void swipeLeft() {
    _performSwipe(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_currentIndex >= widget.jobs.length) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: 75.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background cards (next 2 cards)
          for (int i = 2; i >= 1; i--)
            if (_currentIndex + i < widget.jobs.length)
              Positioned(
                child: Transform.scale(
                  scale: 1.0 - (i * 0.05),
                  child: Transform.translate(
                    offset: Offset(0, i * 8.0),
                    child: Opacity(
                      opacity: 1.0 - (i * 0.2),
                      child: JobCardWidget(
                        jobData: widget.jobs[_currentIndex + i],
                      ),
                    ),
                  ),
                ),
              ),

          // Current card
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final currentOffset = _isDragging
                  ? _dragOffset
                  : _slideAnimation.value * MediaQuery.of(context).size.width;

              final rotation = _isDragging
                  ? _dragOffset.dx * 0.0005
                  : _rotationAnimation.value * (_dragOffset.dx > 0 ? 1 : -1);

              final scale = _isDragging
                  ? 1.0 - (_dragOffset.dx.abs() * 0.0001).clamp(0.0, 0.1)
                  : _scaleAnimation.value;

              return Transform.translate(
                offset: currentOffset,
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onPanStart: _handlePanStart,
                      onPanUpdate: _handlePanUpdate,
                      onPanEnd: _handlePanEnd,
                      child: Stack(
                        children: [
                          JobCardWidget(
                            jobData: widget.jobs[_currentIndex],
                            onTap: () =>
                                widget.onCardTap(widget.jobs[_currentIndex]),
                          ),

                          // Swipe indicators
                          if (_isDragging) ...[
                            // Right swipe indicator (Apply)
                            if (_dragOffset.dx > 50)
                              Positioned(
                                top: 8.h,
                                right: 4.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreatMatch,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.successGreatMatch
                                            .withValues(alpha: 0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'favorite',
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'APPLY',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Left swipe indicator (Skip)
                            if (_dragOffset.dx < -50)
                              Positioned(
                                top: 8.h,
                                left: 4.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.error
                                            .withValues(alpha: 0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'close',
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'SKIP',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 75.h,
      width: 85.w,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'work_off',
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 64,
          ),
          SizedBox(height: 3.h),
          Text(
            'No More Jobs',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'You\'ve seen all available jobs. Try adjusting your filters or check back later for new opportunities.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              // Refresh jobs or navigate to filters
              Navigator.pushNamed(context, '/domain-selection');
            },
            child: Text('Adjust Filters'),
          ),
        ],
      ),
    );
  }
}
