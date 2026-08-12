import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/modules/super_admin/controllers/super_admin_dashboard_controller.dart';

class SuperAdminDashboardView extends GetView<SuperAdminDashboardController> {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin Dashboard')),
      body: const Center(
        child: Text('Welcome, Super Admin!'),
      ),
    );
  }
}
