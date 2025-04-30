import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../generated/l10n.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_state_model.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_sign_in_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final authController = Provider.of<AuthController>(context);
    final state = authController.state;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 80.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo or image
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                  ),
                ),

                // Title
                Text(
                  _getTitleText(state.currentStep, localizations),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Email field (always visible)
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: state.currentStep == AuthStep.emailInput && !state.isLoading,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.emailRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return localizations.invalidEmailFormat;
                    }
                    return null;
                  },
                  onFieldSubmitted: state.currentStep == AuthStep.emailInput
                      ? (_) => _checkEmail(authController)
                      : null,
                ),

                const SizedBox(height: 16),

                // Password field (visible for password input and registration)
                if (state.currentStep == AuthStep.passwordInput ||
                    state.currentStep == AuthStep.registration)
                  Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: localizations.password,
                        ),
                        obscureText: true,
                        enabled: !state.isLoading,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.passwordRequired;
                          }
                          if (value.length < 6) {
                            return localizations.passwordTooShort;
                          }
                          return null;
                        },
                        onFieldSubmitted: state.currentStep == AuthStep.passwordInput
                            ? (_) => _signIn(authController)
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Name and Age fields (visible only for registration)
                if (state.currentStep == AuthStep.registration)
                  Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: localizations.name,
                        ),
                        enabled: !state.isLoading,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.nameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: localizations.age,
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !state.isLoading,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.ageRequired;
                          }
                          try {
                            int age = int.parse(value);
                            if (age <= 0) {
                              return localizations.invalidAge;
                            }
                          } catch (e) {
                            return localizations.invalidAge;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Primary action button
                AuthButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                    if (state.currentStep == AuthStep.emailInput) {
                      if (_validateEmailField()) {
                        _checkEmail(authController);
                      }
                    } else if (state.currentStep == AuthStep.passwordInput) {
                      if (_validatePasswordField()) {
                        _signIn(authController);
                      }
                    } else {
                      if (_validateRegistrationFields()) {
                        _register(authController);
                      }
                    }
                  },
                  isLoading: state.isLoading,
                  text: _getButtonText(state.currentStep, localizations),
                ),

                // Back button (visible for password input and registration)
                if (state.currentStep != AuthStep.emailInput)
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => authController.resetToEmailInput(),
                    child: Text(localizations.back),
                  ),

                // Social sign-in options (visible only on email input step)
                if (state.currentStep == AuthStep.emailInput)
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(localizations.or),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            SocialSignInButton(
                              text: localizations.continueWithGoogle,
                              icon: 'assets/images/google_logo.png',
                              onPressed: state.isLoading
                                  ? null
                                  : () => _signInWithGoogle(authController),
                            ),
                            const SizedBox(height: 12),
                            if (Theme.of(context).platform == TargetPlatform.iOS)
                              SocialSignInButton(
                                text: localizations.continueWithApple,
                                icon: 'assets/images/apple_logo.png',
                                onPressed: state.isLoading
                                    ? null
                                    : () => _signInWithGoogle(authController),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for validation
  bool _validateEmailField() {
    if (_emailController.text.isEmpty) {
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      return false;
    }
    return true;
  }

  bool _validatePasswordField() {
    if (_passwordController.text.isEmpty) {
      return false;
    }
    if (_passwordController.text.length < 6) {
      return false;
    }
    return true;
  }

  bool _validateRegistrationFields() {
    return _formKey.currentState?.validate() ?? false;
  }


  // Helper method to show error dialogs for external auth providers
  void _showAuthErrorDialog(String errorMessage) {
    final localizations = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.authError),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTitleText(AuthStep step, S localizations) {
    switch (step) {
      case AuthStep.emailInput:
        return localizations.signInTitle;
      case AuthStep.passwordInput:
        return localizations.enterPassword;
      case AuthStep.registration:
        return localizations.createAccount;
    }
  }

  String _getButtonText(AuthStep step, S localizations) {
    switch (step) {
      case AuthStep.emailInput:
        return localizations.continue_;
      case AuthStep.passwordInput:
        return localizations.signIn;
      case AuthStep.registration:
        return localizations.signUp;
    }
  }

  void _checkEmail(AuthController controller) async {
    if (_emailController.text.isNotEmpty) {
      await controller.checkEmail(_emailController.text);
    }
  }

  void _signIn(AuthController controller) async {
    if (_passwordController.text.isNotEmpty) {
      try {
        await controller.signInWithEmailPassword(_passwordController.text);
      } catch (error) {
        // Show error dialog for authentication errors
        _showAuthErrorDialog(error.toString());
      }
    }
  }

  void _register(AuthController controller) async {
    if (_validateRegistrationFields()) {
      try {
        await controller.registerWithEmailPassword(
          _passwordController.text,
          _nameController.text,
          _ageController.text,
        );
      } catch (error) {
        // Show error dialog for registration errors
        _showAuthErrorDialog(error.toString());
      }
    }
  }

  void _signInWithGoogle(AuthController controller) {
    controller.signInWithGoogle().then((success) {
      // TODO: Handle success case
    }).catchError((error) {
      if (error is! FirebaseAuthException || error.code != 'ERROR_ABORTED_BY_USER') {
        _showAuthErrorDialog(error.toString());
      }
    });
  }
}
