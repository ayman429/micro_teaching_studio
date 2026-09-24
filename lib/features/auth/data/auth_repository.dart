import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_teaching_studio/app/app_prefs.dart';
import 'package:micro_teaching_studio/common/network/failure.dart';
import 'package:micro_teaching_studio/common/resources/strings_manager.dart';
import 'package:micro_teaching_studio/features/auth/data/auth_error_mapper.dart';
import 'package:micro_teaching_studio/features/auth/data/auth_remote_data_source.dart';
import 'package:micro_teaching_studio/features/auth/models/auth_user.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';

class AuthRepository {
  AuthRepository(this._remote, this._prefs);

  final AuthRemoteDataSource _remote;
  final AppPreferences _prefs;

  Future<Either<Failure, AuthUser>> createAccount({
    required String fullName,
    required String userName,
    required String password,
    required StudentAvatar avatar,
  }) {
    return _guard(() async {
      final user = await _remote.createAccount(
        fullName: fullName,
        userName: userName,
        password: password,
        avatar: avatar,
      );
      await _cache(user);
      return user;
    });
  }

  Future<Either<Failure, AuthUser>> signIn({
    required String userName,
    required String password,
  }) {
    return _guard(() async {
      final user = await _remote.signIn(
        userName: userName,
        password: password,
      );
      final hydrated = _hydrate(user);
      await _cache(hydrated);
      return hydrated;
    });
  }

  Future<Either<Failure, AuthUser?>> restoreSession() {
    return _guard(() async {
      final user = await _remote.currentUser();
      if (user != null) {
        final hydrated = _hydrate(user);
        await _cache(hydrated);
        return hydrated;
      }
      return user;
    });
  }

  Future<Either<Failure, Unit>> signOut() {
    return _guard(() async {
      await _remote.signOut();
      await _prefs.logout();
      return unit;
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on FirebaseAuthException catch (error) {
      return Left(Failure(0, AuthErrorMapper.message(error)));
    } catch (_) {
      return Left(Failure(0, AppStrings.unKnownError));
    }
  }

  AuthUser _hydrate(AuthUser user) {
    final cachedUserName = _prefs.getUserName();
    final guest = AppStrings.guest.tr();
    final cachedAvatar = _prefs.getUserImage();
    return AuthUser(
      uid: user.uid.isNotEmpty ? user.uid : _prefs.getUid(),
      fullName: user.fullName.isNotEmpty ? user.fullName : _prefs.getFullName(),
      userName: user.userName.isNotEmpty && user.userName != guest
          ? user.userName
          : (cachedUserName != guest ? cachedUserName : user.userName),
      email: user.email.isNotEmpty ? user.email : _prefs.getUserEmail(),
      avatar: user.avatar != StudentAvatar.girl1 || cachedAvatar.isEmpty
          ? user.avatar
          : StudentAvatar.fromName(cachedAvatar),
    );
  }

  Future<void> _cache(AuthUser user) async {
    await Future.wait([
      _prefs.saveUid(user.uid),
      _prefs.saveUserName(user.userName),
      _prefs.saveFullName(user.fullName),
      _prefs.saveUserEmail(user.email),
      _prefs.saveUserImage(user.avatar.name),
    ]);
  }
}
