import 'package:equatable/equatable.dart';

import '../../../shared/models/business_model.dart';

/// Business States
abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => [];
}

class BusinessInitial extends BusinessState {
  const BusinessInitial();
}

class BusinessLoading extends BusinessState {
  const BusinessLoading();
}

class BusinessLoaded extends BusinessState {
  const BusinessLoaded({
    required this.businesses,
    required this.currentBusinessId,
  });

  final List<BusinessModel> businesses;
  final String? currentBusinessId;

  BusinessModel? get currentBusiness {
    if (currentBusinessId == null || businesses.isEmpty) return null;
    try {
      return businesses.firstWhere((b) => b.id == currentBusinessId);
    } catch (e) {
      return businesses.first;
    }
  }

  BusinessLoaded copyWith({
    List<BusinessModel>? businesses,
    String? currentBusinessId,
  }) {
    return BusinessLoaded(
      businesses: businesses ?? this.businesses,
      currentBusinessId: currentBusinessId ?? this.currentBusinessId,
    );
  }

  @override
  List<Object?> get props => [businesses, currentBusinessId];
}

class BusinessError extends BusinessState {
  const BusinessError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
