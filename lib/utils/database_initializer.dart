import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// This class provides methods to initialize the database schema
/// and create sample data for testing purposes.
class DatabaseInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize the database schema by creating necessary collections
  /// and setting up indexes if needed.
  Future<void> initializeSchema() async {
    try {
      // Create a batch to perform multiple operations
      final batch = _firestore.batch();

      // Create a sample doctor if none exists
      final doctorsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .limit(1)
          .get();

      if (doctorsQuery.docs.isEmpty) {
        // Create a sample doctor document
        final doctorRef = _firestore.collection('users').doc();
        batch.set(doctorRef, {
          'name': 'Sample Doctor',
          'email': 'doctor@example.com',
          'role': 'doctor',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Create some sample time slots for the doctor
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        
        for (int hour = 9; hour < 17; hour++) {
          final slotRef = _firestore.collection('slots').doc();
          final slotTime = DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            hour,
            0,
          );
          
          batch.set(slotRef, {
            'doctorId': doctorRef.id,
            'dateTime': slotTime,
            'durationMinutes': 30,
            'isBooked': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Create a sample patient if none exists
      final patientsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .limit(1)
          .get();

      if (patientsQuery.docs.isEmpty) {
        // Create a sample patient document
        final patientRef = _firestore.collection('users').doc();
        batch.set(patientRef, {
          'name': 'Sample Patient',
          'email': 'patient@example.com',
          'role': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();
      
      debugPrint('Database schema initialized successfully');
    } catch (e) {
      debugPrint('Error initializing database schema: $e');
    }
  }

  /// Create a new user in both Authentication and Firestore
  Future<User?> createUser(String email, String password, String name, String role) async {
    try {
      // Create the user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create the user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return userCredential.user;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  /// Create sample data for testing
  Future<void> createSampleData() async {
    try {
      // Check if we already have sample data
      final slotsQuery = await _firestore
          .collection('slots')
          .limit(1)
          .get();
      
      if (slotsQuery.docs.isNotEmpty) {
        debugPrint('Sample data already exists');
        return;
      }
      
      // Create a sample doctor
      final doctorEmail = 'doctor@example.com';
      final doctorPassword = 'password123';
      final doctorUser = await createUser(
        doctorEmail,
        doctorPassword,
        'Dr. John Smith',
        'doctor',
      );
      
      if (doctorUser == null) {
        throw Exception('Failed to create sample doctor');
      }
      
      // Create a sample patient
      final patientEmail = 'patient@example.com';
      final patientPassword = 'password123';
      final patientUser = await createUser(
        patientEmail,
        patientPassword,
        'Jane Doe',
        'patient',
      );
      
      if (patientUser == null) {
        throw Exception('Failed to create sample patient');
      }
      
      // Create sample slots for the doctor
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final batch = _firestore.batch();
      
      for (int day = 1; day <= 7; day++) {
        final slotDate = DateTime(now.year, now.month, now.day + day);
        
        for (int hour = 9; hour < 17; hour++) {
          final slotRef = _firestore.collection('slots').doc();
          final slotTime = DateTime(
            slotDate.year,
            slotDate.month,
            slotDate.day,
            hour,
            0,
          );
          
          batch.set(slotRef, {
            'doctorId': doctorUser.uid,
            'dateTime': slotTime,
            'durationMinutes': 30,
            'isBooked': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      // Create a sample appointment
      final slotTime = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        0,
      );
      
      final slotRef = _firestore.collection('slots').doc();
      batch.set(slotRef, {
        'doctorId': doctorUser.uid,
        'dateTime': slotTime,
        'durationMinutes': 30,
        'isBooked': true,
        'patientId': patientUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      final appointmentRef = _firestore.collection('appointments').doc();
      batch.set(appointmentRef, {
        'slotId': slotRef.id,
        'patientId': patientUser.uid,
        'doctorId': doctorUser.uid,
        'dateTime': slotTime,
        'durationMinutes': 30,
        'patientName': 'Jane Doe',
        'doctorName': 'Dr. John Smith',
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
      
      debugPrint('Sample data created successfully');
      debugPrint('Sample Doctor: $doctorEmail / $doctorPassword');
      debugPrint('Sample Patient: $patientEmail / $patientPassword');
    } catch (e) {
      debugPrint('Error creating sample data: $e');
    }
  }
}
