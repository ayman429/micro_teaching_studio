import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Container arrowIcon(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF3F5F7),
      shape: BoxShape.circle,
    ),
    width: 44,
    height: 44,
    child: IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_outlined,
        color: Colors.black,
        size: 20,
      ),
      onPressed: () {
        context.pop(true);
      },
    ),
  );
}
