import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/injection.dart';
import '../../../core/security/app_lock_service.dart';
import '../../../core/localization/app_localizations.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    super.key,
    this.onUnlocked,
  });

  final VoidCallback? onUnlocked;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final List<String> _enteredPin = [];
  late final AppLockService _appLockService = getIt<AppLockService>();

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _tryBiometricAuth();
  }

  bool _isAuthenticating = false;
  String? _errorMessage;
  bool _biometricAvailable = false;

  Future<void> _checkBiometric() async {
    final available = await _appLockService.isBiometricAvailable();
    final enabled = await _appLockService.isBiometricEnabled();
    setState(() {
      _biometricAvailable = available && enabled;
    });
  }

  Future<void> _tryBiometricAuth() async {
    final biometricEnabled = await _appLockService.isBiometricEnabled();
    if (biometricEnabled && _biometricAvailable) {
      final result = await _appLockService.authenticateWithBiometric(
        reason: 'Unlock Enshaal Khata',
      );
      if (result && mounted) {
        widget.onUnlocked?.call();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  void _onPinDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin.add(digit);
        _errorMessage = null;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isAuthenticating = true);

    final pin = _enteredPin.join();
    final isValid = await _appLockService.verifyPin(pin);

    if (isValid) {
      if (mounted) {
        widget.onUnlocked?.call();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      setState(() {
        _enteredPin.clear();
        _errorMessage = 'Incorrect PIN';
        _isAuthenticating = false;
      });
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    // Match screenshot color - reddish brown
    const pinColor = Color(0xFF8B4513);

    return Scaffold(
      backgroundColor:
          const Color(0xFF2C2C2C), // Dark gray background from screenshot
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
                  loc.enterLoginPin,
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
                        color: index < _enteredPin.length
                            ? pinColor
                            : pinColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.resetPinFromSettings)),
                    );
                  },
                  child: Text(
                    loc.forgotPin,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: pinColor,
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
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
                if (_biometricAvailable) ...[
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.fingerprint, size: 40),
                    color: theme.colorScheme.primary,
                    onPressed: _tryBiometricAuth,
                  ),
                  Text(
                    loc.useBiometric,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
            if (_isAuthenticating)
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
                            loc.verifying,
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
