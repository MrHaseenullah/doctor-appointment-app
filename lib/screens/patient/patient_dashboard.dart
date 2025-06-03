import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../login_screen.dart';
import 'book_appointment.dart';
import 'appointment_history.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: CustomAppBar(
        title: 'Patient Dashboard',
        actions: [
          NeumorphicButton(
            style: const NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
              depth: 2,
            ),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            onPressed: () async {
              await authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Icon(Icons.logout, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Card
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 4,
                  intensity: 0.7,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Neumorphic(
                      style: const NeumorphicStyle(
                        depth: 4,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ??
                                user?.email?.split('@').first ??
                                'Patient',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Book Appointment',
                      Icons.calendar_today,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BookAppointment(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      'View History',
                      Icons.history,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AppointmentHistory(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Upcoming Appointments
              const Text(
                'Upcoming Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getUpcomingAppointmentsStream(user?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final appointments = snapshot.data?.docs ?? [];

                    if (appointments.isEmpty) {
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
                                Icons.calendar_today,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No upcoming appointments',
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
                                  boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const BookAppointment(),
                                    ),
                                  );
                                },
                                child: const Text('Book Now'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment =
                            appointments[index].data() as Map<String, dynamic>;
                        final doctorName =
                            appointment['doctorName'] ?? 'Unknown Doctor';
                        final dateTime =
                            (appointment['dateTime'] as Timestamp).toDate();
                        final formattedDate = DateFormat(
                          'MMM dd, yyyy',
                        ).format(dateTime);
                        final formattedTime = DateFormat(
                          'hh:mm a',
                        ).format(dateTime);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              depth: 4,
                              intensity: 0.7,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dr. $doctorName',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              formattedTime,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  NeumorphicButton(
                                    style: const NeumorphicStyle(
                                      depth: 4,
                                      boxShape: NeumorphicBoxShape.circle(),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    onPressed:
                                        () => _cancelAppointment(
                                          appointments[index].id,
                                        ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.7,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getUpcomingAppointmentsStream(String patientId) {
    final now = DateTime.now();

    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('dateTime', isGreaterThanOrEqualTo: now)
        .orderBy('dateTime')
        .limit(10)
        .snapshots();
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      // Get the appointment to retrieve the slot ID
      final appointmentDoc =
          await _firestore.collection('appointments').doc(appointmentId).get();
      final appointmentData = appointmentDoc.data();

      if (appointmentData != null && appointmentData.containsKey('slotId')) {
        final slotId = appointmentData['slotId'];

        // Update the slot to be available again
        await _firestore.collection('slots').doc(slotId).update({
          'isBooked': false,
        });
      }

      // Delete the appointment
      await _firestore.collection('appointments').doc(appointmentId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling appointment: $e')),
      );
    }
  }
}
