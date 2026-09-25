import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:micro_teaching_studio/features/auth/auth_constants.dart';
import 'package:micro_teaching_studio/features/auth/models/auth_user.dart';
import 'package:micro_teaching_studio/features/auth/models/student_avatar.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AuthConstants.usersCollection);

  Future<AuthUser> createAccount({
    required String fullName,
    required String userName,
    required String password,
    required StudentAvatar avatar,
  }) async {
    final normalizedName = AuthConstants.normalizeUserName(userName);
    final email = AuthConstants.emailFromUserName(normalizedName);
    final firebaseUser = await _awaitAuth(
      _auth.createUserWithEmailAndPassword(email: email, password: password),
    );
    try {
      await Future.wait([
        firebaseUser.updateDisplayName(fullName.trim()),
        firebaseUser.updatePhotoURL(avatar.name),
      ]).timeout(AuthConstants.firebaseTimeout);
    } catch (_) {
      // Profile fields on Auth are optional; the account already exists.
    }
    final user = AuthUser(
      uid: firebaseUser.uid,
      fullName: fullName.trim(),
      userName: normalizedName,
      email: email,
      avatar: avatar,
    );
    unawaited(_saveProfile(user));
    return user;
  }

  Future<AuthUser> signIn({
    required String userName,
    required String password,
  }) async {
    final email = AuthConstants.emailFromUserName(userName);
    final firebaseUser = await _awaitAuth(
      _auth.signInWithEmailAndPassword(email: email, password: password),
    );
    return _profileFor(firebaseUser);
  }

  Future<AuthUser?> currentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _profileFor(firebaseUser);
  }

  Future<void> signOut() => _auth.signOut();

  Future<User> _awaitAuth(Future<UserCredential> action) async {
    try {
      final user = await Future.any<User?>([
        action.then((credential) => credential.user),
        _auth.authStateChanges().firstWhere((signedIn) => signedIn != null),
      ]).timeout(AuthConstants.authTimeout);
      if (user == null) {
        throw FirebaseAuthException(code: 'network-request-failed');
      }
      return user;
    } on FirebaseAuthException {
      rethrow;
    } on TimeoutException {
      throw FirebaseAuthException(code: 'network-request-failed');
    }
  }

  Future<AuthUser> _profileFor(User firebaseUser) async {
    try {
      final snapshot = await _users
          .doc(firebaseUser.uid)
          .get()
          .timeout(AuthConstants.firebaseTimeout);
      final data = snapshot.data();
      if (data != null) {
        return AuthUser.fromMap(data);
      }
    } catch (_) {
      // Fall back to Auth profile if Firestore is unreachable.
    }
    return AuthUser(
      uid: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? '',
      userName: AuthConstants.userNameFromEmail(firebaseUser.email ?? ''),
      email: firebaseUser.email ?? '',
      avatar: StudentAvatar.fromName(firebaseUser.photoURL),
    );
  }

  Future<void> _saveProfile(AuthUser user) async {
    try {
      await _users.doc(user.uid).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(AuthConstants.firebaseTimeout);
    } catch (_) {
      // Auth succeeded; profile can be rewritten on the next session restore.
    }
  }
}
