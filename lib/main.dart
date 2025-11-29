import 'package:flutter/material.dart';
import 'package:math_ai_app/data/providers/device_info_provider.dart';
import 'package:math_ai_app/data/providers/user_provider.dart';
import 'package:math_ai_app/data/providers/auth_provider.dart';
import 'package:math_ai_app/data/providers/setting_provider.dart';
import 'package:math_ai_app/data/providers/grades_provider.dart';
import 'package:math_ai_app/data/providers/levels_provider.dart';
import 'package:math_ai_app/data/providers/profile_provider.dart';
import 'package:math_ai_app/ui/onboarding%20screen/view/onboarding_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DeviceInfoProvider()),
        ChangeNotifierProvider(create: (context) => SettingProvider()),
        ChangeNotifierProvider(create: (context) => GradesProvider()),
        ChangeNotifierProvider(create: (context) => LevelsProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
