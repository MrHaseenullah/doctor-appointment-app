import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';

class SlotManagement extends StatefulWidget {
  const SlotManagement({super.key});

  @override
  State<SlotManagement> createState() => _SlotManagementState();
}

class _SlotManagementState extends State<SlotManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
    hour: TimeOfDay.now().hour + 1,
    minute: TimeOfDay.now().minute,
  );
  int _durationMinutes = 30;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: const CustomAppBar(title: 'Manage Time Slots'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Selector
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.7,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat(
                              'EEEE, MMMM d, yyyy',
                            ).format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        NeumorphicButton(
                          style: const NeumorphicStyle(
                            depth: 4,
                            boxShape: NeumorphicBoxShape.circle(),
                          ),
                          padding: const EdgeInsets.all(12),
                          onPressed: _selectDate,
                          child: const Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Time Range Selector
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.7,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Time Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Time'),
                              const SizedBox(height: 8),
                              NeumorphicButton(
                                style: NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.7,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                onPressed: () => _selectTime(true),
                                child: Text(
                                  _startTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Time'),
                              const SizedBox(height: 8),
                              NeumorphicButton(
                                style: NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.7,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                onPressed: () => _selectTime(false),
                                child: Text(
                                  _endTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Duration Selector
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.7,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDurationOption(15),
                        _buildDurationOption(30),
                        _buildDurationOption(45),
                        _buildDurationOption(60),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Create Slots Button
              SizedBox(
                width: double.infinity,
                child: NeumorphicButton(
                  style: NeumorphicStyle(
                    depth: 8,
                    intensity: 0.7,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed:
                      _isLoading
                          ? null
                          : () => _createTimeSlots(user?.uid ?? ''),
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const Text(
                            'Create Time Slots',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationOption(int minutes) {
    final isSelected = _durationMinutes == minutes;

    return GestureDetector(
      onTap: () {
        setState(() {
          _durationMinutes = minutes;
        });
      },
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: isSelected ? -4 : 4,
          intensity: 0.7,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          '$minutes min',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;

          // Ensure end time is after start time
          final startDateTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _startTime.hour,
            _startTime.minute,
          );

          final endDateTime = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _endTime.hour,
            _endTime.minute,
          );

          if (endDateTime.isBefore(startDateTime) ||
              endDateTime.isAtSameMomentAs(startDateTime)) {
            // Set end time to be 1 hour after start time
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  Future<void> _createTimeSlots(String doctorId) async {
    // Validate inputs
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    if (startDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot create slots in the past')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate time slots
      final slots = <DateTime>[];
      DateTime currentSlot = startDateTime;

      while (currentSlot
              .add(Duration(minutes: _durationMinutes))
              .isBefore(endDateTime) ||
          currentSlot
              .add(Duration(minutes: _durationMinutes))
              .isAtSameMomentAs(endDateTime)) {
        slots.add(currentSlot);
        currentSlot = currentSlot.add(Duration(minutes: _durationMinutes));
      }

      // Save slots to Firestore
      final batch = _firestore.batch();

      for (final slotTime in slots) {
        final slotRef = _firestore.collection('slots').doc();
        batch.set(slotRef, {
          'doctorId': doctorId,
          'dateTime': slotTime,
          'durationMinutes': _durationMinutes,
          'isBooked': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created ${slots.length} time slots')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating slots: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
