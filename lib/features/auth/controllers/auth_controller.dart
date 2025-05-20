import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/core/services/user_service.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../models/auth_state_model.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  AuthStateModel _state = AuthStateModel();

  AuthController()
      : _authService = ServiceManager.instance.getService('auth') as AuthService;

  AuthStateModel get state => _state;

  // Update email and check if it exists in Firebase
  Future<void> login(String email) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      _state = _state.copyWith(
        errorMessage: 'Please enter a valid email address',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      email: email,
      isLoading: true,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final providers = await _authService.getProviders(email);

      if (providers.isEmpty) {
        // Email doesn't exist, proceed to registration
        _state = _state.copyWith(
          currentStep: AuthStep.registration,
          isLoading: false,
          availableProviders: [],
        );
      } else if (providers.contains('password')) {
        // Email exists with password, proceed to password input
        _state = _state.copyWith(
          currentStep: AuthStep.passwordInput,
          isLoading: false,
          availableProviders: providers,
        );
      } else {
        String firstProvider = providers.first;
        if (firstProvider == 'google.com') {
          await signInWithGoogle();
        }
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Error checking email: ${e.toString()}',
      );
    }

    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> loginWithPassword(String password) async {
    if (password.isEmpty) {
      _state = _state.copyWith(
        errorMessage: 'Please enter your password',
      );
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(
      password: password,
      isLoading: true,
      errorMessage: null,
    );
    notifyListeners();

    try {
      await _authService.login(_state.email, password);
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid password. Please try again.',
      );
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailPassword(String password, String name, String ageStr) async {
    // Validate inputs
    if (password.isEmpty || password.length < 6) {
      _state = _state.copyWith(
        errorMessage: 'Password must be at least 6 characters',
      );
      notifyListeners();
      return false;
    }

    if (name.isEmpty) {
      _state = _state.copyWith(
        errorMessage: 'Please enter your name',
      );
      notifyListeners();
      return false;
    }

    int? age;
    try {
      age = int.parse(ageStr);
      if (age <= 0) throw FormatException('Age must be positive');
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Please enter a valid age',
      );
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(
      password: password,
      name: name,
      age: age,
      isLoading: true,
      errorMessage: null,
    );
    notifyListeners();

    try {
      await _authService.signup(
        email: _state.email,
        password: password,
        name: name,
        age: age,
      );
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed: ${e.toString()}',
      );
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _state = _state.copyWith(
      isLoading: true,
    );
    notifyListeners();

    try {
      await _authService.signinWithGoogle();
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      throw e;
    }
  }

  // Reset to email input step
  void resetToEmailInput() {
    _state = _state.copyWith(
      currentStep: AuthStep.emailInput,
      password: '',
      name: '',
      age: null,
      errorMessage: null,
    );
    notifyListeners();
  }

  // Helper methods
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _state = AuthStateModel(); // Reset state after sign out
    notifyListeners();
  }

  // Get user
  Future<AppUser?> getUser() async {
    final usrSrv = ServiceManager.instance.getService('user') as UserService;
    return await usrSrv.get(uid: _authService.currentUser?.uid);
  }

  /// Change the [currentPassword] to the [newPassword] for the current user.
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _authService.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  /// Check if the current user is logged in with a password provider.
  bool isUsingPassword() {
    return _state.availableProviders.contains('password');
  }
}
