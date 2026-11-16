import 'package:flutter/material.dart';

import '../../widgets/placeholder_screen.dart';

/// Sign up screen. See CS310_Group30_Step2.1 wireframes.
/// Owner: Burak Ala
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: PlaceholderBody(screen: 'Sign up', owner: 'Burak Ala', actions: []),
    );
  }
}
