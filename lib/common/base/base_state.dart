import 'exports.dart';

enum Status {
  initial,
  loading,
  success,
  failure,
  isPaginationLoading,
  isPaginationFailure,
  custom
}

extension BaseStateX<T> on BaseState<T> {
  bool get isInitial => status == Status.initial;

  bool get isLoading => status == Status.loading;

  bool get isSuccess => status == Status.success;

  bool get isFailure => status == Status.failure;

  bool get isPaginationLoading => status == Status.isPaginationLoading;

  bool get isPaginationFailure => status == Status.isPaginationFailure;

  bool get isCustom => status == Status.custom;

  bool get isEmpty => isSuccess && items.isEmpty;

  bool get hasData => data != null;
}

class BaseState<T> extends Equatable {
  final Status status;
  final String? errorMessage;
  final String? successMessage;

  final T? data;
  final List<T> items;
  final Map<String, dynamic> metadata;
  final Failure? failure;

  final int page;
  final bool hasReachedMax;
  const BaseState({
    this.status = Status.initial,
    this.failure,
    this.errorMessage,
    this.successMessage,
    this.data,
    this.items = const [],
    this.metadata = const {},
    this.page = 1,
    this.hasReachedMax = false,
  });

  BaseState<T> copyWith(
      {Status? status,
      String? errorMessage,
      String? successMessage,
      Failure? failure,
      T? data,
      List<T>? items,
      Map<String, dynamic>? metadata,
      int? page,
      bool? hasReachedMax}) {
    return BaseState<T>(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      data: data ?? this.data,
      items: items ?? this.items,
      metadata: metadata ?? this.metadata, // Copy metadata
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        successMessage,
        data,
        items,
        metadata,
        failure,
        page,
        hasReachedMax
      ];
}
