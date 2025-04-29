import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import '../../home/screens/home_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainTabScreen extends StatefulWidget {
  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLastTab();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(_handleTabSelection);
  }

  Future<void> _loadLastTab() async {
    // TODO: Implementar lógica para cargar la última pestaña
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      _saveSelectedTab(_currentIndex);
    }
  }

  Future<void> _saveSelectedTab(int index) async {
    // TODO: Implementar lógica para guardar la pestaña seleccionada
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(key: PageStorageKey('home')),
          CalendarScreen(key: PageStorageKey('calendar')),
          SettingsScreen(key: PageStorageKey('settings')),
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
      )
    );
  }
}
