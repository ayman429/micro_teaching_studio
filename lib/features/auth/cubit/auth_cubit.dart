import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_teaching_studio/common/network/failure.dart';
import 'package:micro_teaching_studio/features/auth/cubit/auth_state.dart';
import 'package:micro_teaching_studio/features/auth/data/auth_repository.dart';
import 'package:micro_teaching_studio/features/auth/models/auth_user.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    if (state.status == AuthStatus.loading) return;
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _repository.restoreSession();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          errorMessage: failure.message,
        ),
      ),
      (user) {
        if (user == null) {
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              clearUser: true,
              clearError: true,
            ),
          );
        } else {
          emit(
            AuthState(
              status: AuthStatus.authenticated,
              user: user,
            ),
          );
        }
      },
    );
  }

  Future<void> createAccount({
    required String fullName,
    required String userName,
    required String password,
    required StudentAvatar avatar,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _repository.createAccount(
      fullName: fullName,
      userName: userName,
      password: password,
      avatar: avatar,
    );
    result.fold(_emitFailure, _emitAuthenticated);
  }

  Future<void> signIn({
    required String userName,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _repository.signIn(
      userName: userName,
      password: password,
    );
    result.fold(_emitFailure, _emitAuthenticated);
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _repository.signOut();
    result.fold(
      _emitFailure,
      (_) => emit(
        const AuthState(status: AuthStatus.unauthenticated),
      ),
    );
  }

  void _emitAuthenticated(AuthUser user) {
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  void _emitFailure(Failure failure) {
    emit(
      state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
        clearUser: true,
      ),
    );
  }
}
