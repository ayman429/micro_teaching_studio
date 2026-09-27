import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_teaching_studio/features/analytics/analytics_constants.dart';

class TeacherAccess {
  TeacherAccess(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? _cachedUid;
  bool? _cached;

  Future<bool> get isTeacher async {
    final uid = _auth.currentUser?.uid.trim() ?? '';
    if (uid.isEmpty) return false;
    if (_cachedUid == uid && _cached != null) return _cached!;
    try {
      final snapshot = await _firestore
          .collection(AnalyticsConstants.rolesCollection)
          .doc(uid)
          .get()
          .timeout(AnalyticsConstants.writeTimeout);
      final role = (snapshot.data()?['role'] as String?)?.trim() ?? '';
      _cachedUid = uid;
      _cached = role == AnalyticsConstants.teacherRole;
      return _cached!;
    } catch (_) {
      return false;
    }
  }
}
