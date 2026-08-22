import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';

class AdminShellController extends GetxController {
  final currentRoute = AppRoutes.adminDashboard.obs;
  final currentIndex = 0.obs;

  final routes = <String>[
    AppRoutes.adminDashboard,
    AppRoutes.workforce,
    AppRoutes.timeTracking,
    AppRoutes.adminProject,
    AppRoutes.notifications,
    AppRoutes.reports,
  ];

  int getRouteIndex(String route) {
    if (route == AppRoutes.adminDashboard) return 0;
    if (route == AppRoutes.workforce || route == AppRoutes.accessControl) return 1;
    if (route == AppRoutes.timeTracking || route == AppRoutes.departments) return 2;
    if (route == AppRoutes.adminProject || route == AppRoutes.superAdminProject || route == '/admin/project' || route == '/admin/projects') return 3;
    if (route == AppRoutes.notifications) return 4;
    if (route == AppRoutes.reports) return 5;
    return 0;
  }

  void setRoute(String route) {
    final index = getRouteIndex(route);
    currentRoute.value = route;
    currentIndex.value = index;
  }

  void setIndex(int index) {
    if (index < 0 || index >= routes.length) return;

    currentIndex.value = index;
    currentRoute.value = routes[index];
  }
}