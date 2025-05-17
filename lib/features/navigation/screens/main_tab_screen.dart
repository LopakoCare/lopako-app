import 'package:flutter/material.dart';

// import 'package:flutter_gen/gen_l10n/intl_localizations.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/generated/l10n.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../../routines/screens/home_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../chatbot/screens/chatbot_screen.dart';
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
    // Initialize _tabController FIRST with the correct length
    // _currentIndex is 0 by default, which will be used as initialIndex
    _tabController = TabController(
      length: 4, // CORRECTED: Set to the actual number of tabs
      vsync: this,
      initialIndex: _currentIndex,
    );

    // Add listener immediately after initialization
    _tabController.addListener(_handleTabSelection);

    // THEN load the last saved tab
    _loadLastTab();
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the saved index, default to 0 if not found or null.
    final savedIndex = prefs.getInt('selectedTab') ?? 0;

    // Check if the widget is still mounted before calling setState.
    if (mounted) {
      setState(() {
        // Validate the savedIndex to be within the bounds of the TabController.
        // If out of bounds, default to 0 (the first tab).
        if (savedIndex >= 0 && savedIndex < _tabController.length) {
          _currentIndex = savedIndex;
        } else {
          _currentIndex = 0;
        }
        // Update the TabController's active index.
        // _tabController is guaranteed to be initialized here due to the order in initState.
        _tabController.index = _currentIndex;
      });
    }
  }

  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
      _saveSelectedTab(_currentIndex);
    });
  }

  Future<void> _saveSelectedTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedTab', index);
  }

  @override
  Widget build(BuildContext context) {
    // Use S.of(context) which is configured for your project
    final localizations = S.of(context); 
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(key: PageStorageKey('routines')), // Use HomeScreen instead of RoutinesScreen
          CalendarScreen(key: PageStorageKey('calendar')),
          ChatbotScreen(key: PageStorageKey('chatbot')),
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
          type: BottomNavigationBarType.fixed,
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
              icon: Icon(Icons.chat),
              label: "Chatbot", // Temporarily hardcoded label
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