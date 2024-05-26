import 'package:pavli_text/auth/login.dart';
import 'package:pavli_text/auth/register.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogInPage = true;

  void toggleScreens() {
    setState(() {
      showLogInPage = !showLogInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          filterQuality: FilterQuality.medium,
          child: child,
        );
      },
      child: showLogInPage
          ? LogInPage(showRegisterPage: toggleScreens)
          : RegisterPage(showLogInPage: toggleScreens),
    );
  }
}
