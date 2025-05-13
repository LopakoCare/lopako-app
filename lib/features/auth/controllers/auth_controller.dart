import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../models/auth_state_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  AuthStateModel _state = AuthStateModel();

  AuthController(this._authService);

  AuthStateModel get state => _state;

  bool _wasJustRegistered = false;

  bool get wasJustRegistered => _wasJustRegistered;


  // Update email and check if it exists in Firebase
  Future<void> checkEmail(String email) async {
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
      final providers = await _authService.checkEmailExists(email);

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
  Future<bool> signInWithEmailPassword(String password) async {
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
      await _authService.signInWithEmailPassword(_state.email, password);
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
      await _authService.registerWithEmailPassword(
        _state.email,
        password,
        name,
        age,
      );
      _state = _state.copyWith(isLoading: false);
      _wasJustRegistered = true; //Marcamos que es registro
      print('[DEBUG] Usuario registrado - wasJustRegistered = $_wasJustRegistered');
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
  Future<UserCredential> signInWithGoogle() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    
    try {
      final userCredential = await _authService.signInWithGoogle();
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return userCredential;
    } catch (e) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      rethrow;
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

  String _formatProviders(List<String> providers) {
    final formattedProviders = providers.map((provider) {
      switch (provider) {
        case 'google.com':
          return 'Google';
        case 'apple.com':
          return 'Apple';
        case 'password':
          return 'Email/Password';
        default:
          return provider;
      }
    }).toList();

    if (formattedProviders.length == 1) {
      return formattedProviders.first;
    } else if (formattedProviders.length == 2) {
      return '${formattedProviders.first} or ${formattedProviders.last}';
    } else {
      final last = formattedProviders.removeLast();
      return '${formattedProviders.join(', ')}, or $last';
    }
  }

  // Sign out
  void signOut() async {
    await _authService.signOut();
    _state = AuthStateModel(); // Reset state after sign out
    _wasJustRegistered = false; // reset
    notifyListeners();
  }
}
