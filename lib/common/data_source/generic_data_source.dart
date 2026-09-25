import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../http/api_consumer.dart';
import '../http/either.dart';
import '../network/failure.dart';
import '../http/params.dart';
import '../resources/strings_manager.dart';

class GenericDataSource {
  final ApiConsumer _apiConsumer;

  GenericDataSource(this._apiConsumer);

  Future<Either<Failure, List<T>>> fetchData<T>({
    required String endpoint,
    PaginationParams? params,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final result = await _apiConsumer.get(
      endpoint,
      queryParameters: {
        if (params != null) ...params.toJson(),
        if (queryParameters != null) ...queryParameters,
      }..removeWhere((key, value) => value == null || value == ''),
      headers: headers,
      data: data,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          final items =
              (right['data'] as List).map((e) => fromJson(e)).toList();
          return Right(items);
        } catch (e, stackTrace) {
          log(stackTrace.toString());
          log(e.toString());
          return Left(Failure(0, AppStrings.unKnownError.tr()));
        }
      },
    );
  }

  Future<Either<Failure, T>> fetchResult<T>({
    required String endpoint,
    PaginationParams? params,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final result = await _apiConsumer.get(endpoint,
        data: data,
        queryParameters: {
          if (params != null) ...params.toJson(),
          if (queryParameters != null) ...queryParameters,
        },
        headers: headers);
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          return Right(fromJson!(right['data']));
        } catch (e, stackTrace) {
          log(stackTrace.toString());
          log(e.toString());
          return Left(Failure(0, e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, T>> postData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == String) {
            log('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          log(stackTrace.toString());
          log(e.toString());
          return Left(Failure(0, e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, T>> postFormData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.uploadFile(
      endpoint,
      formData: FormData.fromMap(data ?? {}),
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
      ),
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else if (T == String) {
            log('right: $right');
            return Right(right['message'] ?? "" as T);
          } else {
            return Right(right as T);
          }
        } catch (e, stackTrace) {
          log(stackTrace.toString());
          log(e.toString());
          return Left(Failure(0, e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, T>> deleteData<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.delete(
      endpoint,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else if (T == String) {
            log('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          log(stackTrace.toString());
          log(e.toString());
          return Left(Failure(0, e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, T>> patchData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.patch(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else if (T == String) {
            log('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          log(stackTrace.toString());
          log(e.toString());
          return Left(Failure(0, e.toString()));
        }
      },
    );
  }

  Future<Either<Failure, T>> updateData<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final result = await _apiConsumer.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    );
    return result.fold(
      (left) => Left(left),
      (right) {
        try {
          if (T == Null) {
            return Right(null as T);
          } else if (T == int) {
            return Right(right['id'] ?? 0 as T);
          } else if (T == String) {
            log('right: $right');
            return Right(right['redirect_url'] ?? "" as T);
          } else {
            return Right(null as T);
          }
        } catch (e, stackTrace) {
          log(stackTrace.toString());
          log(e.toString());
          return Left(Failure(0, e.toString()));
        }
      },
    );
  }
}
