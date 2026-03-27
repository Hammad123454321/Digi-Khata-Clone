import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final List<String> _enteredPin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  // Match screenshot color - reddish brown
  const pinColor = Color(0xFF8B4513);

  void _onPinDigitPressed(String digit) {
    if (_isSubmitting) return;

    if (!_isConfirming) {
      if (_enteredPin.length < 4) {
        setState(() {
          _enteredPin.add(digit);
          _errorMessage = null;
        });

        if (_enteredPin.length == 4) {
          // Switch to confirmation
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _isConfirming = true;
              });
            }
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin.add(digit);
          _errorMessage = null;
        });

        if (_confirmPin.length == 4) {
          _verifyAndSetPin();
        }
      }
    }
  }

  void _onBackspace() {
    if (_isSubmitting) return;

    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin.removeLast();
          _errorMessage = null;
        });
      } else {
        // Go back to first PIN entry
        setState(() {
          _isConfirming = false;
          _enteredPin.clear();
        });
      }
    } else {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin.removeLast();
          _errorMessage = null;
        });
      }
    }
  }

  Future<void> _verifyAndSetPin() async {
    if (_enteredPin.join() != _confirmPin.join()) {
      setState(() {
        _errorMessage = 'PINs do not match';
        _confirmPin.clear();
        _isConfirming = false;
        _enteredPin.clear();
      });
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isSubmitting = true);

    final pin = _enteredPin.join();
    context.read<AuthBloc>().add(SetPinEvent(pin));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final currentPin = _isConfirming ? _confirmPin : _enteredPin;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PinSet) {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else if (state is AuthError) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = state.message;
            _confirmPin.clear();
            _isConfirming = false;
            _enteredPin.clear();
          });
          HapticFeedback.vibrate();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2C2C2C), // Dark gray background
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: pinColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isConfirming ? 'Confirm PIN' : 'Set Login PIN',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: index < currentPin.length
                              ? pinColor
                              : pinColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PinButton('1', _onPinDigitPressed, pinColor),
                            _PinButton('2', _onPinDigitPressed, pinColor),
                            _PinButton('3', _onPinDigitPressed, pinColor),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PinButton('4', _onPinDigitPressed, pinColor),
                            _PinButton('5', _onPinDigitPressed, pinColor),
                            _PinButton('6', _onPinDigitPressed, pinColor),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PinButton('7', _onPinDigitPressed, pinColor),
                            _PinButton('8', _onPinDigitPressed, pinColor),
                            _PinButton('9', _onPinDigitPressed, pinColor),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 72, height: 72),
                            _PinButton('0', _onPinDigitPressed, pinColor),
                            _BackspaceButton(_onBackspace, pinColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              if (_isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFE24B2D),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Setting PIN...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton(this.digit, this.onPressed, this.color);

  final String digit;
  final ValueChanged<String> onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPressed(digit),
          borderRadius: BorderRadius.circular(36),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  const _BackspaceButton(this.onPressed, this.color);

  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(36),
          child: Center(
            child: Icon(
              Icons.backspace,
              color: color,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
