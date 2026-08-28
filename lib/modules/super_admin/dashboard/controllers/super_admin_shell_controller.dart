import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';

class SuperAdminShellController extends GetxController {
  final currentRoute = AppRoutes.superAdminDashboard.obs;
  final currentIndex = 0.obs;

  final routes = <String>[
    AppRoutes.superAdminDashboard,
    AppRoutes.accessControl,
    AppRoutes.departments,
    AppRoutes.superAdminProject,
    AppRoutes.notifications,
    AppRoutes.reports,
  ];

  int getRouteIndex(String route) {
    switch (route) {
      case AppRoutes.superAdminDashboard:
        return 0;
      case AppRoutes.accessControl:
        return 1;
      case AppRoutes.departments:
        return 2;
      case AppRoutes.superAdminProject:
        return 3;
      case AppRoutes.notifications:
        return 4;
      case AppRoutes.reports:
        return 5;
      default:
        return 0;
    }
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