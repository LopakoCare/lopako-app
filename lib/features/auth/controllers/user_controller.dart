import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/core/services/user_service.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';

class UserController extends ChangeNotifier {
  final UserService _userService;

  UserController()
      : _userService = ServiceManager.instance.getService('user') as UserService;

  /// Edit the user with the given [user].
  Future<AppUser> edit(AppUser user) async {
    AppUser? updatedUser;
    try {
      updatedUser = await _userService.edit(user);
    } catch (e) {
      throw Exception('No se ha podido editar el usuario. Por favor, inténtelo de nuevo.');
    }
    return updatedUser;
  }
}
