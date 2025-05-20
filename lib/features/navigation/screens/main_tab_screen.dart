import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/auth/controllers/auth_controller.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routines/screens/home_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainTabScreen extends StatefulWidget {
  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with SingleTickerProviderStateMixin {

  final FamilyCirclesController _familyCirclesController = FamilyCirclesController();
  final AuthController _authController = AuthController();

  late TabController _tabController;
  int _currentIndex = 0;

  List<FamilyCircle> familyCircles = [];
  bool _isFamilyCirclesLoading = false;
  bool _isCurrentUserLoading = false;
  bool get isLoading => _isFamilyCirclesLoading || _isCurrentUserLoading;

  AppUser? user;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _currentIndex,
    )..addListener(_handleTabSelection);

    _fetchFamilyCircles();
    _fetchCurrentUser();
    _loadLastTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('last_tab_index') ?? 0;
    if (!mounted) return;
    setState(() => _currentIndex = saved);
    _tabController.index = saved;
  }

  Future<void> _fetchFamilyCircles() async {
    if (!mounted) return;
    setState(() => _isFamilyCirclesLoading = true);

    final circles = await _familyCirclesController.getFamilyCircles();
    if (!mounted) return;
    setState(() {
      familyCircles = circles;
      _isFamilyCirclesLoading = false;
    });
  }

  Future<void> _fetchCurrentUser() async {
    if (!mounted) return;
    setState(() => _isCurrentUserLoading = true);

    final u = await _authController.getUser();
    if (!mounted) return;
    setState(() {
      user = u;
      _isCurrentUserLoading = false;
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final newIndex = _tabController.index;
      if (mounted) {
        setState(() => _currentIndex = newIndex);
      }
      _saveSelectedTab(newIndex);
    }
  }

  Future<void> _saveSelectedTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_tab_index', index);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    return Scaffold(
      body: _isFamilyCirclesLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(
              key: PageStorageKey('routines'),
              familyCircles: familyCircles,
            ),
            CalendarScreen(
              key: PageStorageKey('calendar')
            ),
            SettingsScreen(
              key: PageStorageKey('settings'),
              user: user!,
              familyCircles: familyCircles,
              onUserUpdated: (updatedUser) {
                setState(() {
                  user = updatedUser;
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.neutral[100]!,
                width: 2.0,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              _tabController.animateTo(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house),
                label: localizations.home,
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.calendarDay),
                label: localizations.calendar,
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.gear),
                label: localizations.settings,
              ),
            ],
          ),
        ),
    );
  }
}
