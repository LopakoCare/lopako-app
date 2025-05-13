import 'package:flutter/material.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileController _controller;
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController(context);
    _controller.loadUserData();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.editProfile),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar circular
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      initialValue: _controller.name,
                      decoration: InputDecoration(labelText: localizations.name),
                      onChanged: (v) => _controller.name = v,
                      validator: (v) => v == null || v.isEmpty ? localizations.nameRequired : null,
                    ),
                    TextFormField(
                      initialValue: _controller.age?.toString(),
                      decoration: InputDecoration(labelText: localizations.age),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _controller.age = int.tryParse(v),
                      validator: (v) => v == null || v.isEmpty ? localizations.ageRequired : null,
                    ),
                    TextFormField(
                      initialValue: _controller.familyId,
                      decoration: InputDecoration(
                        labelText: 'ID de Familia',
                        helperText: 'Introduce el ID de la familia a la que quieres unirte',
                      ),
                      onChanged: (v) => _controller.familyId = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) return null; // El family_id es opcional
                        return null; // La validación real se hará al guardar
                      },
                    ),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(labelText: localizations.password),
                      obscureText: true,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6) {
                          return localizations.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(labelText: localizations.password + ' (confirmar)'),
                      obscureText: true,
                      validator: (v) {
                        if (_newPasswordController.text.isNotEmpty && v != _newPasswordController.text) {
                          return localizations.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_newPasswordController.text.isNotEmpty &&
                                _newPasswordController.text == _confirmPasswordController.text) {
                              _controller.password = _newPasswordController.text;
                            } else {
                              _controller.password = null;
                            }
                            final result = await _controller.saveChanges();
                            if (result == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(localizations.profileUpdated))
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result))
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations.saveChanges,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
