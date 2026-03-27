import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_bloc.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/validators.dart' show AppValidators;
import '../../../shared/widgets/gradient_pill_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  Timer? _requestTimeoutTimer;
  bool _languageSheetShown = false;

  @override
  void initState() {
    super.initState();
    _maybeShowLanguageSheet();
  }

  @override
  void dispose() {
    _requestTimeoutTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (_isLoading) return; // Prevent multiple submissions
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _startRequestTimeout();
      context.read<AuthBloc>().add(
            RequestOtpEvent(_phoneController.text.trim()),
          );
    }
  }

  void _startRequestTimeout() {
    _requestTimeoutTimer?.cancel();
    _requestTimeoutTimer = Timer(const Duration(seconds: 25), () {
      if (!mounted || !_isLoading) return;
      setState(() => _isLoading = false);
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.requestTimedOut),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpRequested) {
              if (mounted) {
                _requestTimeoutTimer?.cancel();
                setState(() => _isLoading = false);
              }
            } else if (state is AuthError) {
              if (mounted) {
                _requestTimeoutTimer?.cancel();
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            }
          },
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: BlocBuilder<LocaleBloc, LocaleState>(
                        builder: (context, localeState) {
                          final label = _languageLabel(
                              localeState.locale.languageCode, loc);
                          return TextButton.icon(
                            onPressed: _showLanguageSheet,
                            icon: const Icon(Icons.language, size: 18),
                            label: Text(label),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              textStyle: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'app-logo.jpeg',
                                    height: 64,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    loc.appName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              loc.getStarted,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.enterMobileNumber,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Pakistan flag - green square with white crescent and star
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFF3BAA4D), // Green
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Crescent moon
                                            Positioned(
                                              left: 2,
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 4,
                                              child: Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF3BAA4D),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            // Star
                                            Positioned(
                                              right: 2,
                                              top: 2,
                                              child: Icon(
                                                Icons.star,
                                                size: 8,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '+92',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) =>
                                        AppValidators.phone(value, loc),
                                    onFieldSubmitted: (_) =>
                                        _handleRequestOtp(),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: loc.phoneHint,
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.outline
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.outline
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 1.6,
                                        ),
                                      ),
                                      hintStyle: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: GradientPillButton(
                        label: loc.sendOtp,
                        trailingIcon: Icons.arrow_forward,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleRequestOtp,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading) _LoadingOverlay(message: loc.pleaseWait),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _maybeShowLanguageSheet() async {
    if (_languageSheetShown) return;
    final storage = getIt<LocalStorageService>();
    if (!storage.isFirstLaunch()) return;
    _languageSheetShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showLanguageSheet();
      }
    });
  }

  String _languageLabel(String code, AppLocalizations loc) {
    switch (code) {
      case 'ur':
        return loc.urdu;
      case 'ar':
        return loc.arabic;
      case 'en':
      default:
        return loc.english;
    }
  }

  Future<void> _showLanguageSheet() async {
    final storage = getIt<LocalStorageService>();
    final loc = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<_LanguageOption>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LanguageSheet(
        currentCode: storage.getLanguagePreference() ?? 'en',
      ),
    );

    if (selected == null || !mounted) return;

    if (!selected.supported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.languageNotAvailable),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    final localeCode = selected.localeCode;
    context.read<LocaleBloc>().add(ChangeLocale(Locale(localeCode)));
    await storage.saveLanguagePreference(localeCode);
    await storage.setFirstLaunch(false);
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({
    required this.currentCode,
  });

  final String currentCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final options = <_LanguageOption>[
      _LanguageOption(label: loc.english, localeCode: 'en', supported: true),
      _LanguageOption(label: loc.urdu, localeCode: 'ur', supported: true),
      _LanguageOption(label: loc.arabic, localeCode: 'ar', supported: true),
    ];

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                loc.selectYourLanguage,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: options.map((option) {
                  final selected =
                      currentCode == option.localeCode && option.supported;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(option),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? (theme.brightness == Brightness.dark
                                    ? AppTheme.primaryGradient.colors.first
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFFFCEDE7))
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryGradient.colors.first
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            option.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppTheme.primaryGradient.colors.first
                                  : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                loc.languagePolicyNotice,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.label,
    required this.localeCode,
    required this.supported,
  });

  final String label;
  final String localeCode;
  final bool supported;
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Center(
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
