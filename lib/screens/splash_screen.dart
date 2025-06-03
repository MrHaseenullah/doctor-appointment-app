import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'doctor/doctor_dashboard.dart';
import 'patient/patient_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Simulate a delay for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isAuthenticated) {
      if (authService.userRole == UserRole.doctor) {
        _navigateTo(const DoctorDashboard());
      } else if (authService.userRole == UserRole.patient) {
        _navigateTo(const PatientDashboard());
      } else {
        _navigateTo(const LoginScreen());
      }
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Neumorphic(
              style: NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.circle(),
                depth: 8,
                intensity: 0.7,
                lightSource: LightSource.topLeft,
                color: const Color(0xFFE0E5EC),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.medical_services,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Doctor Appointment App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
