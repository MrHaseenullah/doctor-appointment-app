import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// This class provides methods to initialize the Firebase database schema
/// with all necessary collections and sample data.
class FirebaseSchemaInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize all collections with proper schema
  Future<void> initializeCollections() async {
    try {
      await _createUsersCollection();
      await _createDoctorsCollection();
      await _createPatientsCollection();
      await _createSlotsCollection();
      await _createAppointmentsCollection();
      await _createMedicalRecordsCollection();
      await _createNotificationsCollection();
      await _createReviewsCollection();
      await _createSettingsCollection();
      
      debugPrint('All collections initialized successfully');
    } catch (e) {
      debugPrint('Error initializing collections: $e');
    }
  }

  /// Create the users collection with proper schema
  Future<void> _createUsersCollection() async {
    // Check if collection already has documents
    final usersQuery = await _firestore.collection('users').limit(1).get();
    if (usersQuery.docs.isNotEmpty) {
      debugPrint('Users collection already exists');
      return;
    }

    // Create sample admin user
    await _firestore.collection('users').doc('admin').set({
      'email': 'admin@example.com',
      'name': 'Admin User',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,
      'profileImageUrl': '',
      'phoneNumber': '+1234567890',
    });

    debugPrint('Users collection initialized');
  }

  /// Create the doctors collection with proper schema
  Future<void> _createDoctorsCollection() async {
    // Check if collection already has documents
    final doctorsQuery = await _firestore.collection('doctors').limit(1).get();
    if (doctorsQuery.docs.isNotEmpty) {
      debugPrint('Doctors collection already exists');
      return;
    }

    // Create sample doctor
    await _firestore.collection('doctors').doc('sample_doctor').set({
      'userId': 'sample_doctor_user_id',
      'name': 'Dr. John Smith',
      'specialization': 'Cardiologist',
      'experience': 10,
      'qualifications': ['MBBS', 'MD', 'DM'],
      'bio': 'Experienced cardiologist with 10+ years of practice',
      'profileImageUrl': '',
      'clinicAddress': '123 Medical Center, New York',
      'consultationFee': 100,
      'rating': 4.8,
      'totalReviews': 120,
      'availableDays': ['Monday', 'Wednesday', 'Friday'],
      'workingHours': {
        'start': '09:00',
        'end': '17:00',
      },
      'createdAt': FieldValue.serverTimestamp(),
      'isVerified': true,
      'isActive': true,
      'contactInfo': {
        'email': 'dr.smith@example.com',
        'phone': '+1234567890',
      },
    });

    debugPrint('Doctors collection initialized');
  }

  /// Create the patients collection with proper schema
  Future<void> _createPatientsCollection() async {
    // Check if collection already has documents
    final patientsQuery = await _firestore.collection('patients').limit(1).get();
    if (patientsQuery.docs.isNotEmpty) {
      debugPrint('Patients collection already exists');
      return;
    }

    // Create sample patient
    await _firestore.collection('patients').doc('sample_patient').set({
      'userId': 'sample_patient_user_id',
      'name': 'Jane Doe',
      'dateOfBirth': Timestamp.fromDate(DateTime(1990, 5, 15)),
      'gender': 'Female',
      'bloodGroup': 'O+',
      'allergies': ['Penicillin'],
      'chronicDiseases': ['Hypertension'],
      'emergencyContact': {
        'name': 'John Doe',
        'relationship': 'Spouse',
        'phone': '+0987654321',
      },
      'address': '456 Residential Ave, New York',
      'profileImageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'contactInfo': {
        'email': 'jane.doe@example.com',
        'phone': '+1234567890',
      },
      'insuranceInfo': {
        'provider': 'Health Insurance Co.',
        'policyNumber': 'HI12345678',
        'expiryDate': Timestamp.fromDate(DateTime(2025, 12, 31)),
      },
    });

    debugPrint('Patients collection initialized');
  }

  /// Create the slots collection with proper schema
  Future<void> _createSlotsCollection() async {
    // Check if collection already has documents
    final slotsQuery = await _firestore.collection('slots').limit(1).get();
    if (slotsQuery.docs.isNotEmpty) {
      debugPrint('Slots collection already exists');
      return;
    }

    // Create sample slots for the next 7 days
    final now = DateTime.now();
    final batch = _firestore.batch();
    
    for (int day = 1; day <= 7; day++) {
      final slotDate = DateTime(now.year, now.month, now.day + day);
      
      for (int hour = 9; hour < 17; hour += 1) {
        final slotRef = _firestore.collection('slots').doc();
        final slotTime = DateTime(
          slotDate.year,
          slotDate.month,
          slotDate.day,
          hour,
          0,
        );
        
        batch.set(slotRef, {
          'doctorId': 'sample_doctor',
          'dateTime': slotTime,
          'durationMinutes': 30,
          'isBooked': false,
          'patientId': null,
          'status': 'available', // available, booked, cancelled
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'notes': '',
          'fee': 100,
        });
      }
    }
    
    await batch.commit();
    debugPrint('Slots collection initialized');
  }

  /// Create the appointments collection with proper schema
  Future<void> _createAppointmentsCollection() async {
    // Check if collection already has documents
    final appointmentsQuery = await _firestore.collection('appointments').limit(1).get();
    if (appointmentsQuery.docs.isNotEmpty) {
      debugPrint('Appointments collection already exists');
      return;
    }

    // Create a sample appointment
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final appointmentTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      10,
      0,
    );
    
    await _firestore.collection('appointments').doc('sample_appointment').set({
      'slotId': 'sample_slot_id',
      'patientId': 'sample_patient',
      'doctorId': 'sample_doctor',
      'dateTime': appointmentTime,
      'durationMinutes': 30,
      'patientName': 'Jane Doe',
      'doctorName': 'Dr. John Smith',
      'status': 'scheduled', // scheduled, completed, cancelled, no-show
      'symptoms': 'Chest pain and shortness of breath',
      'notes': 'Patient has a history of hypertension',
      'followUpDate': null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'paymentStatus': 'pending', // pending, completed, refunded
      'paymentAmount': 100,
      'paymentMethod': 'credit_card',
      'meetingType': 'in-person', // in-person, video, phone
      'meetingLink': '',
    });

    debugPrint('Appointments collection initialized');
  }

  /// Create the medical records collection with proper schema
  Future<void> _createMedicalRecordsCollection() async {
    // Check if collection already has documents
    final recordsQuery = await _firestore.collection('medical_records').limit(1).get();
    if (recordsQuery.docs.isNotEmpty) {
      debugPrint('Medical records collection already exists');
      return;
    }

    // Create a sample medical record
    await _firestore.collection('medical_records').doc('sample_record').set({
      'patientId': 'sample_patient',
      'doctorId': 'sample_doctor',
      'appointmentId': 'sample_appointment',
      'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      'diagnosis': 'Hypertension',
      'symptoms': ['Headache', 'Dizziness', 'Fatigue'],
      'vitalSigns': {
        'bloodPressure': '140/90',
        'heartRate': 85,
        'temperature': 98.6,
        'respiratoryRate': 16,
        'oxygenSaturation': 98,
      },
      'prescriptions': [
        {
          'medication': 'Lisinopril',
          'dosage': '10mg',
          'frequency': 'Once daily',
          'duration': '30 days',
          'instructions': 'Take with food',
        }
      ],
      'labTests': [
        {
          'name': 'Complete Blood Count',
          'date': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
          'results': 'Normal',
          'attachmentUrl': '',
        }
      ],
      'notes': 'Patient responding well to medication',
      'followUpRecommended': true,
      'followUpDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'attachments': [],
    });

    debugPrint('Medical records collection initialized');
  }

  /// Create the notifications collection with proper schema
  Future<void> _createNotificationsCollection() async {
    // Check if collection already has documents
    final notificationsQuery = await _firestore.collection('notifications').limit(1).get();
    if (notificationsQuery.docs.isNotEmpty) {
      debugPrint('Notifications collection already exists');
      return;
    }

    // Create sample notifications
    final batch = _firestore.batch();
    
    // Appointment reminder notification
    final notificationRef1 = _firestore.collection('notifications').doc();
    batch.set(notificationRef1, {
      'userId': 'sample_patient_user_id',
      'title': 'Appointment Reminder',
      'body': 'You have an appointment with Dr. John Smith tomorrow at 10:00 AM',
      'type': 'appointment_reminder',
      'relatedId': 'sample_appointment',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'scheduledFor': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      'action': {
        'type': 'view_appointment',
        'data': {'appointmentId': 'sample_appointment'},
      },
    });
    
    // Medical record notification
    final notificationRef2 = _firestore.collection('notifications').doc();
    batch.set(notificationRef2, {
      'userId': 'sample_patient_user_id',
      'title': 'Medical Record Updated',
      'body': 'Dr. John Smith has updated your medical record',
      'type': 'medical_record',
      'relatedId': 'sample_record',
      'isRead': true,
      'createdAt': FieldValue.serverTimestamp().toString(),
      'scheduledFor': null,
      'action': {
        'type': 'view_record',
        'data': {'recordId': 'sample_record'},
      },
    });
    
    await batch.commit();
    debugPrint('Notifications collection initialized');
  }

  /// Create the reviews collection with proper schema
  Future<void> _createReviewsCollection() async {
    // Check if collection already has documents
    final reviewsQuery = await _firestore.collection('reviews').limit(1).get();
    if (reviewsQuery.docs.isNotEmpty) {
      debugPrint('Reviews collection already exists');
      return;
    }

    // Create a sample review
    await _firestore.collection('reviews').doc('sample_review').set({
      'doctorId': 'sample_doctor',
      'patientId': 'sample_patient',
      'appointmentId': 'sample_appointment',
      'rating': 5,
      'comment': 'Dr. Smith was very professional and thorough. Highly recommended!',
      'date': FieldValue.serverTimestamp(),
      'isAnonymous': false,
      'patientName': 'Jane Doe',
      'response': {
        'text': 'Thank you for your kind words!',
        'date': FieldValue.serverTimestamp(),
      },
    });

    debugPrint('Reviews collection initialized');
  }

  /// Create the settings collection with proper schema
  Future<void> _createSettingsCollection() async {
    // Check if collection already has documents
    final settingsQuery = await _firestore.collection('settings').limit(1).get();
    if (settingsQuery.docs.isNotEmpty) {
      debugPrint('Settings collection already exists');
      return;
    }

    // Create app settings
    await _firestore.collection('settings').doc('app_settings').set({
      'appointmentDurations': [15, 30, 45, 60],
      'workingHours': {
        'start': '08:00',
        'end': '18:00',
      },
      'cancellationPolicy': 'Appointments can be cancelled up to 24 hours before the scheduled time.',
      'termsAndConditions': 'These are the terms and conditions for using the Doctor Appointment App.',
      'privacyPolicy': 'This is the privacy policy for the Doctor Appointment App.',
      'supportEmail': 'support@example.com',
      'supportPhone': '+1234567890',
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    debugPrint('Settings collection initialized');
  }

  /// Create sample data for testing
  Future<void> createSampleData() async {
    try {
      await initializeCollections();
      
      // Create sample users
      await _createSampleUsers();
      
      debugPrint('Sample data created successfully');
    } catch (e) {
      debugPrint('Error creating sample data: $e');
    }
  }

  /// Create sample users with different roles
  Future<void> _createSampleUsers() async {
    try {
      // Create a sample doctor user
      final doctorEmail = 'doctor@example.com';
      final doctorPassword = 'password123';
      User? doctorUser;
      
      try {
        final doctorCredential = await _auth.createUserWithEmailAndPassword(
          email: doctorEmail,
          password: doctorPassword,
        );
        doctorUser = doctorCredential.user;
      } catch (e) {
        // User might already exist, try to sign in
        final doctorCredential = await _auth.signInWithEmailAndPassword(
          email: doctorEmail,
          password: doctorPassword,
        );
        doctorUser = doctorCredential.user;
      }
      
      if (doctorUser != null) {
        await _firestore.collection('users').doc(doctorUser.uid).set({
          'name': 'Dr. John Smith',
          'email': doctorEmail,
          'role': 'doctor',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await _firestore.collection('doctors').doc(doctorUser.uid).set({
          'userId': doctorUser.uid,
          'name': 'Dr. John Smith',
          'specialization': 'Cardiologist',
          'experience': 10,
          'qualifications': ['MBBS', 'MD', 'DM'],
          'bio': 'Experienced cardiologist with 10+ years of practice',
          'profileImageUrl': '',
          'clinicAddress': '123 Medical Center, New York',
          'consultationFee': 100,
          'rating': 4.8,
          'totalReviews': 120,
          'availableDays': ['Monday', 'Wednesday', 'Friday'],
          'workingHours': {
            'start': '09:00',
            'end': '17:00',
          },
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': true,
          'isActive': true,
          'contactInfo': {
            'email': doctorEmail,
            'phone': '+1234567890',
          },
        });
      }
      
      // Create a sample patient user
      final patientEmail = 'patient@example.com';
      final patientPassword = 'password123';
      User? patientUser;
      
      try {
        final patientCredential = await _auth.createUserWithEmailAndPassword(
          email: patientEmail,
          password: patientPassword,
        );
        patientUser = patientCredential.user;
      } catch (e) {
        // User might already exist, try to sign in
        final patientCredential = await _auth.signInWithEmailAndPassword(
          email: patientEmail,
          password: patientPassword,
        );
        patientUser = patientCredential.user;
      }
      
      if (patientUser != null) {
        await _firestore.collection('users').doc(patientUser.uid).set({
          'name': 'Jane Doe',
          'email': patientEmail,
          'role': 'patient',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await _firestore.collection('patients').doc(patientUser.uid).set({
          'userId': patientUser.uid,
          'name': 'Jane Doe',
          'dateOfBirth': Timestamp.fromDate(DateTime(1990, 5, 15)),
          'gender': 'Female',
          'bloodGroup': 'O+',
          'allergies': ['Penicillin'],
          'chronicDiseases': ['Hypertension'],
          'emergencyContact': {
            'name': 'John Doe',
            'relationship': 'Spouse',
            'phone': '+0987654321',
          },
          'address': '456 Residential Ave, New York',
          'profileImageUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'contactInfo': {
            'email': patientEmail,
            'phone': '+1234567890',
          },
          'insuranceInfo': {
            'provider': 'Health Insurance Co.',
            'policyNumber': 'HI12345678',
            'expiryDate': Timestamp.fromDate(DateTime(2025, 12, 31)),
          },
        });
      }
      
      debugPrint('Sample users created successfully');
      debugPrint('Sample Doctor: $doctorEmail / $doctorPassword');
      debugPrint('Sample Patient: $patientEmail / $patientPassword');
    } catch (e) {
      debugPrint('Error creating sample users: $e');
    }
  }
}
