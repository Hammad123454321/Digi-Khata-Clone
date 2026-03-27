import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/storage_constants.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/database/app_database.dart';
import '../../shared/models/business_model.dart';

/// Business Repository
class BusinessRepository {
  BusinessRepository({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required AppDatabase appDatabase,
    Connectivity? connectivity,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage,
        _localStorage = localStorage,
        _appDatabase = appDatabase,
        _connectivity = connectivity ?? Connectivity();

  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final AppDatabase _appDatabase;
  final Connectivity _connectivity;

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get businesses for current user
  Future<Result<List<BusinessModel>>> getBusinesses() async {
    try {
      final cached = await _getCachedBusiness();
      final online = await isOnline();
      final refreshToken = await _secureStorage.getRefreshToken();
      if (cached != null && !online) {
        return Result.success([cached]);
      }
      if (online && (refreshToken == null || refreshToken.isEmpty)) {
        return const Result.failure(
          AuthenticationFailure('Session expired. Please sign in again.'),
        );
      }

      final response = await _apiClient.get(ApiConstants.businesses);

      final businesses = (response.data as List<dynamic>)
          .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _cacheSelectedBusinessIfAvailable(businesses);
      return Result.success(businesses);
    } on AppException catch (e) {
      if (e is NetworkException || e is TimeoutException) {
        final cached = await _getCachedBusiness();
        if (cached != null) {
          return Result.success([cached]);
        }
      }
      if (e is AuthenticationException || e is AuthorizationException) {
        final online = await isOnline();
        if (!online) {
          final cached = await _getCachedBusiness();
          if (cached != null) {
            return Result.success([cached]);
          }
        }
      }
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Create a new business
  Future<Result<BusinessModel>> createBusiness({
    required String name,
    required String phone,
    String? ownerName,
    String? email,
    String? address,
    String? area,
    String? city,
    String? businessCategory,
    required String businessType,
    String? customBusinessType,
    String? languagePreference,
    int maxDevices = 3,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.businesses,
        data: {
          'name': name,
          'phone': phone,
          if (ownerName != null && ownerName.isNotEmpty)
            'owner_name': ownerName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (address != null && address.isNotEmpty) 'address': address,
          if (area != null && area.isNotEmpty) 'area': area,
          if (city != null && city.isNotEmpty) 'city': city,
          if (businessCategory != null && businessCategory.isNotEmpty)
            'business_category': businessCategory,
          'business_type': businessType,
          if (customBusinessType != null && customBusinessType.isNotEmpty)
            'custom_business_type': customBusinessType,
          if (languagePreference != null)
            'language_preference': languagePreference,
          'max_devices': maxDevices,
        },
      );

      final business = BusinessModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return Result.success(business);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Get business by ID
  Future<Result<BusinessModel>> getBusiness(String businessId) async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.businesses}/$businessId');
      final business = BusinessModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(business);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Update business
  Future<Result<BusinessModel>> updateBusiness({
    required String businessId,
    String? name,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? area,
    String? city,
    String? businessCategory,
    String? businessType,
    String? customBusinessType,
    String? languagePreference,
    int? maxDevices,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (ownerName != null) data['owner_name'] = ownerName;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (address != null) data['address'] = address;
      if (area != null) data['area'] = area;
      if (city != null) data['city'] = city;
      if (businessCategory != null) {
        data['business_category'] = businessCategory;
      }
      if (businessType != null) data['business_type'] = businessType;
      if (customBusinessType != null)
        data['custom_business_type'] = customBusinessType;
      if (languagePreference != null)
        data['language_preference'] = languagePreference;
      if (maxDevices != null) data['max_devices'] = maxDevices;

      final response = await _apiClient.patch(
        '${ApiConstants.businesses}/$businessId',
        data: data,
      );

      final business = BusinessModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(business);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Set default business
  Future<Result<void>> setDefaultBusiness(String businessId) async {
    try {
      await _apiClient
          .post('${ApiConstants.businesses}/$businessId/set-default');
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  /// Persist / read current business ID in secure storage
  Future<String?> getCurrentBusinessId() => _secureStorage.getBusinessId();

  Future<void> setCurrentBusinessId(String id) async {
    final previousBusinessId = await _secureStorage.getBusinessId();
    if (previousBusinessId != null &&
        previousBusinessId.isNotEmpty &&
        previousBusinessId != id) {
      await _appDatabase.clearAllData();
      final userId = _localStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        await _secureStorage.deleteScopedSyncCursor(
          userId: userId,
          businessId: previousBusinessId,
        );
        await _localStorage.remove(
          '${StorageConstants.lastSyncAtScopedPrefix}_${userId}_$previousBusinessId',
        );
      }
      await _localStorage.remove(StorageConstants.lastSyncAt);
    }

    await _secureStorage.saveBusinessId(id);
    await _localStorage.saveSelectedBusinessId(id);
  }

  Future<void> cacheSelectedBusiness({
    required String id,
    required String name,
  }) async {
    await _localStorage.saveSelectedBusinessId(id);
    await _localStorage.saveBusinessName(name);
  }

  Future<BusinessModel?> _getCachedBusiness() async {
    final selectedId = _localStorage.getSelectedBusinessId();
    final securedId = await _secureStorage.getBusinessId();
    final id = selectedId ?? securedId;
    if (id == null || id.isEmpty) return null;

    final name = _localStorage.getBusinessName();
    return BusinessModel(
      id: id,
      name: (name == null || name.trim().isEmpty) ? 'Business' : name,
      isActive: true,
    );
  }

  Future<void> _cacheSelectedBusinessIfAvailable(
    List<BusinessModel> businesses,
  ) async {
    if (businesses.isEmpty) return;
    final currentId = await _secureStorage.getBusinessId();
    final selected = currentId == null
        ? businesses.first
        : businesses.firstWhere(
            (b) => b.id == currentId,
            orElse: () => businesses.first,
          );
    await cacheSelectedBusiness(id: selected.id, name: selected.name);
  }

  Failure _mapExceptionToFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => NetworkFailure(exception.message),
      ServerException() => ServerFailure(exception.message),
      TimeoutException() => TimeoutFailure(exception.message),
      ValidationException() => ValidationFailure(
          exception.message,
          exception.errors,
        ),
      AuthenticationException() => AuthenticationFailure(exception.message),
      AuthorizationException() => AuthorizationFailure(exception.message),
      _ => UnknownFailure(exception.message),
    };
  }
}
