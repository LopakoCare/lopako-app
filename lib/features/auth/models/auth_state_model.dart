enum AuthStep {
  emailInput,
  passwordInput,
  registration,
}

enum AuthProvider {
  email,
  google,
  apple,
}

class AuthStateModel {
  final AuthStep currentStep;
  final String email;
  final String password;
  final String name;
  final int? age;
  final bool isLoading;
  final String? errorMessage;
  final List<String> availableProviders;

  AuthStateModel({
    this.currentStep = AuthStep.emailInput,
    this.email = '',
    this.password = '',
    this.name = '',
    this.age,
    this.isLoading = false,
    this.errorMessage,
    this.availableProviders = const [],
  });

  AuthStateModel copyWith({
    AuthStep? currentStep,
    String? email,
    String? password,
    String? name,
    int? age,
    bool? isLoading,
    String? errorMessage,
    List<String>? availableProviders,
  }) {
    return AuthStateModel(
      currentStep: currentStep ?? this.currentStep,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      age: age ?? this.age,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,  // Pass null to clear error
      availableProviders: availableProviders ?? this.availableProviders,
    );
  }
}
