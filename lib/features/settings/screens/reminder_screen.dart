import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/reminder_controller.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late final ReminderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReminderController();
    _controller.loadReminderSettings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _controller.selectedTime,
    );
    if (picked != null && picked != _controller.selectedTime) {
      await _controller.updateTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recordatorio diario'),
          centerTitle: true,
        ),
        body: Consumer<ReminderController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Activar recordatorio',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: controller.reminderEnabled,
                                  onChanged:
                                      (value) =>
                                          controller.toggleReminder(value),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hora: ${controller.selectedTime.format(context)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: ElevatedButton(
                                    onPressed:
                                        controller.reminderEnabled
                                            ? _pickTime
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B5CF6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cambiar hora',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (controller.reminderEnabled) ...[
                      const SizedBox(height: 16),
                      const Card(
                        color: Color(0xFFE8F5E9),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            '¡Recibirás un recordatorio diario a la hora seleccionada!',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Pruebas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed:
                                  () => controller.showTestNotification(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Probar notificación instantánea',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed:
                                  () =>
                                      controller
                                          .showScheduledTestNotification(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Probar notificación programada (1 min)',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
