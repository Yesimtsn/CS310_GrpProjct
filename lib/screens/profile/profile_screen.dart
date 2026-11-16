import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/placeholder_screen.dart';

/// Profile screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: TBD
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: PlaceholderBody(
        screen: 'Profile',
        owner: 'TBD',
        actions: [
          OutlinedButton(
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              );
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
