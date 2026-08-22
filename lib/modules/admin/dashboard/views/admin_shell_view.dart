import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/admin/dashboard/controllers/admin_shell_controller.dart';
import 'package:tms/modules/admin/dashboard/views/admin_dashboard_view.dart';
import 'package:tms/modules/admin/dashboard/views/admin_sidebar.dart';
import 'package:tms/modules/admin/time%20tracking/view/admin_time_tracking_view.dart';
import 'package:tms/modules/admin/work%20force/view/admin_workforce_view.dart';
import 'package:tms/modules/admin/my%20project/view/admin_projects.dart';
import 'package:tms/modules/notification/views/notification_list_view.dart';
import 'package:tms/modules/reports/views/reports_view.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class AdminShellView extends StatefulWidget {
  const AdminShellView({
    super.key,
    required this.initialRoute,
  });

  final String initialRoute;

  @override
  State<AdminShellView> createState() => _AdminShellViewState();
}

class _AdminShellViewState extends State<AdminShellView> {
  late final AdminShellController controller;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminShellController>();
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
      case AppRoutes.adminDashboard:
        return 0;
      case AppRoutes.workforce:
      case AppRoutes.accessControl:
        return 1;
      case AppRoutes.timeTracking:
      case AppRoutes.departments:
        return 2;
      case AppRoutes.adminProject:
        return 3;
      case AppRoutes.notifications:
        return 4;
      case AppRoutes.reports:
        return 5;
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
                  () => AdminSidebar(
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
                () => AdminSidebar(
                  currentRoute: controller.currentRoute.value,
                  onRouteSelected: _handleRouteSelected,
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                // Stable Persistent AppTopBar across all Admin Screens
                Obx(
                  () => AppTopBar(
                    title: controller.departmentDisplayName.value,
                    subtitle: controller.screenSubtitle,
                    userName: controller.userName.value,
                    userRole: controller.userRoleDisplay.value,
                    userAvatarUrl: controller.userAvatarUrl.value,
                    tabs: controller.tabsForCurrentRoute,
                    selectedTabIndex: controller.selectedTabIndex.value,
                    onTabSelected: controller.changeTab,
                    onMenuPressed: !isDesktop ? _openMobileDrawer : null,
                    onSearchChanged: controller.onSearchChanged,
                    unreadNotificationsCount: controller.unreadNotificationsCount.value,
                  ),
                ),

                // Dynamic Canvas with Animated/Indexed Stack
                Expanded(
                  child: Obx(
                    () {
                      final route = controller.currentRoute.value;

                      return IndexedStack(
                        index: _getPageIndex(route),
                        children: const [
                          AdminDashboardView(),
                          AdminWorkforceView(),
                          AdminTimeTrackingView(),
                          AdminProjectsView(),
                          NotificationListView(),
                          ReportsView(),
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
