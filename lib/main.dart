import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/admin/presentation/pages/admin_home_page.dart';
import 'features/profile/presentation/pages/customer_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kplymojaedcjgcpzvzaa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwbHltb2phZWRjamdjcHp2emFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MTM4MTEsImV4cCI6MjA5MDE4OTgxMX0.asDQ7PRYcHDo6J2-I3ue7XxFjj7PIv_n3V-qMl1v3oY',
  );
  runApp(const DilanBeautyApp());
}

class DilanBeautyApp extends StatelessWidget {
  const DilanBeautyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dilan Beauty Lounge',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
        '/admin': (context) => AdminHomePage(),
        '/home': (context) => CustomerHomePage(),
      },
    );
  }
}