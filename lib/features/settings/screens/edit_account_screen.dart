import 'package:flutter/material.dart';
import 'package:lopako_app_lis/features/auth/controllers/auth_controller.dart';
import 'package:lopako_app_lis/features/auth/controllers/user_controller.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class EditAccountScreen extends StatefulWidget {
  final AppUser user;
  final void Function(AppUser updatedUser)? onSave;

  const EditAccountScreen({
    Key? key,
    required this.user,
    this.onSave,
  }) : super(key: key);

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();

  bool _isSaving = false;
  bool _isUsingPassword = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _ageController.text = widget.user.age?.toString() ?? '';
    _isUsingPassword = _authController.isUsingPassword();

    // Listeners to update save button state
    _nameController.addListener(() => setState(() {}));
    _ageController.addListener(() => setState(() {}));
    _currentPasswordController.addListener(() => setState(() {}));
    _newPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  bool get _infoChanged {
    if (_nameController.text != widget.user.name) return true;
    if (_ageController.text != (widget.user.age?.toString() ?? '')) return true;
    return false;
  }

  bool get _passwordSectionFilled {
    return _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    AppUser updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
    );
    try {
      updated = await _userController.edit(updated);

      if (_passwordSectionFilled) {
        await _authController.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
      }

      if (widget.onSave != null) {
        widget.onSave!(updated);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.editAccount),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.personalInformation, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.name,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                textCapitalization: TextCapitalization.words,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => v == null || v.trim().isEmpty ? loc.nameRequired : null,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: loc.age,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return loc.invalidAge;
                  }
                  return null;
                },
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
              ),

              if (_isUsingPassword) ...[
                const SizedBox(height: 32),
                Text(loc.changePassword, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: loc.currentPassword,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (_passwordSectionFilled && (v == null || v.isEmpty)) {
                      return loc.passwordRequired;
                    }
                    return null;
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: loc.newPassword,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (_passwordSectionFilled) {
                      if (v == null || v.length < 6) return loc.passwordMinLength;
                    }
                    return null;
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: loc.confirmPassword,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (_passwordSectionFilled) {
                      if (v != _newPasswordController.text) return loc.passwordsDoNotMatch;
                    }
                    return null;
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: !_isSaving && (_infoChanged || _passwordSectionFilled)
              ? _save
              : null,
            child: Text(loc.save),
          ),
        ),
      ),
    );
  }
}
