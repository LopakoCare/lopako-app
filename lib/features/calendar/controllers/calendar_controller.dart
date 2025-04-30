import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventModel {
  final String title;
  final DateTime date;
  final String iconType;
  final int durationMinutes;

  EventModel({
    required this.title,
    required this.date,
    required this.iconType,
    required this.durationMinutes,
  });
}

class CalendarController extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  List<EventModel> events = [];

  Map<String, List<EventModel>> get eventsByDate {
    Map<String, List<EventModel>> groupedEvents = {};
    for (var event in events) {
      String dateKey = DateFormat('yyyy-MM-dd').format(event.date);
      if (groupedEvents.containsKey(dateKey)) {
        groupedEvents[dateKey]!.add(event);
      } else {
        groupedEvents[dateKey] = [event];
      }
    }
    return groupedEvents;
  }

  void addEvent(String title, DateTime date, String iconType, int durationMinutes) {
    events.add(EventModel(title: title, date: date, iconType: iconType, durationMinutes: durationMinutes));
    notifyListeners();
  }

  void removeEvent(EventModel event) {
    events.remove(event);
    notifyListeners();
  }

  void updateEvent(EventModel oldEvent, EventModel newEvent) {
    int index = events.indexOf(oldEvent);
    if (index != -1) {
      events[index] = newEvent;
      notifyListeners();
    }
  }

  void changeMonth(int increment) {
    selectedDate = DateTime(
      selectedDate.year,
      selectedDate.month + increment,
    );
    notifyListeners();
  }
}
