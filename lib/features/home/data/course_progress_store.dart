import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseProgressStore {
  CourseProgressStore(this._prefs, this._appPreferences);

  final SharedPreferences _prefs;
  final AppPreferences _appPreferences;

  static const String _prefix = 'course_progress_parts_';

  String get _key {
    final uid = _appPreferences.getUid().trim();
    return '$_prefix${uid.isEmpty ? 'guest' : uid}';
  }

  Set<String> load() {
    return _prefs.getStringList(_key)?.toSet() ?? <String>{};
  }

  Future<void> save(Set<String> ids) {
    return _prefs.setStringList(_key, ids.toList());
  }

  Set<String> loadNamed(String name) {
    return _prefs.getStringList(_namedKey(name))?.toSet() ?? <String>{};
  }

  Future<void> saveNamed(String name, Set<String> ids) {
    return _prefs.setStringList(_namedKey(name), ids.toList());
  }

  String _namedKey(String name) {
    final uid = _appPreferences.getUid().trim();
    return 'course_progress_${name}_${uid.isEmpty ? 'guest' : uid}';
  }
}
