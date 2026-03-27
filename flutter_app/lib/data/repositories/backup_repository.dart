import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';

class BackupModel {
  const BackupModel({
    required this.id,
    required this.backupType,
    required this.status,
    required this.backupDate,
    this.filePath,
    this.fileSize,
    this.errorMessage,
  });

  final String id;
  final String backupType;
  final String status;
  final DateTime backupDate;
  final String? filePath;
  final String? fileSize;
  final String? errorMessage;

  bool get isCompleted => status == 'completed';

  factory BackupModel.fromJson(Map<String, dynamic> json) {
    return BackupModel(
      id: json['id']?.toString() ?? '',
      backupType: json['backup_type']?.toString() ?? 'manual',
      status: json['status']?.toString() ?? 'failed',
      backupDate: DateTime.tryParse(json['backup_date']?.toString() ?? '') ??
          DateTime.now(),
      filePath: json['file_path']?.toString(),
      fileSize: json['file_size']?.toString(),
      errorMessage: json['error_message']?.toString(),
    );
  }
}

class BackupRepository {
  BackupRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<BackupModel>> createBackup() async {
    try {
      final response = await _apiClient.post(
        ApiConstants.backups,
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return Result.success(BackupModel.fromJson(data));
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Result<List<BackupModel>>> listBackups() async {
    try {
      final response = await _apiClient.get(ApiConstants.backups);
      final list = (response.data as List<dynamic>)
          .map(
            (entry) => BackupModel.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList();
      return Result.success(list);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Result<void>> restoreBackup(String backupId) async {
    try {
      await _apiClient.post('${ApiConstants.backups}/$backupId/restore');
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
  }

  Future<Result<File>> downloadBackup(String backupId) async {
    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'digikhata_backup_$timestamp.json';
      final savePath = p.join(dir.path, fileName);
      await _apiClient.download(
        '${ApiConstants.backups}/$backupId/download',
        savePath,
      );
      return Result.success(File(savePath));
    } on AppException catch (e) {
      return Result.failure(_mapExceptionToFailure(e));
    }
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
      _ => UnknownFailure(exception.message),
    };
  }
}
