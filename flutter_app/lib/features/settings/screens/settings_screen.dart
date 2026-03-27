import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/security/app_lock_service.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_queue.dart';
import '../../../core/localization/locale_bloc.dart';
import '../../../core/theme/theme_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../core/models/currency_model.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/repositories/backup_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import 'legal_screen.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

/// Settings Screen with app configuration options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppLockService _appLockService = getIt<AppLockService>();
  final LocalStorageService _localStorage = getIt<LocalStorageService>();
  final AnalyticsService _analytics = getIt<AnalyticsService>();
  final SyncService _syncService = getIt<SyncService>();
  final SyncQueue _syncQueue = getIt<SyncQueue>();
  final GlobalKey _securityKey = GlobalKey();
  final GlobalKey _appearanceKey = GlobalKey();
  final GlobalKey _dataKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  bool _isLockEnabled = false;
  bool _isBiometricEnabled = false;
  String _selectedLanguage = 'en';
  String _selectedTheme = 'system';
  String _selectedCurrency = 'PKR';
  int _pendingSyncOps = 0;
  int _failedSyncOps = 0;
  String? _lastSyncAt;
  bool _syncOnline = false;
  bool _isSyncBusy = false;
  bool _isBackupBusy = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final lockEnabled = await _appLockService.isLockEnabled();
    final biometricEnabled = await _appLockService.isBiometricEnabled();
    final language = _localStorage.getLanguagePreference() ?? 'en';
    final theme = _localStorage.getThemeMode() ?? 'system';
    final currency = _localStorage.getCurrencyPreference() ?? 'PKR';
    final syncHealth = await _syncService.getLocalSyncQueueHealth();

    setState(() {
      _isLockEnabled = lockEnabled;
      _isBiometricEnabled = biometricEnabled;
      _selectedLanguage = language;
      _selectedTheme = theme;
      _selectedCurrency = currency;
      _pendingSyncOps = syncHealth['pending_count'] as int? ?? 0;
      _failedSyncOps = syncHealth['failed_count'] as int? ?? 0;
      _lastSyncAt = syncHealth['last_sync_at'] as String?;
      _syncOnline = syncHealth['is_online'] as bool? ?? false;
      _isLoading = false;
    });
  }

  Future<void> _syncNow() async {
    final loc = AppLocalizations.of(context)!;
    if (_isSyncBusy) return;
    setState(() => _isSyncBusy = true);
    try {
      final result = await _syncService.performFullSync();
      await _loadSettings();
      if (!mounted) return;
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.synced),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result.failureOrNull?.message ?? loc.failedToLoadData),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncBusy = false);
      }
    }
  }

  Future<void> _retryFailedSync() async {
    final loc = AppLocalizations.of(context)!;
    if (_isSyncBusy) return;
    setState(() => _isSyncBusy = true);
    try {
      final retried = await _syncQueue.retryDeadLetters(limit: 200);
      final result = await _syncService.performFullSync();
      await _loadSettings();
      if (!mounted) return;

      final succeeded = result.isSuccess;
      final message = succeeded
          ? '${loc.retry}: $retried'
          : (result.failureOrNull?.message ?? loc.failedToLoadData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              succeeded ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncBusy = false);
      }
    }
  }

  Future<void> _toggleAppLock(bool value) async {
    final loc = AppLocalizations.of(context)!;
    if (value) {
      // Check if PIN is already set
      final hasPin = await _appLockService.hasPin();
      if (!hasPin) {
        // Show dialog to set PIN
        final pin = await _showSetPinDialog();
        if (pin == null || pin.length != 4) {
          return;
        }
        await _appLockService.setPin(pin);
      }
      await _appLockService.setLockEnabled(true);
      setState(() => _isLockEnabled = true);
      _analytics.trackEvent('app_lock_enabled');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.appLockEnabled),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      // Verify PIN before disabling - show PIN dialog
      final pin = await _showEnterPinDialog(loc.enterPinToDisableAppLock);
      if (pin == null) return;

      final authenticated = await _appLockService.authenticate(pin: pin);
      if (authenticated) {
        await _appLockService.setLockEnabled(false);
        setState(() {
          _isLockEnabled = false;
          _isBiometricEnabled = false; // Disable biometric if lock is disabled
        });
        _analytics.trackEvent('app_lock_disabled');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.appLockDisabled),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final loc = AppLocalizations.of(context)!;
    if (value) {
      // Check if biometric is available
      final isAvailable = await _appLockService.isBiometricAvailable();
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.biometricNotAvailable),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
        return;
      }

      // Authenticate to enable biometric
      final authenticated = await _appLockService.authenticateWithBiometric(
        reason: loc.enableBiometricAuthentication,
      );

      if (authenticated) {
        await _appLockService.setBiometricEnabled(true);
        setState(() => _isBiometricEnabled = true);
        _analytics.trackEvent('biometric_enabled');
      }
    } else {
      await _appLockService.setBiometricEnabled(false);
      setState(() => _isBiometricEnabled = false);
      _analytics.trackEvent('biometric_disabled');
    }
  }

  Future<String?> _showSetPinDialog() async {
    final loc = AppLocalizations.of(context)!;
    String? pin;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(loc.setPin),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: InputDecoration(
              labelText: loc.enterPin,
              hintText: loc.pinHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                pin = controller.text;
                Navigator.of(context).pop();
              },
              child: Text(loc.set),
            ),
          ],
        );
      },
    );
    return pin;
  }

  Future<String?> _showEnterPinDialog(String title) async {
    final loc = AppLocalizations.of(context)!;
    String? pin;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: InputDecoration(
              labelText: loc.enterPin,
              hintText: loc.pinHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                pin = controller.text;
                Navigator.of(context).pop();
              },
              child: Text(loc.verify),
            ),
          ],
        );
      },
    );
    return pin;
  }

  Future<void> _changeLanguage(String language) async {
    await _localStorage.saveLanguagePreference(language);
    setState(() => _selectedLanguage = language);
    _analytics
        .trackEvent('language_changed', parameters: {'language': language});

    final localeBloc = context.read<LocaleBloc>();
    Locale locale;
    switch (language) {
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
    localeBloc.add(ChangeLocale(locale));

    if (mounted) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.languageUpdated)),
      );
    }
  }

  Future<void> _changeTheme(String theme) async {
    await _localStorage.saveThemeMode(theme);
    setState(() => _selectedTheme = theme);
    _analytics.trackEvent('theme_changed', parameters: {'theme': theme});

    // Update theme mode in ThemeBloc
    final themeBloc = context.read<ThemeBloc>();
    ThemeMode themeMode;
    switch (theme) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        themeMode = ThemeMode.system;
        break;
    }
    themeBloc.add(ChangeTheme(themeMode));

    if (mounted) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.themeUpdated),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _changeCurrency(String currencyCode) async {
    await _localStorage.saveCurrencyPreference(currencyCode);
    setState(() => _selectedCurrency = currencyCode);
    CurrencyUtils.clearCache(); // Clear cached formatter
    _analytics
        .trackEvent('currency_changed', parameters: {'currency': currencyCode});

    if (mounted) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.currencyUpdated),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.clearCache),
        content: Text(loc.clearCacheMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(loc.clear),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Clear cache logic would go here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.cacheClearedSuccessfully),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _analytics.trackEvent('cache_cleared');
    }
  }

  Future<void> _exportData() async {
    if (_isBackupBusy) return;
    final loc = AppLocalizations.of(context)!;
    setState(() => _isBackupBusy = true);
    try {
      final backupRepository = getIt<BackupRepository>();
      final backupResult = await backupRepository.createBackup();
      switch (backupResult) {
        case FailureResult(:final failure):
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message ?? loc.failedToLoadData),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        case Success(:final data):
          final downloadResult = await backupRepository.downloadBackup(data.id);
          switch (downloadResult) {
            case FailureResult(:final failure):
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message ?? loc.failedToLoadData),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            case Success(data: final file):
              await Share.shareXFiles(
                [
                  XFile(
                    file.path,
                    mimeType: 'application/json',
                  ),
                ],
                text: 'Digi Khata backup export',
                subject: 'Digi Khata Backup',
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.success),
                  backgroundColor: AppTheme.successColor,
                ),
              );
          }
      }
      await _loadSettings();
    } finally {
      if (mounted) {
        setState(() => _isBackupBusy = false);
      }
      _analytics.trackEvent('export_data_requested');
    }
  }

  Future<void> _restoreBackup() async {
    if (_isBackupBusy) return;
    final loc = AppLocalizations.of(context)!;
    setState(() => _isBackupBusy = true);
    try {
      final backupRepository = getIt<BackupRepository>();
      final backupsResult = await backupRepository.listBackups();
      switch (backupsResult) {
        case FailureResult(:final failure):
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message ?? loc.failedToLoadData),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        case Success(:final data):
          final completedBackups =
              data.where((backup) => backup.isCompleted).toList();
          if (completedBackups.isEmpty) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No completed backups found.'),
              ),
            );
            return;
          }

          final selectedBackup = await _pickBackupToRestore(completedBackups);
          if (selectedBackup == null || !mounted) {
            return;
          }

          final shouldRestore = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Restore backup'),
              content: const Text(
                'This will replace local business data with selected backup. Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(loc.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Restore'),
                ),
              ],
            ),
          );

          if (shouldRestore != true) {
            return;
          }

          final restoreResult =
              await backupRepository.restoreBackup(selectedBackup.id);
          if (!mounted) return;
          switch (restoreResult) {
            case FailureResult(:final failure):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message ?? loc.failedToLoadData),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            case Success():
              await _loadSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.success),
                  backgroundColor: AppTheme.successColor,
                ),
              );
          }
      }
    } finally {
      if (mounted) {
        setState(() => _isBackupBusy = false);
      }
      _analytics.trackEvent('restore_data_requested');
    }
  }

  Future<BackupModel?> _pickBackupToRestore(
    List<BackupModel> backups,
  ) async {
    if (!mounted) return null;
    return showModalBottomSheet<BackupModel>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select backup',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 360,
                  child: ListView.builder(
                    itemCount: backups.length,
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      final date = backup.backupDate.toLocal();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.backup_outlined),
                        title: Text(
                          'Backup ${index + 1}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        ),
                        onTap: () => Navigator.of(sheetContext).pop(backup),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  String _languageLabel(AppLocalizations loc) {
    return _selectedLanguage == 'en'
        ? loc.english
        : _selectedLanguage == 'ur'
            ? loc.urdu
            : loc.arabic;
  }

  String _themeLabel(AppLocalizations loc) {
    return _selectedTheme == 'light'
        ? loc.light
        : _selectedTheme == 'dark'
            ? loc.dark
            : loc.system;
  }

  String _currencyLabel() {
    final currency = CurrencyModel.getByCode(_selectedCurrency) ??
        CurrencyModel.getDefault();
    return '${currency.symbol} ${currency.getName(_selectedLanguage)}';
  }

  Future<void> _confirmLogout() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(loc.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(const LogoutEvent());
    }
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, AppLocalizations loc) {
    return AppBar(
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.settings,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            loc.appName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(theme, loc),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(theme, loc),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.settings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.languageSettings,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SettingsMiniStat(
                          label: loc.security,
                          value: _isLockEnabled ? loc.active : loc.inactive,
                          color: _isLockEnabled
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SettingsMiniStat(
                          label: loc.language,
                          value: _languageLabel(loc),
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SettingsMiniStat(
                          label: loc.theme,
                          value: _themeLabel(loc),
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SettingsMiniStat(
                          label: loc.currency,
                          value: _currencyLabel(),
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuickActionButton(
                    icon: Icons.security,
                    label: loc.security,
                    onTap: () => _scrollTo(_securityKey),
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.palette,
                    label: loc.appearance,
                    onTap: () => _scrollTo(_appearanceKey),
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.storage,
                    label: loc.dataManagement,
                    onTap: () => _scrollTo(_dataKey),
                  ),
                  const SizedBox(width: 12),
                  QuickActionButton(
                    icon: Icons.info_outline,
                    label: loc.about,
                    onTap: () => _scrollTo(_aboutKey),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            key: _securityKey,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.security,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(loc.appLock),
                        subtitle: Text(loc.requirePinToUnlock),
                        value: _isLockEnabled,
                        onChanged: _toggleAppLock,
                      ),
                      if (_isLockEnabled) const Divider(height: 1),
                      if (_isLockEnabled)
                        SwitchListTile(
                          title: Text(loc.biometricAuthentication),
                          subtitle: Text(loc.useFingerprintOrFaceId),
                          value: _isBiometricEnabled,
                          onChanged: _toggleBiometric,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            key: _appearanceKey,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.appearance,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(loc.language),
                        subtitle: Text(_languageLabel(loc)),
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            items: [
                              DropdownMenuItem(
                                  value: 'en', child: Text(loc.english)),
                              DropdownMenuItem(
                                  value: 'ur', child: Text(loc.urdu)),
                              DropdownMenuItem(
                                  value: 'ar', child: Text(loc.arabic)),
                            ],
                            onChanged: (value) {
                              if (value != null) _changeLanguage(value);
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(loc.theme),
                        subtitle: Text(_themeLabel(loc)),
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTheme,
                            items: [
                              DropdownMenuItem(
                                  value: 'system', child: Text(loc.system)),
                              DropdownMenuItem(
                                  value: 'light', child: Text(loc.light)),
                              DropdownMenuItem(
                                  value: 'dark', child: Text(loc.dark)),
                            ],
                            onChanged: (value) {
                              if (value != null) _changeTheme(value);
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(loc.currency),
                        subtitle: Text(_currencyLabel()),
                        trailing: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            items: CurrencyModel.supportedCurrencies
                                .map((currency) {
                              return DropdownMenuItem<String>(
                                value: currency.code,
                                child: Text(
                                  '${currency.symbol} ${currency.getName(_selectedLanguage)}',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) _changeCurrency(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            key: _dataKey,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.dataManagement,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ModernListTile(
                  icon: Icons.cached,
                  title: loc.clearCache,
                  subtitle: loc.clearCachedDataAndImages,
                  onTap: _clearCache,
                ),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.syncStatus,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _SyncPill(
                            label: loc.pending,
                            value: '$_pendingSyncOps',
                            color: AppTheme.warningColor,
                          ),
                          _SyncPill(
                            label: loc.failed,
                            value: '$_failedSyncOps',
                            color: AppTheme.errorColor,
                          ),
                          _SyncPill(
                            label: _syncOnline ? loc.synced : loc.offline,
                            value: _syncOnline ? 'online' : 'offline',
                            color: _syncOnline
                                ? AppTheme.successColor
                                : theme.colorScheme.outline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${loc.lastSync}: ${_lastSyncAt ?? '-'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isSyncBusy ? null : _syncNow,
                              icon: const Icon(Icons.sync),
                              label: Text(loc.syncNow),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isSyncBusy || _failedSyncOps == 0
                                  ? null
                                  : _retryFailedSync,
                              icon: const Icon(Icons.replay),
                              label: Text(loc.retryFailed),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ModernListTile(
                  icon: Icons.download,
                  title: loc.exportData,
                  subtitle: loc.exportBusinessData,
                  onTap: _isBackupBusy ? null : _exportData,
                ),
                ModernListTile(
                  icon: Icons.restore,
                  title: 'Restore Backup',
                  subtitle: 'Restore business data from a saved backup',
                  onTap: _isBackupBusy ? null : _restoreBackup,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            key: _aboutKey,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.about,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ModernListTile(
                  icon: Icons.info_outline,
                  title: loc.appVersion,
                  subtitle: '1.0.0',
                ),
                ModernListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: loc.privacyPolicy,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LegalScreen(initialTabIndex: 0),
                    ),
                  ),
                ),
                ModernListTile(
                  icon: Icons.description_outlined,
                  title: loc.termsOfService,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LegalScreen(initialTabIndex: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return ElevatedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout),
                  label: Text(loc.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: theme.colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMiniStat extends StatelessWidget {
  const _SettingsMiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncPill extends StatelessWidget {
  const _SyncPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
