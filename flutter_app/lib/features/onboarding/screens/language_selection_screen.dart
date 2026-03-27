import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/routes/app_router.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/theme/app_theme.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedCode = 'en';

  @override
  void initState() {
    super.initState();
    final storage = getIt<LocalStorageService>();
    _selectedCode = storage.getLanguagePreference() ?? 'en';
  }

  void _onSelect(String code) {
    setState(() => _selectedCode = code);
  }

  Future<void> _onContinue() async {
    final localeBloc = context.read<LocaleBloc>();
    Locale locale;
    switch (_selectedCode) {
      case 'ur':
        locale = const Locale('ur', '');
        break;
      case 'ar':
        locale = const Locale('ar', '');
        break;
      case 'en':
      default:
        locale = const Locale('en', '');
    }

    // Persist and update locale via BLoC
    final storage = getIt<LocalStorageService>();
    await storage.saveLanguagePreference(_selectedCode);
    await storage.setFirstLaunch(false);
    localeBloc.add(ChangeLocale(locale));

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.root,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.selectLanguage,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.languageSettings,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              children: [
                _LanguageOptionCard(
                  code: 'en',
                  title: loc.english,
                  subtitle: 'English',
                  selected: _selectedCode == 'en',
                  onTap: () => _onSelect('en'),
                ),
                const SizedBox(height: 12),
                _LanguageOptionCard(
                  code: 'ur',
                  title: loc.urdu,
                  subtitle: 'اردو',
                  selected: _selectedCode == 'ur',
                  onTap: () => _onSelect('ur'),
                ),
                const SizedBox(height: 12),
                _LanguageOptionCard(
                  code: 'ar',
                  title: loc.arabic,
                  subtitle: 'العربية',
                  selected: _selectedCode == 'ar',
                  onTap: () => _onSelect('ar'),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppButton(
                onPressed: _onContinue,
                label: loc.save,
                icon: Icons.check,
                isFullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: selected ? theme.colorScheme.primary : null,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              code.toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceVariant,
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: selected ? Colors.white : theme.colorScheme.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
