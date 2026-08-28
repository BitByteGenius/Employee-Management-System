import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/employee/dashboard/controllers/employee_dashboard_controller.dart';
import 'package:tms/modules/employee/dashboard/views/employee_dashboard_view.dart';
import 'package:tms/modules/employee/dashboard/views/employee_sidebar.dart';
import 'package:tms/modules/employee/projects/view/employee_projects_view.dart';
import 'package:tms/modules/employee/task/view/employee_tasks_view.dart';
import 'package:tms/modules/employee/time_tracking/view/employee_time_tracking_view.dart';
import 'package:tms/modules/notification/views/notification_list_view.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class EmployeeShellView extends StatefulWidget {
  const EmployeeShellView({
    super.key,
    required this.initialRoute,
  });

  final String initialRoute;

  @override
  State<EmployeeShellView> createState() => _EmployeeShellViewState();
}

class _EmployeeShellViewState extends State<EmployeeShellView> {
  late final EmployeeDashboardController controller;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = Get.find<EmployeeDashboardController>();
    controller.setRoute(widget.initialRoute);
  }

  void _handleRouteSelected(String route) {
    controller.setRoute(route);
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  void _openMobileDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  int _getPageIndex(String route) {
    switch (route) {
      case AppRoutes.employeeDashboard:
        return 0;
      case AppRoutes.employeeTasks:
      case AppRoutes.tasks:
        return 1;
      case AppRoutes.employeeProjects:
        return 2;
      case AppRoutes.employeeTimeTracking:
        return 3;
      case AppRoutes.notifications:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = AppBreakpoints.isDesktop(width);

    return Scaffold(
      key: scaffoldKey,
      drawer: !isDesktop
          ? Drawer(
              child: SafeArea(
                child: Obx(
                  () => EmployeeSidebar(
                    currentRoute: controller.currentRoute.value,
                    onRouteSelected: _handleRouteSelected,
                  ),
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 280,
              child: Obx(
                () => EmployeeSidebar(
                  currentRoute: controller.currentRoute.value,
                  onRouteSelected: _handleRouteSelected,
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                // Stable Persistent AppTopBar across all Employee Screens
                Obx(
                  () => AppTopBar(
                    title: controller.departmentDisplayName.value,
                    subtitle: controller.screenSubtitle,
                    userName: controller.userName.value,
                    userRole: controller.userRoleDisplay.value,
                    userAvatarUrl: controller.userAvatarUrl.value,
                    tabs: controller.tabsForCurrentRoute,
                    selectedTabIndex: controller.selectedTab.value,
                    onTabSelected: controller.changeTab,
                    onMenuPressed: !isDesktop ? _openMobileDrawer : null,
                    unreadNotificationsCount: controller.unreadNotificationsCount.value,
                  ),
                ),

                // Dynamic Canvas with IndexedStack
                Expanded(
                  child: Obx(
                    () {
                      final route = controller.currentRoute.value;

                      return IndexedStack(
                        index: _getPageIndex(route),
                        children: const [
                          EmployeeDashboardView(),
                          EmployeeTasksView(),
                          EmployeeProjectsView(),
                          EmployeeTimeTrackingView(),
                          NotificationListView(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
