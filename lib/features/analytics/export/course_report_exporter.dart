import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_report.dart';
import 'package:micro_teaching_studio/features/analytics/export/course_report_workbook.dart';
import 'package:micro_teaching_studio/features/analytics/export/teacher_access.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CourseReportExporter {
  CourseReportExporter(this._firestore, this._access);

  final FirebaseFirestore _firestore;
  final TeacherAccess _access;

  Future<void> shareGradesFile() async {
    if (!await _access.isTeacher) {
      throw StateError('grades export is limited to the teacher role');
    }
    final report = CourseReport.fromDocuments(
      userProgress: await _rows(AnalyticsConstants.userProgressCollection),
      partProgress: await _rows(AnalyticsConstants.partProgressCollection),
      attempts: await _rows(AnalyticsConstants.attemptsCollection),
    );
    final bytes = CourseReportWorkbook.encode(report);
    final directory = await getTemporaryDirectory();
    final stamp = _stamp(DateTime.now());
    final file = File('${directory.path}/micro_teaching_grades_$stamp.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Micro-Teaching Studio grades',
      ),
    );
  }

  String _stamp(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}_${two(time.hour)}${two(time.minute)}';
  }

  Future<List<Map<String, dynamic>>> _rows(String collection) async {
    final snapshot = await _firestore
        .collection(collection)
        .get()
        .timeout(AnalyticsConstants.writeTimeout);
    return [
      for (final doc in snapshot.docs) _plain(doc.data()),
    ];
  }

  Map<String, dynamic> _plain(Map<String, dynamic> data) {
    return {
      for (final entry in data.entries) entry.key: _value(entry.value),
    };
  }

  Object? _value(Object? value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is List) return value.map(_value).toList();
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _value(entry.value),
      };
    }
    return value;
  }
}
