import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calendar widget will go here
            Card(
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2030),  // Changed from 2025 to 2030 to ensure it's after initialDate
                onDateChanged: (date) {
                  // Handle date selection
                  print('Selected date: $date');
                },
              ),
            ),
            SizedBox(height: 20),
            // Events list will go here
            Expanded(
              child: ListView.builder(
                itemCount: 0, // Will be replaced with actual events
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Event Title'),
                    subtitle: Text('Event Description'),
                    leading: Icon(Icons.event),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new event
        },
        child: Icon(Icons.add),
      ),
    );
  }
}