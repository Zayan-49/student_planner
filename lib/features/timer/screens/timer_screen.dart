import 'dart:async';

import 'package:flutter/material.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';
import 'package:student_planner/theme/widgets/gradient_background.dart';

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
    final ringColor = _isCompleted ? AppTheme.secondary : AppTheme.primary;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Focus Timer'),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: AppTheme.textPrimary,
        ),
        body:  SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [

                  const SizedBox(height: 18),
                  GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(8),
                    child: SegmentedButton<TimerMode>(
                      showSelectedIcon: false,
                      selected: <TimerMode>{_selectedMode},
                      onSelectionChanged: (selection) => _switchMode(selection.first),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppTheme.primary;
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return AppTheme.textSecondary;
                        }),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: Colors.transparent),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        textStyle: const WidgetStatePropertyAll(
                          TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 235,
                            height: 320,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: _progress),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOut,
                              builder: (context, animatedProgress, _) {
                                return CircularProgressIndicator(
                                  value: animatedProgress,
                                  strokeWidth: 7,
                                  strokeCap: StrokeCap.round,
                                  color: ringColor,
                                  backgroundColor: const Color(0x44FFFFFF),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 264,
                            height: 264,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.glass,
                              border: Border.all(color: AppTheme.border),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(2, 44, 34, 0.45),
                                  blurRadius: 28,
                                  offset: Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatTime(_remainingSeconds),
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _modeLabel(_selectedMode),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlassContainer(
                    borderRadius: 22,
                    child: Column(
                      children: [
                        Text(
                          'Focus Session',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Session $_focusSessionCount of 4',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _startTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            child: const Text('Start'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassActionButton(
                          label: 'Pause',
                          onTap: _isRunning ? _pauseTimer : null,
                          isEnabled: _isRunning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassActionButton(
                          label: 'Reset',
                          onTap: _resetTimer,
                          isEnabled: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.label,
    required this.onTap,
    required this.isEnabled,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: GlassContainer(
        borderRadius: 18,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

