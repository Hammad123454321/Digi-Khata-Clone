import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';
import '../bloc/business_state.dart';
import '../../../core/localization/locale_bloc.dart';
import 'create_business_screen.dart';
import '../../../core/navigation/app_lock_wrapper.dart';
import '../../../shared/widgets/error_widget.dart';

class BusinessBootstrapScreen extends StatefulWidget {
  const BusinessBootstrapScreen({super.key});

  @override
  State<BusinessBootstrapScreen> createState() =>
      _BusinessBootstrapScreenState();
}

class _BusinessBootstrapScreenState extends State<BusinessBootstrapScreen> {
  bool _navigationInProgress = false;

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(const LoadBusinesses());
  }

  Future<void> _navigateToCreateBusiness(BusinessBloc bloc) async {
    if (_navigationInProgress || !mounted) return;
    _navigationInProgress = true;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const CreateBusinessScreen(),
        ),
      ),
    );

    if (!mounted) return;
    _navigationInProgress = false;

    if (result == true) {
      bloc.add(const LoadBusinesses());
    }
  }

  void _navigateToHome(BusinessBloc bloc, BusinessLoaded state) {
    if (_navigationInProgress || !mounted) return;
    _navigationInProgress = true;

    final business = state.currentBusiness;
    if (business?.languagePreference != null) {
      context.read<LocaleBloc>().add(
            ChangeLocale(Locale(business!.languagePreference!)),
          );
    }

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const AppLockWrapper(),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BusinessBloc, BusinessState>(
        listenWhen: (previous, current) => current is BusinessLoaded,
        listener: (context, state) async {
          if (!mounted || _navigationInProgress) return;

          if (state is BusinessLoaded) {
            final bloc = context.read<BusinessBloc>();

            if (state.businesses.isEmpty) {
              await _navigateToCreateBusiness(bloc);
              return;
            }

            if (state.currentBusinessId == null) {
              bloc.add(SetCurrentBusiness(state.businesses.first.id));
              return;
            }

            _navigateToHome(bloc, state);
          }
        },
        builder: (context, state) {
          if (state is BusinessError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<BusinessBloc>().add(const LoadBusinesses()),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
