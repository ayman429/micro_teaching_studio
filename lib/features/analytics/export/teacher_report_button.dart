import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:micro_teaching_studio/app/app_functions.dart';
import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/common/resources/values_manager.dart';
import 'package:micro_teaching_studio/common/widgets/default_button_widget.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_report_exporter.dart';
import 'package:micro_teaching_studio/features/analytics/export/teacher_access.dart';

class TeacherReportButton extends StatefulWidget {
  const TeacherReportButton({super.key});

  @override
  State<TeacherReportButton> createState() => _TeacherReportButtonState();
}

class _TeacherReportButtonState extends State<TeacherReportButton> {
  var _teacher = false;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final teacher = await TeacherAccess(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ).isTeacher;
    if (!mounted) return;
    setState(() => _teacher = teacher);
  }

  @override
  Widget build(BuildContext context) {
    if (!_teacher) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: AppPadding.p16.h),
      child: SizedBox(
        width: double.infinity,
        height: AppSize.submitHeight.h,
        child: DefaultButtonWidget(
          onPressed: _busy ? null : _export,
          text: AppStrings.exportGrades.tr(),
          isLoading: _busy,
          color: ColorManager.navy,
          textColor: ColorManager.white,
          radius: AppRadius.r16.r,
          elevation: 0,
          verticalPadding: 0,
          fontSize: FontSize.s14.sp,
          loadingColor: ColorManager.white,
        ),
      ),
    );
  }

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final firestore = FirebaseFirestore.instance;
      await CourseReportExporter(
        firestore,
        TeacherAccess(firestore, FirebaseAuth.instance),
      ).shareGradesFile();
    } catch (_) {
      if (mounted) {
        AppFunctions.showsToast(
          AppStrings.exportGradesFailed.tr(),
          ColorManager.red,
          context,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
