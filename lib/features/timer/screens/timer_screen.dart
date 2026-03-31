import 'dart:async';

import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';

enum TimerMode {
  focus,
  shortBreak,
  longBreak,
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const Map<TimerMode, int> _modeDurationsInSeconds = {
    TimerMode.focus: 25 * 60,
    TimerMode.shortBreak: 5 * 60,
    TimerMode.longBreak: 15 * 60,
  };

  Timer? _timer;
  TimerMode _selectedMode = TimerMode.focus;
  bool _isRunning = false;
  bool _isCompleted = false;
  int _focusSessionCount = 1;
  int _remainingSeconds = _modeDurationsInSeconds[TimerMode.focus]!;

  int get _totalSeconds => _modeDurationsInSeconds[_selectedMode]!;

  double get _progress {
    if (_totalSeconds == 0) {
      return 0;
    }
    return (_remainingSeconds / _totalSeconds).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning || _remainingSeconds <= 0) {
      return;
    }

    setState(() {
      _isRunning = true;
      _isCompleted = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isCompleted = true;
          if (_selectedMode == TimerMode.focus && _focusSessionCount < 4) {
            _focusSessionCount += 1;
          }
        });
        return;
      }

      setState(() {
        _remainingSeconds -= 1;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _switchMode(TimerMode mode) {
    if (_selectedMode == mode) {
      return;
    }

    _timer?.cancel();
    setState(() {
      _selectedMode = mode;
      _remainingSeconds = _modeDurationsInSeconds[mode]!;
      _isRunning = false;
      _isCompleted = false;
    });
  }

  String _modeLabel(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'Focus';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    final String minutesText = minutes.toString().padLeft(2, '0');
    final String secondsText = secs.toString().padLeft(2, '0');
    return '$minutesText:$secondsText';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color activeColor = _isCompleted ? AppColors.success : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Focus Timer'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SegmentedButton<TimerMode>(
                showSelectedIcon: false,
                selected: <TimerMode>{_selectedMode},
                onSelectionChanged: (selection) {
                  _switchMode(selection.first);
                },
                segments: <ButtonSegment<TimerMode>>[
                  ButtonSegment<TimerMode>(
                    value: TimerMode.focus,
                    label: Text(_modeLabel(TimerMode.focus)),
                  ),
                  ButtonSegment<TimerMode>(
                    value: TimerMode.shortBreak,
                    label: Text(_modeLabel(TimerMode.shortBreak)),
                  ),
                  ButtonSegment<TimerMode>(
                    value: TimerMode.longBreak,
                    label: Text(_modeLabel(TimerMode.longBreak)),
                  ),
                ],
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0x1A4F46E5);
                    }
                    return Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.textSecondary;
                  }),
                  side: const WidgetStatePropertyAll(
                    BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 280,
                height: 280,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _progress),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          color: activeColor,
                          backgroundColor: const Color(0xFFE5E7EB),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _modeLabel(_selectedMode),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Focus Session',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Session $_focusSessionCount of 4',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _isRunning ? _pauseTimer : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Pause'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _resetTimer,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


