import 'package:equatable/equatable.dart';

class PaginationParams extends Equatable {
  final int page;
  final int? limit;

  const PaginationParams({
    required this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [page, limit];

  Map<String, dynamic> toJson() => {
        'page': page,
        if (limit != null) 'limit': limit,
      };
}
