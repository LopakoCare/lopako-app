// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Calendar`
  String get calendar {
    return Intl.message('Calendar', name: 'calendar', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Sign In`
  String get signIn {
    return Intl.message('Sign In', name: 'signIn', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Email is required.`
  String get emailRequired {
    return Intl.message(
      'Email is required.',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `The email address is not valid.`
  String get invalidEmailFormat {
    return Intl.message(
      'The email address is not valid.',
      name: 'invalidEmailFormat',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Password is required.`
  String get passwordRequired {
    return Intl.message(
      'Password is required.',
      name: 'passwordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters.`
  String get passwordTooShort {
    return Intl.message(
      'Password must be at least 6 characters.',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Name is required.`
  String get nameRequired {
    return Intl.message(
      'Name is required.',
      name: 'nameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get age {
    return Intl.message('Age', name: 'age', desc: '', args: []);
  }

  /// `Age is required.`
  String get ageRequired {
    return Intl.message(
      'Age is required.',
      name: 'ageRequired',
      desc: '',
      args: [],
    );
  }

  /// `The age must be a valid number.`
  String get invalidAge {
    return Intl.message(
      'The age must be a valid number.',
      name: 'invalidAge',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Continue with Google`
  String get continueWithGoogle {
    return Intl.message(
      'Continue with Google',
      name: 'continueWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Apple`
  String get continueWithApple {
    return Intl.message(
      'Continue with Apple',
      name: 'continueWithApple',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during authentication process. Please try again.`
  String get authError {
    return Intl.message(
      'An error occurred during authentication process. Please try again.',
      name: 'authError',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Sign in`
  String get signInTitle {
    return Intl.message('Sign in', name: 'signInTitle', desc: '', args: []);
  }

  /// `Enter your password`
  String get enterPassword {
    return Intl.message(
      'Enter your password',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Create an account`
  String get createAccount {
    return Intl.message(
      'Create an account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continue_ {
    return Intl.message('Continue', name: 'continue_', desc: '', args: []);
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `or`
  String get or {
    return Intl.message('or', name: 'or', desc: '', args: []);
  }

  /// `Hello world!`
  String get world {
    return Intl.message('Hello world!', name: 'world', desc: '', args: []);
  }

  /// `User not authenticated`
  String get userNotAuthenticated {
    return Intl.message(
      'User not authenticated',
      name: 'userNotAuthenticated',
      desc: '',
      args: [],
    );
  }

  /// `Error updating profile: `
  String get profileUpdateError {
    return Intl.message(
      'Error updating profile: ',
      name: 'profileUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `Error updating routines: `
  String get routinesUpdateError {
    return Intl.message(
      'Error updating routines: ',
      name: 'routinesUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Edit Routines`
  String get editRoutines {
    return Intl.message(
      'Edit Routines',
      name: 'editRoutines',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get profileUpdated {
    return Intl.message(
      'Profile updated successfully',
      name: 'profileUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Routine`
  String get routine {
    return Intl.message('Routine', name: 'routine', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Add routine`
  String get addRoutine {
    return Intl.message('Add routine', name: 'addRoutine', desc: '', args: []);
  }

  /// `Routines updated successfully`
  String get routinesUpdated {
    return Intl.message(
      'Routines updated successfully',
      name: 'routinesUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Your first family circle`
  String get firstFamilyCircleTitle {
    return Intl.message(
      'Your first family circle',
      name: 'firstFamilyCircleTitle',
      desc: '',
      args: [],
    );
  }

  /// `We are almost there! Just one more step...`
  String get firstFamilyCircleSubtitle {
    return Intl.message(
      'We are almost there! Just one more step...',
      name: 'firstFamilyCircleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Create a circle`
  String get createCircle {
    return Intl.message(
      'Create a circle',
      name: 'createCircle',
      desc: '',
      args: [],
    );
  }

  /// `Create a family circle and invite other caregivers for the patient's well-being.`
  String get createCircleDescription {
    return Intl.message(
      'Create a family circle and invite other caregivers for the patient\'s well-being.',
      name: 'createCircleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Join to others`
  String get joinCircle {
    return Intl.message(
      'Join to others',
      name: 'joinCircle',
      desc: '',
      args: [],
    );
  }

  /// `Join a family circle previously created by another caregiver.`
  String get joinCircleDescription {
    return Intl.message(
      'Join a family circle previously created by another caregiver.',
      name: 'joinCircleDescription',
      desc: '',
      args: [],
    );
  }

  /// `Skip for now`
  String get skip {
    return Intl.message('Skip for now', name: 'skip', desc: '', args: []);
  }

  /// `Create family circle`
  String get createFamilyCircle {
    return Intl.message(
      'Create family circle',
      name: 'createFamilyCircle',
      desc: '',
      args: [],
    );
  }

  /// `Family of`
  String get familyOf {
    return Intl.message('Family of', name: 'familyOf', desc: '', args: []);
  }

  /// `Patient name`
  String get patientName {
    return Intl.message(
      'Patient name',
      name: 'patientName',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one option.`
  String get selectAtLeastOneOption {
    return Intl.message(
      'Select at least one option.',
      name: 'selectAtLeastOneOption',
      desc: '',
      args: [],
    );
  }

  /// `Answer required questions`
  String get missingRequiredAnswers {
    return Intl.message(
      'Answer required questions',
      name: 'missingRequiredAnswers',
      desc: '',
      args: [],
    );
  }

  /// `Family circle created!`
  String get familyCircleCreated {
    return Intl.message(
      'Family circle created!',
      name: 'familyCircleCreated',
      desc: '',
      args: [],
    );
  }

  /// `Share the code with other caregivers to help together in the patient's well-being.`
  String get shareFamilyCirclePinDescription {
    return Intl.message(
      'Share the code with other caregivers to help together in the patient\'s well-being.',
      name: 'shareFamilyCirclePinDescription',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get finish {
    return Intl.message('Finish', name: 'finish', desc: '', args: []);
  }

  /// `Discover routines`
  String get discoverRoutines {
    return Intl.message(
      'Discover routines',
      name: 'discoverRoutines',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Recommended routines`
  String get recommendedRoutines {
    return Intl.message(
      'Recommended routines',
      name: 'recommendedRoutines',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `No routines found.`
  String get noRoutinesFound {
    return Intl.message(
      'No routines found.',
      name: 'noRoutinesFound',
      desc: '',
      args: [],
    );
  }

  /// `All the areas in which this routine helps you.`
  String get routineCategoriesScoresHelpText {
    return Intl.message(
      'All the areas in which this routine helps you.',
      name: 'routineCategoriesScoresHelpText',
      desc: '',
      args: [],
    );
  }

  /// `What you will learn?`
  String get whatYouWillLearn {
    return Intl.message(
      'What you will learn?',
      name: 'whatYouWillLearn',
      desc: '',
      args: [],
    );
  }

  /// `What will we do?`
  String get whatWillWeDo {
    return Intl.message(
      'What will we do?',
      name: 'whatWillWeDo',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get later {
    return Intl.message('Later', name: 'later', desc: '', args: []);
  }

  /// `Start now`
  String get startNow {
    return Intl.message('Start now', name: 'startNow', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Tomorrow`
  String get tomorrow {
    return Intl.message('Tomorrow', name: 'tomorrow', desc: '', args: []);
  }

  /// `Morning`
  String get morning {
    return Intl.message('Morning', name: 'morning', desc: '', args: []);
  }

  /// `Afternoon`
  String get afternoon {
    return Intl.message('Afternoon', name: 'afternoon', desc: '', args: []);
  }

  /// `Night`
  String get night {
    return Intl.message('Night', name: 'night', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
