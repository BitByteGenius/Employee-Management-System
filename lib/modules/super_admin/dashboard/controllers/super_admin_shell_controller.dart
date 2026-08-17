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
  ];

//   final routes = <String>[
//   AppRoutes.superAdminDashboard,
//   AppRoutes.departments,
//   AppRoutes.accessControl,
//   AppRoutes.projects,
//   AppRoutes.notifications,
//   AppRoutes.reports,
// ];

  void setRoute(String route) {
    final index = routes.indexOf(route);

    if (index == -1) return;

    if (currentIndex.value == index) {
      return;
    }

    currentRoute.value = route;
    currentIndex.value = index;
  }

  void setIndex(int index) {
    if (index < 0 || index >= routes.length) return;

    currentIndex.value = index;
    currentRoute.value = routes[index];
  }
}