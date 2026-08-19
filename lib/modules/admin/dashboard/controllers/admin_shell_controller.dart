import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';

class AdminShellController extends GetxController {
  final currentRoute = AppRoutes.adminDashboard.obs;
  final currentIndex = 0.obs;

  final routes = <String>[
    AppRoutes.adminDashboard,
    AppRoutes.accessControl,
    AppRoutes.departments,
    AppRoutes.superAdminProject,
    AppRoutes.notifications,
    AppRoutes.reports,
  ];

  void setRoute(String route) {
    final index = routes.indexOf(route);
    if (index == -1) return;

    if (currentIndex.value == index) return;

    currentRoute.value = route;
    currentIndex.value = index;
  }

  void setIndex(int index) {
    if (index < 0 || index >= routes.length) return;

    currentIndex.value = index;
    currentRoute.value = routes[index];
  }
}