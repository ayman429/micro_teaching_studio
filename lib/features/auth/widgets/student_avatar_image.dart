import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';

class StudentAvatarImage extends StatelessWidget {
  const StudentAvatarImage({
    super.key,
    required this.avatar,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final StudentAvatar avatar;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AvifImage.asset(
      avatar.asset,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
