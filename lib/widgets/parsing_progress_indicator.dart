import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_export.dart';

class ParsingProgressIndicator extends StatefulWidget {
  final String currentStep;
  final double progress;
  final bool isComplete;
  final VoidCallback? onComplete;

  const ParsingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.progress,
    this.isComplete = false,
    this.onComplete,
  });

  @override
  State<ParsingProgressIndicator> createState() => _ParsingProgressIndicatorState();
}

class _ParsingProgressIndicatorState extends State<ParsingProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  final List<String> _steps = [
    'Extracting text from PDF...',
    'Analyzing document structure...',
    'Identifying personal information...',
    'Extracting work experience...',
    'Finding education details...',
    'Collecting skills and certifications...',
    'Finalizing profile data...',
  ];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  @override
  void didUpdateWidget(ParsingProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressController.animateTo(widget.progress);
    }
    if (widget.isComplete && !oldWidget.isComplete) {
      _pulseController.stop();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Resume Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isComplete ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: widget.isComplete 
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isComplete ? Icons.check_circle : Icons.description,
                    size: 10.w,
                    color: widget.isComplete 
                        ? Colors.green
                        : AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: 4.h),
          
          // Progress Bar
          Container(
            width: double.infinity,
            height: 0.8.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value * widget.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isComplete
                            ? [Colors.green, Colors.green.shade300]
                            : [
                                AppTheme.lightTheme.colorScheme.primary,
                                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.7),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Progress Percentage
          Text(
            '${(widget.progress * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: widget.isComplete 
                  ? Colors.green
                  : AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Current Step
          Text(
            widget.isComplete ? 'Resume parsed successfully!' : widget.currentStep,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Step Details
          if (!widget.isComplete) ...[
            Text(
              'Please wait while we extract and analyze your resume data...',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ] else ...[
            Text(
              'Your profile will be automatically filled with the extracted information.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.green.shade700,
              ),
            ),
          ],
          
          SizedBox(height: 4.h),
          
          // Steps List
          if (!widget.isComplete)
            _buildStepsList(),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processing Steps:',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ..._steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCurrentStep = widget.currentStep.toLowerCase().contains(
              step.toLowerCase().split('...').first.trim()
            );
            final isCompleted = (index + 1) / _steps.length < widget.progress;
            
            return Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green
                          : isCurrentStep
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.grey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 2.w,
                            color: Colors.white,
                          )
                        : isCurrentStep
                            ? SizedBox(
                                width: 2.w,
                                height: 2.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      step,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: isCurrentStep ? FontWeight.w500 : FontWeight.w400,
                        color: isCompleted || isCurrentStep
                            ? AppTheme.lightTheme.colorScheme.onSurface
                            : AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}