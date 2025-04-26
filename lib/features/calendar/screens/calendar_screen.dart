import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import 'package:provider/provider.dart';
import '../controllers/calendar_controller.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController controller;

  final List<Map<String, dynamic>> eventIcons = [
    {'value': 'medication', 'icon': Icons.medical_services, 'label': 'Medicación', 'color': Colors.redAccent.shade100},
    {'value': 'meal', 'icon': Icons.restaurant, 'label': 'Comida', 'color': Colors.orangeAccent.shade100},
    {'value': 'meeting', 'icon': Icons.people, 'label': 'Reunión', 'color': Colors.lightBlueAccent.shade100},
    {'value': 'exercise', 'icon': Icons.fitness_center, 'label': 'Ejercicio', 'color': Colors.greenAccent.shade100},
    {'value': 'rest', 'icon': Icons.bedtime, 'label': 'Descanso', 'color': Colors.purpleAccent.shade100},
    {'value': 'hydration', 'icon': Icons.local_drink, 'label': 'Hidratación', 'color': Colors.cyanAccent.shade100},
    {'value': 'meditation', 'icon': Icons.self_improvement, 'label': 'Meditación', 'color': Colors.pinkAccent.shade100},
  ];

  final List<String> suggestions = [
    'Dar medicación',
    'Hora de beber agua',
    'Pequeño paseo',
    'Tiempo de descanso',
    'Comida ligera',
    'Ejercicio suave',
    'Llamar a un familiar',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = Provider.of<CalendarController>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(DateFormat('MMMM yyyy', 'es_ES').format(controller.selectedDate).toUpperCase()),
      ),
      body: Consumer<CalendarController>(
        builder: (context, controller, child) {
          final groupedEvents = controller.eventsByDate;
          final hasEvents = groupedEvents.isNotEmpty;
          return hasEvents
              ? ListView(
            padding: const EdgeInsets.all(10),
            children: _buildCalendarView(controller),
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text('No tienes recordatorios aún', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showAddEventDialog(context),
                  child: const Text('Agregar primer recordatorio'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildCalendarView(CalendarController controller) {
    final groupedEvents = controller.eventsByDate;
    final dates = groupedEvents.keys.map(DateTime.parse).toList()..sort();

    return dates
        .where((date) => date.month == controller.selectedDate.month)
        .map((date) => _buildDaySection(date, groupedEvents[DateFormat('yyyy-MM-dd').format(date)]!))
        .toList();
  }

  Widget _buildDaySection(DateTime date, List<EventModel> events) {
    final morningEvents = events.where((e) => e.date.hour < 12).toList();
    final afternoonEvents = events.where((e) => e.date.hour >= 12 && e.date.hour < 18).toList();
    final eveningEvents = events.where((e) => e.date.hour >= 18).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            DateFormat('EEEE d', 'es_ES').format(date).toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (morningEvents.isNotEmpty) ...[
          Row(
            children: const [
              Icon(Icons.wb_sunny_outlined, size: 20),
              SizedBox(width: 6),
              Text('Mañana', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          ...morningEvents.map((event) => _buildEventCard(event)),
        ],
        if (afternoonEvents.isNotEmpty) ...[
          Row(
            children: const [
              Icon(Icons.wb_twilight, size: 20),
              SizedBox(width: 6),
              Text('Tarde', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          ...afternoonEvents.map((event) => _buildEventCard(event)),
        ],
        if (eveningEvents.isNotEmpty) ...[
          Row(
            children: const [
              Icon(Icons.nights_stay_outlined, size: 20),
              SizedBox(width: 6),
              Text('Noche', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          ...eveningEvents.map((event) => _buildEventCard(event)),
        ],
      ],
    );
  }

  Widget _buildPeriodSection(String title, List<EventModel> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        ...events.map((event) => _buildEventCard(event)).toList(),
      ],
    );
  }

  Widget _buildEventCard(EventModel event) {
    final endTime = event.date.add(Duration(minutes: event.durationMinutes ?? 60));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _getBackgroundColor(event.iconType),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(_getIconData(event.iconType)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("${DateFormat('HH:mm').format(event.date)} - ${DateFormat('HH:mm').format(event.date.add(Duration(minutes: event.durationMinutes ?? 60)))}"),
            ],
          )
        ],
      ),
    );
  }

  Color _getBackgroundColor(String iconType) {
    final match = eventIcons.firstWhere(
          (icon) => icon['value'] == iconType,
      orElse: () => {'color': Colors.grey.shade300},
    );
    return match['color'];
  }

  IconData _getIconData(String iconType) {
    switch (iconType) {
      case 'medication':
        return Icons.medical_services;
      case 'meal':
        return Icons.restaurant;
      case 'meeting':
        return Icons.people;
      case 'exercise':
        return Icons.fitness_center;
      case 'rest':
        return Icons.bedtime;
      case 'hydration':
        return Icons.local_drink;
      case 'meditation':
        return Icons.self_improvement;
      default:
        return Icons.event;
    }
  }

  Future<Duration?> showDurationPicker({required BuildContext context, required Duration initialTime}) async {
    Duration? selectedDuration;
    await showDialog(
      context: context,
      builder: (context) {
        int minutes = initialTime.inMinutes;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecciona duración'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$minutes minutos'),
                  Slider(
                    min: 5,
                    max: 180,
                    divisions: 35,
                    value: minutes.toDouble(),
                    label: '$minutes min',
                    onChanged: (value) {
                      setState(() {
                        minutes = (value / 5).round() * 5;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    selectedDuration = Duration(minutes: minutes);
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
    return selectedDuration;
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedIcon = 'medication';
    TimeOfDay selectedTime = TimeOfDay.now();
    Duration selectedDuration = const Duration(hours: 1);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nuevo recordatorio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título del recordatorio'),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: suggestions.map((s) => ActionChip(
                        label: Text(s),
                        onPressed: () {
                          setState(() {
                            titleController.text = s;
                          });
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedIcon,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedIcon = value;
                          });
                        }
                      },
                      items: eventIcons
                          .map<DropdownMenuItem<String>>((iconData) => DropdownMenuItem<String>(
                        value: iconData['value'] as String,
                        child: Row(
                          children: [
                            Icon(iconData['icon']),
                            const SizedBox(width: 8),
                            Text(iconData['label']),
                          ],
                        ),
                      ))
                          .toList(),
                    ),
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Text('Hora: ${selectedTime.format(context)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final Duration? pickedDuration = await showDurationPicker(
                          context: context,
                          initialTime: selectedDuration,
                        );
                        if (pickedDuration != null) {
                          setState(() {
                            selectedDuration = pickedDuration;
                          });
                        }
                      },
                      child: Text('Duración: ${selectedDuration.inMinutes} minutos'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final now = controller.selectedDate;
                      final eventDate = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      controller.addEvent(
                        titleController.text,
                        eventDate,
                        selectedIcon,
                        selectedDuration.inMinutes
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
