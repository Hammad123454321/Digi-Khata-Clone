import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/business/bloc/business_bloc.dart';
import '../../features/business/bloc/business_event.dart';
import '../../features/business/bloc/business_state.dart';
import '../../features/business/screens/create_business_screen.dart';
import '../models/business_model.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/di/injection.dart';
import '../../data/repositories/business_repository.dart';

/// Business Switcher Widget - Shows current business and allows switching
class BusinessSwitcher extends StatelessWidget {
  const BusinessSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, state) {
        if (state is BusinessLoaded) {
          final currentBusiness = state.businesses.firstWhere(
            (b) => b.id == state.currentBusinessId,
            orElse: () => state.businesses.first,
          );

          return PopupMenuButton<BusinessAction>(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.business,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    currentBusiness.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            onSelected: (action) => _handleAction(context, action, state),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: BusinessAction.switchBusiness,
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 20),
                    SizedBox(width: 8),
                    Text(loc.switchBusiness),
                  ],
                ),
              ),
              PopupMenuItem(
                value: BusinessAction.createBusiness,
                child: Row(
                  children: [
                    Icon(Icons.add_business, size: 20),
                    SizedBox(width: 8),
                    Text(loc.createNewBusiness),
                  ],
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _handleAction(
    BuildContext context,
    BusinessAction action,
    BusinessLoaded state,
  ) {
    switch (action) {
      case BusinessAction.switchBusiness:
        _showBusinessSelector(context, state);
        break;
      case BusinessAction.createBusiness:
        _navigateToCreateBusiness(context);
        break;
    }
  }

  void _showBusinessSelector(BuildContext context, BusinessLoaded state) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.selectBusiness),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.businesses.length,
            itemBuilder: (context, index) {
              final business = state.businesses[index];
              final isSelected = business.id == state.currentBusinessId;
              return ListTile(
                title: Text(business.name),
                subtitle: business.phone != null && business.phone!.isNotEmpty
                    ? Text(business.phone!)
                    : null,
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => _attemptSwitchBusiness(
                  context: context,
                  dialogContext: dialogContext,
                  state: state,
                  business: business,
                  isSelected: isSelected,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _attemptSwitchBusiness({
    required BuildContext context,
    required BuildContext dialogContext,
    required BusinessLoaded state,
    required BusinessModel business,
    required bool isSelected,
  }) async {
    if (isSelected) {
      Navigator.of(dialogContext).pop();
      return;
    }

    final repo = getIt<BusinessRepository>();
    final isOnline = await repo.isOnline();
    if (!isOnline) {
      if (context.mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.onlineRequired),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      Navigator.of(dialogContext).pop();
      return;
    }

    context.read<BusinessBloc>().add(SwitchBusiness(business.id));
    Navigator.of(dialogContext).pop();
  }

  void _navigateToCreateBusiness(BuildContext context) {
    final bloc = context.read<BusinessBloc>();
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const CreateBusinessScreen(),
        ),
      ),
    )
        .then((created) {
      if (created == true) {
        // Reload businesses after creation
        bloc.add(const LoadBusinesses());
      }
    });
  }
}

enum BusinessAction {
  switchBusiness,
  createBusiness,
}
