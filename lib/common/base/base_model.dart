import 'package:equatable/equatable.dart';

class BaseModel extends Equatable {
  const BaseModel({
    required this.status,
    required this.message,
  });

  final String? status;
  final String? message;

  factory BaseModel.fromJson(Map<String, dynamic> json) {
    return BaseModel(
      status: json["status"],
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };

  @override
  List<Object?> get props => [status, message];
}
