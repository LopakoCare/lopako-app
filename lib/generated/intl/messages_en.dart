// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(patientName) => "Family of ${patientName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activities": MessageLookupByLibrary.simpleMessage("Activities"),
    "addFamilyCircle": MessageLookupByLibrary.simpleMessage(
      "Add family circle",
    ),
    "addFamilyCircleDecision": MessageLookupByLibrary.simpleMessage(
      "Do you want to create a new family circle or join an existing one?",
    ),
    "addOtherFamilyCircle": MessageLookupByLibrary.simpleMessage(
      "Add other family circle",
    ),
    "addRoutine": MessageLookupByLibrary.simpleMessage("Add routine"),
    "afternoon": MessageLookupByLibrary.simpleMessage("Afternoon"),
    "age": MessageLookupByLibrary.simpleMessage("Age"),
    "ageRequired": MessageLookupByLibrary.simpleMessage("Age is required."),
    "assistant": MessageLookupByLibrary.simpleMessage("Assistant"),
    "authError": MessageLookupByLibrary.simpleMessage(
      "An error occurred during authentication process. Please try again.",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "beforeStart": MessageLookupByLibrary.simpleMessage("Before starting"),
    "calendar": MessageLookupByLibrary.simpleMessage("Calendar"),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change password"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm password"),
    "continueWithApple": MessageLookupByLibrary.simpleMessage(
      "Continue with Apple",
    ),
    "continueWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "continue_": MessageLookupByLibrary.simpleMessage("Continue"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create an account"),
    "createCircle": MessageLookupByLibrary.simpleMessage("Create a circle"),
    "createCircleDescription": MessageLookupByLibrary.simpleMessage(
      "Create a family circle and invite other caregivers for the patient\'s well-being.",
    ),
    "createFamilyCircle": MessageLookupByLibrary.simpleMessage(
      "Create family circle",
    ),
    "currentPassword": MessageLookupByLibrary.simpleMessage("Current password"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "discoverRoutines": MessageLookupByLibrary.simpleMessage(
      "Discover routines",
    ),
    "editAccount": MessageLookupByLibrary.simpleMessage("Edit account"),
    "editFamilyCircle": MessageLookupByLibrary.simpleMessage(
      "Edit family circle",
    ),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "editRoutines": MessageLookupByLibrary.simpleMessage("Edit Routines"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailRequired": MessageLookupByLibrary.simpleMessage("Email is required."),
    "enterPassword": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "familyCircleCreated": MessageLookupByLibrary.simpleMessage(
      "Family circle created!",
    ),
    "familyCircles": MessageLookupByLibrary.simpleMessage("Family circles"),
    "familyOf": MessageLookupByLibrary.simpleMessage("Family of"),
    "familyOfPatientName": m0,
    "finish": MessageLookupByLibrary.simpleMessage("Finish"),
    "firstFamilyCircleSubtitle": MessageLookupByLibrary.simpleMessage(
      "We are almost there! Just one more step...",
    ),
    "firstFamilyCircleTitle": MessageLookupByLibrary.simpleMessage(
      "Your first family circle",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "invalidAge": MessageLookupByLibrary.simpleMessage(
      "The age must be a valid number.",
    ),
    "invalidEmailFormat": MessageLookupByLibrary.simpleMessage(
      "The email address is not valid.",
    ),
    "joinCircle": MessageLookupByLibrary.simpleMessage("Join to others"),
    "joinCircleDescription": MessageLookupByLibrary.simpleMessage(
      "Join a family circle previously created by another caregiver.",
    ),
    "later": MessageLookupByLibrary.simpleMessage("Later"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "members": MessageLookupByLibrary.simpleMessage("Members"),
    "microlearningActivity": MessageLookupByLibrary.simpleMessage(
      "Microlearning activity",
    ),
    "missingRequiredAnswers": MessageLookupByLibrary.simpleMessage(
      "Answer required questions",
    ),
    "morning": MessageLookupByLibrary.simpleMessage("Morning"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameRequired": MessageLookupByLibrary.simpleMessage("Name is required."),
    "newPassword": MessageLookupByLibrary.simpleMessage("New password"),
    "night": MessageLookupByLibrary.simpleMessage("Night"),
    "noFamilyCirclesYet": MessageLookupByLibrary.simpleMessage(
      "You don\'t have any family circles yet.",
    ),
    "noRoutinesFound": MessageLookupByLibrary.simpleMessage(
      "No routines found.",
    ),
    "noRoutinesYet": MessageLookupByLibrary.simpleMessage(
      "You don\'t have any routines yet.",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "or": MessageLookupByLibrary.simpleMessage("or"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordMinLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters.",
    ),
    "passwordRequired": MessageLookupByLibrary.simpleMessage(
      "Password is required.",
    ),
    "passwordTooShort": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters.",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "patientName": MessageLookupByLibrary.simpleMessage("Patient name"),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Personal information",
    ),
    "practiceActivity": MessageLookupByLibrary.simpleMessage(
      "Practice activity",
    ),
    "profileUpdateError": MessageLookupByLibrary.simpleMessage(
      "Error updating profile: ",
    ),
    "profileUpdated": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully",
    ),
    "recommendedRoutines": MessageLookupByLibrary.simpleMessage(
      "Recommended routines",
    ),
    "routine": MessageLookupByLibrary.simpleMessage("Routine"),
    "routineCategoriesScoresHelpText": MessageLookupByLibrary.simpleMessage(
      "All the areas in which this routine helps you.",
    ),
    "routinesUpdateError": MessageLookupByLibrary.simpleMessage(
      "Error updating routines: ",
    ),
    "routinesUpdated": MessageLookupByLibrary.simpleMessage(
      "Routines updated successfully",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "selectAtLeastOneOption": MessageLookupByLibrary.simpleMessage(
      "Select at least one option.",
    ),
    "selectFamilyCircle": MessageLookupByLibrary.simpleMessage(
      "Select a family circle",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shareFamilyCirclePinDescription": MessageLookupByLibrary.simpleMessage(
      "Share the code with other caregivers to help together in the patient\'s well-being.",
    ),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signInTitle": MessageLookupByLibrary.simpleMessage("Sign in"),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
    "skip": MessageLookupByLibrary.simpleMessage("Skip for now"),
    "startNow": MessageLookupByLibrary.simpleMessage("Start now"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "tomorrow": MessageLookupByLibrary.simpleMessage("Tomorrow"),
    "userNotAuthenticated": MessageLookupByLibrary.simpleMessage(
      "User not authenticated",
    ),
    "whatWillWeDo": MessageLookupByLibrary.simpleMessage("What will we do?"),
    "whatYouWillLearn": MessageLookupByLibrary.simpleMessage(
      "What you will learn?",
    ),
    "world": MessageLookupByLibrary.simpleMessage("Hello world!"),
  };
}
