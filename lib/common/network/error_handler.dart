import 'package:micro_teaching_studio/common/network/failure.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:dio/dio.dart';

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      failure = _handleError(error);
    } else {
      failure = DataSource.unKnown.getFailure();
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return DataSource.connectionTimeout.getFailure();
      case DioExceptionType.sendTimeout:
        return DataSource.sendTimeout.getFailure();
      case DioExceptionType.receiveTimeout:
        return DataSource.receiveTimeout.getFailure();
      case DioExceptionType.badCertificate:
        return DataSource.badCertificate.getFailure();
      case DioExceptionType.badResponse:
        if (error.response != null &&
            error.response?.statusMessage != null &&
            error.response?.statusCode != null) {
          return Failure(
              0, error.response?.statusMessage ?? AppStrings.unKnownError);
        } else {
          return DataSource.unKnown.getFailure();
        }
      case DioExceptionType.cancel:
        return DataSource.cancel.getFailure();
      case DioExceptionType.connectionError:
        return DataSource.connectionError.getFailure();
      case DioExceptionType.unknown:
        return DataSource.unKnown.getFailure();
    }
  }
}

enum DataSource {
  connectionTimeout,
  receiveTimeout,
  sendTimeout,
  badCertificate,
  connectionError,
  cancel,
  cacheError,
  noInternetConnection,
  unKnown,
}

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.connectionTimeout:
        return Failure(0, ResponseMessage.connectionTimeout);
      case DataSource.cancel:
        return Failure(0, ResponseMessage.cancel);
      case DataSource.receiveTimeout:
        return Failure(0, ResponseMessage.receiveTimeout);
      case DataSource.sendTimeout:
        return Failure(0, ResponseMessage.sendTimeout);
      case DataSource.cacheError:
        return Failure(0, ResponseMessage.cacheError);
      case DataSource.noInternetConnection:
        return Failure(0, ResponseMessage.noInternetConnection);
      case DataSource.unKnown:
        return Failure(0, ResponseMessage.unKnown);
      case DataSource.badCertificate:
        return Failure(0, ResponseMessage.badCertificate);
      case DataSource.connectionError:
        return Failure(0, ResponseMessage.badCertificate);
    }
  }
}

class ResponseMessage {
  static const String connectionTimeout = AppStrings.timeoutError;
  static const String cancel = AppStrings.requestCanceled;
  static const String receiveTimeout = AppStrings.timeoutError;
  static const String sendTimeout = AppStrings.timeoutError;
  static const String cacheError = AppStrings.cacheError;
  static const String noInternetConnection = AppStrings.noInternetError;
  static const String unKnown = AppStrings.unKnownError;
  static const String badCertificate = AppStrings.badCertificate;
  static const String connectionError = AppStrings.connectionError;
}
