import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// Initial screen shown while the session is restored.
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolve the lazy binding so SplashController.onReady starts the
    // session-restore and navigation flow.
    Get.find<SplashController>();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt, size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              Text('Task Orbit', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Restoring your session...', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
