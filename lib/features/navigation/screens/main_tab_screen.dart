import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import '../../routines/screens/home_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../chatbot/screens/chatbot_screen.dart';  // Add this import

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
      length: 4,  // Updated to include chatbot
      vsync: this,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          RoutinesScreen(key: PageStorageKey('routines')),
          CalendarScreen(key: PageStorageKey('calendar')),
          ChatbotScreen(key: PageStorageKey('chatbot')),
          SettingsScreen(key: PageStorageKey('settings')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,  // Added to support 4 items
        onTap: (index) {
          _tabController.animateTo(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: localizations.calendar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: localizations.chatbot,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: localizations.settings,
          ),
        ],
      ),
    );
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
}
