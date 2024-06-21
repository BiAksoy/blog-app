import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/core/error/failures.dart';
import 'package:blog_app/core/network/connection_checker.dart';
import 'package:blog_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_app/core/entities/user.dart';
import 'package:blog_app/features/auth/data/models/user_model.dart';
import 'package:blog_app/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final ConnectionChecker _connectionChecker;

  AuthRepositoryImpl(this._remoteDataSource, this._connectionChecker);

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await _connectionChecker.hasConnection) {
        final session = _remoteDataSource.currentSession;

        if (session == null) {
          return left(Failure('User is not logged in'));
        }

        return right(
          UserModel(
            id: session.user.id,
            email: '',
            name: '',
          ),
        );
      }

      final user = await _remoteDataSource.getCurrentUserData();

      if (user == null) {
        return left(Failure('User is not logged in'));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await _remoteDataSource.logInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await _remoteDataSource.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() getUser,
  ) async {
    try {
      if (!await _connectionChecker.hasConnection) {
        return left(Failure('No internet connection'));
      }

      final user = await getUser();
      return right(user);
    } on sb.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
