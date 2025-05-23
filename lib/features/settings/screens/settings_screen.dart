import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/auth/controllers/auth_controller.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import 'package:lopako_app_lis/features/family_circles/screens/edit_family_circle_screen.dart';
import 'package:lopako_app_lis/features/family_circles/screens/new_family_circle_screen.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/settings/screens/edit_account_screen.dart';
import 'package:lopako_app_lis/features/settings/widgets/family_circle_item_widget.dart';
import 'package:lopako_app_lis/features/settings/widgets/profile_option_item_widget.dart';
import 'package:lopako_app_lis/features/settings/widgets/settings_item_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  final AppUser user;
  final List<FamilyCircle> familyCircles;
  final void Function(AppUser updatedUser) onUserUpdated;

  const SettingsScreen({super.key, required this.user, required this.familyCircles, required this.onUserUpdated});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final AuthController _authController = AuthController();

  final _scrollCtrl = ScrollController();
  double _topPos = 0;

  static const double _headerContentHeight = 200.0;
  late double _statusBarHeight;
  late double _fullHeaderHeight;
  late double _initialTop;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statusBarHeight = MediaQuery.of(context).padding.top;
    _fullHeaderHeight = _headerContentHeight + _statusBarHeight;
    _initialTop = _fullHeaderHeight;
    _topPos = _initialTop;
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;
    final effectiveOffset = offset.clamp(0.0, _initialTop);
    final newTop = (_initialTop - effectiveOffset).clamp(0.0, _initialTop);
    if (newTop != _topPos) {
      setState(() => _topPos = newTop);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary[50],
      body: SizedBox.expand(
        child: Stack(
          children: [
            Container(
              height: _fullHeaderHeight,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(top: _statusBarHeight + 16, bottom: 16, left: 16, right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileOptionItem(
                    title: widget.user.name,
                    subtitle: widget.user.email,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditAccountScreen(
                          user: widget.user,
                          onSave: (newUser) {
                            widget.onUserUpdated(newUser);
                          },
                        ),
                      ));
                    },
                  ),
                ]
              )
            ),
            Positioned(
              top: _topPos,
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    controller: _scrollCtrl,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: _headerContentHeight - _topPos + _statusBarHeight + 16, bottom: 64, left: 16, right: 16),
                    children: [
                      Text(
                        localizations.familyCircles,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.familyCircles.map((circle) {
                        return FamilyCircleItem(
                          familyCircle: circle,
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EditFamilyCircleScreen(
                                currentUser: widget.user,
                                familyCircle: circle,
                                onSave: (updatedCircle) {
                                  Navigator.pop(context);
                                  setState(() {
                                    widget.familyCircles[widget.familyCircles.indexOf(circle)] = updatedCircle;
                                  });
                                },
                              ),
                            ));
                          },
                        );
                      }),
                      SettingsItem(
                        title: localizations.addFamilyCircle,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewFamilyCircleScreen(
                              onComplete: (newCircle) {
                                setState(() {
                                  widget.familyCircles.add(newCircle);
                                });
                              },
                            )),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        localizations.settings,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SettingsItem(
                        icon: FontAwesomeIcons.arrowRightFromBracket,
                        title: localizations.logout,
                        onTap: () async {
                          await _authController.logout();
                          if (!mounted) return;
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        hideArrow: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}