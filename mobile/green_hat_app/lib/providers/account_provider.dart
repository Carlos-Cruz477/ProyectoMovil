import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../services/api_service.dart';

class AccountProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Account? _account;
  bool _isCheckingSession = true;
  bool _isBusy = false;

  Account? get account => _account;
  bool get isCheckingSession => _isCheckingSession;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _account != null;

  Future<void> restoreSession() async {
    try {
      _account = await _api.restoreSession();
    } catch (_) {
      _account = null;
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    _setBusy(true);
    try {
      _account = await _api.logIn(email: email, password: password);
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signUp({
    required String email,
    required String name,
    required String password,
    required String businessSector,
  }) async {
    _setBusy(true);
    try {
      _account = await _api.signUp(
        email: email,
        name: name,
        password: password,
        businessSector: businessSector,
      );
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logOut() async {
    _setBusy(true);
    try {
      await _api.logOut();
      _account = null;
      notifyListeners();
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}
