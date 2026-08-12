import 'package:flutter/material.dart';

import 'auth_branding.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 700) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          if (width >= 1000)
            const Expanded(
              flex: 4,
              child: AuthBranding(),
            ),
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
