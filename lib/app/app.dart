import 'package:flutter/material.dart';
import '../shared/theme/app_theme.dart';
import '../features/auth/screens/register_screen.dart';

class ContactoApp extends StatelessWidget {
  const ContactoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacto',
      debugShowCheckedModeBanner: false,
      theme: ContactoTheme.light,
      home: const RegisterScreen(),
    );
  }
}
