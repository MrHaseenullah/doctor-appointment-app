import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';

class BookAppointment extends StatefulWidget {
  const BookAppointment({super.key});

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedDoctorId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: const CustomAppBar(title: 'Book Appointment'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Selector
              const Text(
                'Select Doctor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: _getDoctorsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final doctors = snapshot.data?.docs ?? [];

                  if (doctors.isEmpty) {
                    return const Center(child: Text('No doctors available'));
                  }

                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        final doctor =
                            doctors[index].data() as Map<String, dynamic>;
                        final doctorId = doctors[index].id;
                        final doctorName = doctor['name'] ?? 'Unknown Doctor';
                        final isSelected = _selectedDoctorId == doctorId;

                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDoctorId = doctorId;
                              });
                            },
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                depth: isSelected ? -4 : 4,
                                intensity: 0.7,
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(12),
                                ),
                                color:
                                    isSelected
                                        ? Colors.blue.withOpacity(0.1)
                                        : null,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Dr. $doctorName',
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isSelected
                                              ? Colors.blue
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Date Selector
              Row(
                children: [
                  const Text(
                    'Select Date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
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
              const SizedBox(height: 12),

              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.7,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Available Slots
              const Text(
                'Available Time Slots',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child:
                    _selectedDoctorId == null
                        ? const Center(
                          child: Text('Please select a doctor first'),
                        )
                        : StreamBuilder<QuerySnapshot>(
                          stream: _getAvailableSlotsStream(
                            _selectedDoctorId!,
                            _selectedDate,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            final slots = snapshot.data?.docs ?? [];

                            if (slots.isEmpty) {
                              return Center(
                                child: Neumorphic(
                                  style: NeumorphicStyle(
                                    depth: 4,
                                    intensity: 0.7,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No available slots for this date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      NeumorphicButton(
                                        style: NeumorphicStyle(
                                          depth: 4,
                                          intensity: 0.7,
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                BorderRadius.circular(8),
                                              ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 24,
                                        ),
                                        onPressed: _selectDate,
                                        child: const Text('Try Another Date'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: slots.length,
                              itemBuilder: (context, index) {
                                final slot =
                                    slots[index].data() as Map<String, dynamic>;
                                final slotId = slots[index].id;
                                final dateTime =
                                    (slot['dateTime'] as Timestamp).toDate();
                                final formattedTime = DateFormat(
                                  'hh:mm a',
                                ).format(dateTime);
                                final durationMinutes =
                                    slot['durationMinutes'] as int? ?? 30;

                                return NeumorphicButton(
                                  style: NeumorphicStyle(
                                    depth: 4,
                                    intensity: 0.7,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () => _bookAppointment(
                                            slotId,
                                            user?.uid ?? '',
                                            _selectedDoctorId!,
                                          ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$durationMinutes min',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getDoctorsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots();
  }

  Stream<QuerySnapshot> _getAvailableSlotsStream(
    String doctorId,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('slots')
        .where('doctorId', isEqualTo: doctorId)
        .where('isBooked', isEqualTo: false)
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThanOrEqualTo: endOfDay)
        .orderBy('dateTime')
        .snapshots();
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

  Future<void> _bookAppointment(
    String slotId,
    String patientId,
    String doctorId,
  ) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get slot details
      final slotDoc = await _firestore.collection('slots').doc(slotId).get();
      final slotData = slotDoc.data();

      if (slotData == null) {
        throw Exception('Slot not found');
      }

      if (slotData['isBooked'] == true) {
        throw Exception('Slot already booked');
      }

      // Get doctor details
      final doctorDoc =
          await _firestore.collection('users').doc(doctorId).get();
      final doctorData = doctorDoc.data();

      if (doctorData == null) {
        throw Exception('Doctor not found');
      }

      // Get patient details
      final patientDoc =
          await _firestore.collection('users').doc(patientId).get();
      final patientData = patientDoc.data();

      if (patientData == null) {
        throw Exception('Patient not found');
      }

      // Create appointment
      await _firestore.collection('appointments').add({
        'slotId': slotId,
        'patientId': patientId,
        'doctorId': doctorId,
        'dateTime': slotData['dateTime'],
        'durationMinutes': slotData['durationMinutes'],
        'patientName': patientData['name'],
        'doctorName': doctorData['name'],
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update slot to be booked
      await _firestore.collection('slots').doc(slotId).update({
        'isBooked': true,
        'patientId': patientId,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error booking appointment: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
