// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:tms/core/constants/app_sizes.dart';
// import 'package:tms/core/routes/app_pages.dart';
// import 'package:tms/modules/super_admin/dashboard/controllers/super_admin_shell_controller.dart';
// import 'package:tms/modules/super_admin/acces%20controll/view/access_control_view.dart';
// import 'package:tms/modules/super_admin/dashboard/views/super_admin_dashboard_view.dart';
// import 'package:tms/modules/super_admin/dashboard/views/widgets/super_admin_sidebar.dart';

// class SuperAdminShellView extends StatefulWidget {
//   const SuperAdminShellView({
//     super.key,
//     required this.initialRoute,
//   });

//   final String initialRoute;

//   @override
//   State<SuperAdminShellView> createState() =>
//       _SuperAdminShellViewState();
// }

// class _SuperAdminShellViewState extends State<SuperAdminShellView> {
//   late final SuperAdminShellController controller;

//   final GlobalKey<ScaffoldState> scaffoldKey =
//       GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();

//     controller = Get.find<SuperAdminShellController>();

//     controller.setRoute(widget.initialRoute);
//   }

//   // ================================================================
//   // Navigation
//   // ================================================================

//   void _handleRouteSelected(String route) {
//     controller.setRoute(route);

//     // Close Drawer only on mobile.
//     if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
//       scaffoldKey.currentState?.closeDrawer();
//     }
//   }

//   void _openMobileDrawer() {
//     scaffoldKey.currentState?.openDrawer();
//   }

//   // ================================================================
//   // Convert route -> page index
//   // ================================================================

//   int _getPageIndex(String route) {
//     switch (route) {
//       case AppRoutes.accessControl:
//         return 1;

//       case AppRoutes.superAdminDashboard:
//       default:
//         return 0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.sizeOf(context).width;

//     final isDesktop = AppBreakpoints.isDesktop(width);

//     return Scaffold(
//       key: scaffoldKey,

//       // ============================================================
//       // MOBILE DRAWER
//       // ============================================================
//       drawer: !isDesktop
//           ? Drawer(
//               child: SafeArea(
//                 child: Obx(
//                   () => SuperAdminSidebar(
//                     currentRoute: controller.currentRoute.value,
//                     onRouteSelected: _handleRouteSelected,
//                   ),
//                 ),
//               ),
//             )
//           : null,

//       // ============================================================
//       // MAIN LAYOUT
//       // ============================================================
//       body: Row(
//         children: [
//           // ==========================================================
//           // DESKTOP SIDEBAR
//           //
//           // IMPORTANT:
//           // Sidebar belongs ONLY to Shell.
//           // Dashboard/AccessControl do NOT create a sidebar.
//           // ==========================================================
//           if (isDesktop)
//             SizedBox(
//               width: 280,
//               child: Obx(
//                 () => SuperAdminSidebar(
//                   currentRoute: controller.currentRoute.value,
//                   onRouteSelected: _handleRouteSelected,
//                 ),
//               ),
//             ),

//           // ==========================================================
//           // CONTENT
//           // ==========================================================
//           Expanded(
//             child: Obx(
//               () {
//                 final route = controller.currentRoute.value;

//                 return IndexedStack(
//                   index: _getPageIndex(route),

//                   children: [
//                     // ==================================================
//                     // Dashboard
//                     // ==================================================
//                     SuperAdminDashboardView(
//                       onMenuPressed:
//                           !isDesktop ? _openMobileDrawer : null,
//                     ),

//                     // ==================================================
//                     // Access Control
//                     // ==================================================
//                     AccessControlView(
//                       onMenuPressed:
//                           !isDesktop ? _openMobileDrawer : null,
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/modules/super_admin/dashboard/controllers/super_admin_shell_controller.dart';
import 'package:tms/modules/super_admin/acces%20controll/view/access_control_view.dart';
import 'package:tms/modules/super_admin/dashboard/views/super_admin_dashboard_view.dart';
import 'package:tms/modules/super_admin/dashboard/views/widgets/super_admin_sidebar.dart';
import 'package:tms/modules/super_admin/projects/view/projects_overview_screen.dart';

class SuperAdminShellView extends StatefulWidget {
  const SuperAdminShellView({
    super.key,
    required this.initialRoute,
  });

  final String initialRoute;

  @override
  State<SuperAdminShellView> createState() =>
      _SuperAdminShellViewState();
}

class _SuperAdminShellViewState extends State<SuperAdminShellView> {
  late final SuperAdminShellController controller;

  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    controller = Get.find<SuperAdminShellController>();

    controller.setRoute(widget.initialRoute);
  }

  // ================================================================
  // Navigation
  // ================================================================

  void _handleRouteSelected(String route) {
    controller.setRoute(route);

    // Close Drawer only on mobile.
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeDrawer();
    }
  }

  void _openMobileDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  // ================================================================
  // Convert route -> page index
  // ================================================================

  int _getPageIndex(String route) {
    switch (route) {
      case AppRoutes.accessControl:
        return 1;
          case AppRoutes.superAdminProject:
        return 2; // Index for Projects Overview
      case AppRoutes.superAdminDashboard:
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
                  () => SuperAdminSidebar(
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
                () => SuperAdminSidebar(
                  currentRoute: controller.currentRoute.value,
                  onRouteSelected: _handleRouteSelected,
                ),
              ),
            ),
          Expanded(
            child: Obx(
              () {
                final route = controller.currentRoute.value;

                return IndexedStack(
                  index: _getPageIndex(route),
                  children: [
                    // ==================================================
                    // 0: Dashboard
                    // ==================================================
                    SuperAdminDashboardView(
                      onMenuPressed: !isDesktop ? _openMobileDrawer : null,
                    ),

                    // ==================================================
                    // 1: Access Control
                    // ==================================================
                    AccessControlView(
                      onMenuPressed: !isDesktop ? _openMobileDrawer : null,
                    ),

                    // ==================================================
                    // 2: Projects Overview
                    // ==================================================
                    ProjectsOverviewScreen(
                       onMenuPressed: !isDesktop ? _openMobileDrawer : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}