import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider() {
    // 데모용: 자동으로 데모 계정 로그인
    _currentUser = MockDataService.getDemoUser('demo@cltv-sign.com');
    _isAuthenticated = true;
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 4) {
      _currentUser = MockDataService.getDemoUser(email);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _error = '이메일 또는 비밀번호가 올바르지 않습니다.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? company,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    _currentUser = User(
      name: name,
      email: email,
      company: company,
      plan: UserPlan.free,
    );
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? department,
    String? position,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      company: company,
      department: department,
      position: position,
    );
    notifyListeners();
  }

  Future<void> updateSettings(UserSettings settings) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(settings: settings);
    notifyListeners();
  }
}
