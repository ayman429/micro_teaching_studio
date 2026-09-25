import 'package:equatable/equatable.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.avatar,
  });

  final String uid;
  final String fullName;
  final String userName;
  final String email;
  final StudentAvatar avatar;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'userName': userName,
      'email': email,
      'avatar': avatar.name,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      avatar: StudentAvatar.fromName(map['avatar'] as String?),
    );
  }

  @override
  List<Object?> get props => [uid, fullName, userName, email, avatar];
}
