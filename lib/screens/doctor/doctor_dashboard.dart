import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../login_screen.dart';
import 'slot_management.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: CustomAppBar(
        title: 'Doctor Dashboard',
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
              // Doctor Info Card
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
                            'Dr. ${user?.displayName ?? user?.email?.split('@').first ?? 'Doctor'}',
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

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Today\'s Appointments',
                      StreamBuilder<QuerySnapshot>(
                        stream: _getTodayAppointmentsStream(user?.uid ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('...');
                          }
                          return Text(
                            '${snapshot.data?.docs.length ?? 0}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Available Slots',
                      StreamBuilder<QuerySnapshot>(
                        stream: _getAvailableSlotsStream(user?.uid ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('...');
                          }
                          return Text(
                            '${snapshot.data?.docs.length ?? 0}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                      Icons.access_time,
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
                          child: const Text(
                            'No upcoming appointments',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment =
                            appointments[index].data() as Map<String, dynamic>;
                        final patientName =
                            appointment['patientName'] ?? 'Unknown Patient';
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
                                          patientName,
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
      floatingActionButton: NeumorphicFloatingActionButton(
        style: const NeumorphicStyle(
          depth: 8,
          intensity: 0.7,
          boxShape: NeumorphicBoxShape.circle(),
        ),
        child: const Icon(Icons.add, size: 30),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SlotManagement()));
        },
      ),
    );
  }

  Widget _buildStatCard(String title, Widget value, IconData icon) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 4,
        intensity: 0.7,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          value,
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getTodayAppointmentsStream(String doctorId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('dateTime', isLessThanOrEqualTo: endOfDay)
        .snapshots();
  }

  Stream<QuerySnapshot> _getAvailableSlotsStream(String doctorId) {
    final now = DateTime.now();

    return _firestore
        .collection('slots')
        .where('doctorId', isEqualTo: doctorId)
        .where('isBooked', isEqualTo: false)
        .where('dateTime', isGreaterThanOrEqualTo: now)
        .snapshots();
  }

  Stream<QuerySnapshot> _getUpcomingAppointmentsStream(String doctorId) {
    final now = DateTime.now();

    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('dateTime', isGreaterThanOrEqualTo: now)
        .orderBy('dateTime')
        .limit(10)
        .snapshots();
  }
}
