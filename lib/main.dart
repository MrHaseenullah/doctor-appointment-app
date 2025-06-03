import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'utils/firebase_schema_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase database schema and create sample data
  try {
    final schemaInitializer = FirebaseSchemaInitializer();
    await schemaInitializer.createSampleData();
    debugPrint('Firebase schema initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase schema: $e');
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Appointment App',
      theme: NeumorphicThemeData(
        baseColor: const Color(0xFFE0E5EC), // soft white-grey
        lightSource: LightSource.topLeft,
        depth: 8,
      ),
      home: const SplashScreen(),
    );
  }
}
