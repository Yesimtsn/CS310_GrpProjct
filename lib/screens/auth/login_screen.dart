import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/placeholder_screen.dart';

/// Login screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: Burak Ala
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: PlaceholderBody(
        screen: 'Login',
        owner: 'Burak Ala',
        actions: [
          // Temporary shortcut until the real form exists.
          FilledButton(
            onPressed: () {
              context.read<AuthService>().login(
                MockData.demoEmail,
                MockData.demoPassword,
              );
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
            child: const Text('Log in as demo user'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
            child: const Text('Create account'),
          ),
        ],
      ),
    );
  }
}
