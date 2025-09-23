import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

class ResendTimer extends StatefulWidget {
  final VoidCallback onResend;
  final int initialSeconds;
  final bool isActive;

  const ResendTimer({
    super.key,
    required this.onResend,
    this.initialSeconds = 60,
    this.isActive = false,
  });

  @override
  State<ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<ResendTimer> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(ResendTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = widget.initialSeconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _canResend = true;
      _remainingSeconds = 0;
    });
  }

  void _handleResend() {
    if (_canResend) {
      widget.onResend();
      _startTimer();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Didn't receive the code? ",
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          GestureDetector(
            onTap: _canResend ? _handleResend : null,
            child: Text(
              _canResend
                  ? 'Resend'
                  : 'Resend in ${_formatTime(_remainingSeconds)}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _canResend
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                decoration: _canResend ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}