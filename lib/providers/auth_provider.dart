import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  UserModel? _user;
  Future<bool>? _loginRequest;

  AuthProvider(this._apiService);

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _apiService.setToken(token);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login() {
    return _loginRequest ??= _performLogin();
  }

  Future<bool> _performLogin() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(ApiConstants.login, {
        'email': ApiConstants.loginEmail,
        'password': ApiConstants.loginPassword,
      });

      final loginResponse = LoginResponse.fromJson(response);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', loginResponse.token);
      _apiService.setToken(loginResponse.token);

      _user = loginResponse.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      _loginRequest = null;
      return true;
    } catch (e) {
      _errorMessage = e is ApiException
          ? e.message
          : 'Login failed. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
      _loginRequest = null;
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _apiService.clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
