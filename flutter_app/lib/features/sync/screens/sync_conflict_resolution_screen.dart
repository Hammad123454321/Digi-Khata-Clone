import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../core/localization/app_localizations.dart';

/// Model for sync conflict
class SyncConflictModel {
  const SyncConflictModel({
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
    required this.clientVersion,
    required this.serverData,
    required this.clientData,
  });

  final String entityType;
  final int entityId;
  final DateTime serverVersion;
  final DateTime clientVersion;
  final Map<String, dynamic> serverData;
  final Map<String, dynamic> clientData;
}

class SyncConflictResolutionScreen extends StatefulWidget {
  const SyncConflictResolutionScreen({
    super.key,
    required this.conflicts,
  });

  final List<SyncConflictModel> conflicts;

  @override
  State<SyncConflictResolutionScreen> createState() =>
      _SyncConflictResolutionScreenState();
}

class _SyncConflictResolutionScreenState
    extends State<SyncConflictResolutionScreen> {
  final SyncService _syncService = getIt<SyncService>();
  bool _isResolving = false;
  String? _error;
  final Map<int, String> _resolutions = {}; // entityId -> resolution

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode).add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.resolveSyncConflicts),
      ),
      body: LoadingOverlay(
        isLoading: _isResolving,
        child: _error != null
            ? AppErrorWidget(
                message: _error!,
                onRetry: () {
                  setState(() => _error = null);
                },
              )
            : Column(
                children: [
                  // Info Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: theme.colorScheme.primaryContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc.syncConflictsDetected,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.syncConflictsDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Conflicts List
                  Expanded(
                    child: widget.conflicts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 64,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  loc.noConflictsToResolve,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: widget.conflicts.length,
                            itemBuilder: (context, index) {
                              final conflict = widget.conflicts[index];
                              return _ConflictCard(
                                conflict: conflict,
                                resolution: _resolutions[conflict.entityId],
                                dateFormatter: dateFormatter,
                                onResolutionChanged: (resolution) {
                                  setState(() {
                                    _resolutions[conflict.entityId] =
                                        resolution;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  // Resolve Button
                  if (widget.conflicts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: AppButton(
                          onPressed: _canResolve() ? _resolveConflicts : null,
                          label: loc.resolveAllConflicts,
                          icon: Icons.check,
                          isLoading: _isResolving,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  bool _canResolve() {
    return widget.conflicts.every(
      (conflict) => _resolutions.containsKey(conflict.entityId),
    );
  }

  Future<void> _resolveConflicts() async {
    setState(() {
      _isResolving = true;
      _error = null;
    });

    try {
      // Prepare resolution data
      final resolutions = widget.conflicts.map((conflict) {
        return {
          'entity_type': conflict.entityType,
          'entity_id': conflict.entityId,
          'resolution': _resolutions[conflict.entityId],
        };
      }).toList();

      final result = await _syncService.resolveConflicts(
        resolutions: resolutions,
      );
      if (result.isFailure) {
        throw Exception(
            result.failureOrNull?.message ?? 'Conflict resolution failed');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.allConflictsResolvedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResolving = false;
          _error = AppLocalizations.of(context)!
              .failedToResolveConflicts
              .replaceAll('{error}', e.toString());
        });
      }
    }
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.resolution,
    required this.dateFormatter,
    required this.onResolutionChanged,
  });

  final SyncConflictModel conflict;
  final String? resolution;
  final DateFormat dateFormatter;
  final ValueChanged<String> onResolutionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entity Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  conflict.entityType.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                loc.idLabel.replaceAll('{id}', conflict.entityId.toString()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Server Version
          _VersionCard(
            title: loc.serverVersion,
            date: conflict.serverVersion,
            data: conflict.serverData,
            dateFormatter: dateFormatter,
            isSelected: resolution == 'server',
            onTap: () => onResolutionChanged('server'),
          ),
          const SizedBox(height: 12),
          // Client Version
          _VersionCard(
            title: loc.yourVersion,
            date: conflict.clientVersion,
            data: conflict.clientData,
            dateFormatter: dateFormatter,
            isSelected: resolution == 'client',
            onTap: () => onResolutionChanged('client'),
          ),
        ],
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.title,
    required this.date,
    required this.data,
    required this.dateFormatter,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final DateTime date;
  final Map<String, dynamic> data;
  final DateFormat dateFormatter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: isSelected ? title : null,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.updated}: ${dateFormatter.format(date)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (data.containsKey('name'))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        data['name'] as String? ?? '',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
