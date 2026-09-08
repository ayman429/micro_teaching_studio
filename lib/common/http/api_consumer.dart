import 'dart:convert';
import 'dart:developer';

import 'package:micro_teaching_studio/app/app.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/app/imports.dart';
import 'package:micro_teaching_studio/common/extensions/context_extension.dart';
import 'package:micro_teaching_studio/common/resources/app_router.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'either.dart';
import '../network/failure.dart';

abstract final class ApiConsumer {
  Future<Either<Failure, Map<String, dynamic>>> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? isFormData,
  });

  Future<Either<Failure, Map<String, dynamic>>> patch(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Either<Failure, Map<String, dynamic>>> delete(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String url, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  void addInterceptor(Interceptor interceptor);

  void removeAllInterceptors();

  void updateHeader(Map<String, dynamic> headers);

  Future<Either<Failure, Map<String, dynamic>>> retryApiCall(
    Future<Either<Failure, Map<String, dynamic>>> Function() apiCall, {
    int retryCount = 0,
  });
}

final class BaseApiConsumer implements ApiConsumer {
  final Dio _dio;
  final int maxRetries;
  final Duration retryDelay;

  BaseApiConsumer({
    required Dio dio,
    int maxRetries = 0,
    Duration retryDelay = const Duration(seconds: 2),
  })  : _dio = dio,
        maxRetries = 0,
        retryDelay = const Duration(seconds: 2) {
    // Logging
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      enabled: true,
      logPrint: (object) => log(object.toString()),
    ));
    final AppPreferences appPreferences = instance<AppPreferences>();

    _dio.options.headers['Accept-Language'] = appPreferences.getAppLanguage();
    // final AppPreferences appPreferences = instance<AppPreferences>();

    // 🔹 هنا نضيف Interceptor لموضوع الـ token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, handler) async {
          if ((err.response?.statusCode == 401 ||
                  err.response?.statusCode == 403) &&
              !appPreferences.isGestMode()) {
            // امسح التوكن

            await appPreferences.logout();
            await instance.reset();
            await initAppModule();

            // إعادة التوجيه
            final ctx = navigatorKey.currentContext;
            if (ctx != null) {
              Future.microtask(() {
                GoRouter.of(ctx).go(AppRouters.root);
              });
            }
            return;
          }
          return handler.next(err);
        },
      ),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> retryApiCall(
    Future<Either<Failure, Map<String, dynamic>>> Function() apiCall, {
    int retryCount = 2,
  }) async {
    final result = await apiCall();
    return result.fold((failure) async {
      if (retryCount < maxRetries) {
        log("API failed, retrying attempt #${retryCount + 1}");
        await Future.delayed(retryDelay);
        return retryApiCall(apiCall, retryCount: retryCount + 1); //recursion
      } else {
        log("Max retries reached, API failed: ${failure.message}");
        return Left(failure);
      }
    }, (success) => Right(success));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    apiCall() async {
      try {
        final response = await _dio.get(
          url,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
          data: data,
          onReceiveProgress: onReceiveProgress,
        );
        return Right<Failure, Map<String, dynamic>>(
            response.data as Map<String, dynamic>);
      } on DioException catch (e) {
        log(e.toString());
        final failure = _handleDioError(e);
        return Left<Failure, Map<String, dynamic>>(failure);
      } catch (e) {
        return Left<Failure, Map<String, dynamic>>(
          Failure(0, 'An unexpected error occurred: $e'),
        );
      }
    }

    return await retryApiCall(apiCall);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> patch(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.patch(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        data: data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log(e.toString());
      final failure = _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(Failure(0, 'An unexpected error occurred${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? isFormData,
  }) async {
    try {
      Response response = await _dio.post(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        data: (isFormData ?? false) ? formData : data,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final failure = _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(Failure(0, 'An unexpected error occurred${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.put(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
        data: data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log(e.toString());
      final failure = _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(Failure(0, 'An unexpected error occurred${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> delete(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        data: data,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );

      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log(e.toString());
      final failure = _handleDioError(e);
      return Left(failure);
    } catch (e) {
      return Left(Failure(0, 'An unexpected error occurred${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      // Return the file path after successful download
      return Right(savePath);
    } on DioException catch (e) {
      log(e.toString());
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(Failure(0, 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadFile(
    String url, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      Response response = await _dio.post(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      log(e.toString());
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(Failure(0, 'An unexpected error occurred${e.toString()}'));
    }
  }

  @override
  void removeAllInterceptors() {
    _dio.options.headers.clear();
  }

  @override
  void updateHeader(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  @override
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        // scaffoldMessengerKey.currentContext!.showToast(text: 'تم الغاء الطلب ');
        return Failure(0, 'تم إلغاء الطلب ');
      case DioExceptionType.connectionTimeout:
        // scaffoldMessengerKey.currentContext!.showToast(text: 'انتهت مهلة الاتصال ');
        return Failure(0, 'انتهت مهلة الاتصال ');
      case DioExceptionType.receiveTimeout:
        // scaffoldMessengerKey.currentContext!.showToast(text: 'انتهت مهلة الاتصال ');
        return Failure(0, 'انتهت مهلة الاستقبال في الاتصال ');
      case DioExceptionType.sendTimeout:
        // scaffoldMessengerKey.currentContext!.showToast(text: 'انتهت مهلة الاتصال ');
        return Failure(0, 'انتهت مهلة الإرسال في الاتصال ');
      case DioExceptionType.badResponse: //400-500
        if (error.response?.data != null) {
          try {
            final data = error.response!.data;
            final Map<String, dynamic> decoded =
                data is String ? json.decode(data) : data;
            if (error.response?.statusCode == 503) {
              return Failure(0, 'network failure ${error.message}');
            }
            if (error.response?.statusCode == 401) {
              // if(instance<AppPreferences>().getToken().isNotEmpty)  instance<AppPreferences>().logout();
              //   scaffoldMessengerKey.currentContext?.go(const LoginView());

              return Failure(
                  0, error.response?.data['message'] ?? 'غير مصرح لك');
            }
            if (error.response?.statusCode == 413) {
              scaffoldMessengerKey.currentContext!
                  .showToast(text: 'File size is too large');

              return Failure(0, 'File size is too large');
            }
            if (error.response?.statusCode == 410) {
              scaffoldMessengerKey.currentContext!
                  .showToast(text: 'لقد تعرضت للحظر ');
              // scaffoldMessengerKey.currentContext!.goWithNoReturn(const LoginScreen());

              return Failure(0, 'لقد تعرضت للحظر ');
            }
            // Handle OTP failure for 409 status code
            if (error.response?.statusCode == 409) {
              log('VERIFYERROR');
              return Failure(0, 'خطأ في التحقق من الكود');
            }
            if (error.response?.statusCode == 415) {
              return Failure(0, error.response?.data['message']);
            }
            if (decoded.containsKey('message')) {
              String message = decoded['message'];

              // Process validation errors if present
              if (decoded.containsKey('errors') && decoded['errors'] is Map) {
                final Map<String, dynamic> errors = decoded['errors'];
                List<String> errorMessages = [];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.map((e) => '$e').toList());
                  } else if (value is String) {
                    errorMessages.add(value);
                  }
                });

                if (errorMessages.isNotEmpty) {
                  scaffoldMessengerKey.currentContext!
                      .showToast(text: errorMessages[0]);
                  return Failure(0, message);
                }
              }

              // scaffoldMessengerKey.currentContext!.showToast(text: texttext: )(message);
              return Failure(0, message);
            }

            if (error.response?.statusCode == 404) {
              return Failure(0, AppStrings.unKnownError.tr());
            }
          } catch (e) {
            // scaffoldMessengerKey.currentContext!.showToast(text: texttext: )(e.toString());
            return Failure(0, '${error.response?.data['message']}');
          }
        }
        // scaffoldMessengerKey.currentContext!.showToast(text: texttext: )(error.message!);
        return Failure(0, '${error.response?.data['message']}');
      case DioExceptionType.badCertificate:
        return Failure(0, 'تعذر الاتصال ');
      case DioExceptionType.connectionError:
        // navigatorKey.currentContext!.showTopSnackBar( child: Text("تعذر الاتصال"),backgroundColor: ColorManager.red);
        return Failure(0, AppStrings.noInternetError.tr());
      case DioExceptionType.unknown:
        return Failure(0, AppStrings.unKnownError.tr());
    }
  }
}
