import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/home_provider.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return MaterialApp(
      title: 'Smart Home',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: provider.themeMode,
      locale: provider.locale,
      builder: (context, child) => Directionality(
        textDirection: provider.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: const LoginScreen(),
    );
  }
}
