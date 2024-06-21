import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get hasConnection;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final InternetConnection _internetConnection;

  ConnectionCheckerImpl(this._internetConnection);

  @override
  Future<bool> get hasConnection async =>
      await _internetConnection.hasInternetAccess;
}
