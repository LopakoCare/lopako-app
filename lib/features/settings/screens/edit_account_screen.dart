import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/auth/controllers/auth_controller.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import 'package:lopako_app_lis/features/family_circles/screens/new_family_circle_screen.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/settings/screens/edit_profile_screen.dart';
import 'package:lopako_app_lis/features/settings/widgets/family_circle_item_widget.dart';
import 'package:lopako_app_lis/features/settings/widgets/profile_option_item_widget.dart';
import 'package:lopako_app_lis/features/settings/widgets/settings_item_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final AuthController _authController = AuthController();
  User? user;

  final FamilyCirclesController _familyCirclesController = FamilyCirclesController();
  List<FamilyCircle> familyCircles = [];

  final _scrollCtrl = ScrollController();
  double _topPos = 0;

  static const double _headerContentHeight = 200.0;
  late double _statusBarHeight;
  late double _fullHeaderHeight;
  late double _initialTop;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchFamilyCircles();
    _scrollCtrl.addListener(_onScroll);
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await _authController.getUser();
      setState(() {
        this.user = user;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchFamilyCircles() async {
    try {
      final circles = await _familyCirclesController.getFamilyCircles();
      setState(() {
        familyCircles = circles;
      });
    } catch (e) {
      // Handle error
    }
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
                    title: user == null ? localizations.loading : user!.name,
                    subtitle: user?.email,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
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
                      ...familyCircles.map((circle) {
                        return FamilyCircleItem(
                          familyCircle: circle,
                        );
                      }),
                      SettingsItem(
                        title: localizations.addFamilyCircle,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NewFamilyCircleScreen()),
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