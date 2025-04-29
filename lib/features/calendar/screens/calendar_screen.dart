import 'package:flutter/material.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.calendar),
      ),
      body: Center(
        child: Text(localizations.world),
      ),
    );
  }
}
