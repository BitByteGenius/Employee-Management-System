// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tms/core/constants/app_colors.dart';
// import 'package:tms/core/constants/app_constants.dart' hide AppColors, AppRadius; // Added AppRadius here
// import 'package:tms/core/constants/app_sizes.dart'; // Removed 'hide AppRadius' so this is the active one
// import 'package:tms/core/constants/app_typography.dart';
// import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';
// import 'package:tms/modules/super_admin/projects/view/widget/project_deliverables_dialog.dart';

// class ProjectsOverviewScreen extends StatelessWidget {
//   const ProjectsOverviewScreen({super.key});




//   @override
//   Widget build(BuildContext context) {
//     Get.put(ProjectController());
//    /* final isDark =
//         Theme.of(context).brightness ==
//             Brightness.dark;*/

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppSpacing.xxl),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Top Bar & Actions ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Projects Overview', style: AppTypography.headlineLg(color: AppColors.onBackground)),
//                     const SizedBox(height: AppSpacing.xs),
//                     Text('Manage and monitor all active enterprise initiatives.', style: AppTypography.bodyLg(color: AppColors.onSurfaceVariant)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     _buildDropdown('All Statuses'),
//                     const SizedBox(width: AppSpacing.md),
//                     _buildDropdown('All Managers'),
//                     const SizedBox(width: AppSpacing.md),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Get.dialog(
//                           const ProjectDeliverablesDialog(), 
//                           barrierColor: AppColors.primaryContainer.withOpacity(0.5),
//                         );
//                       },
//                       icon: const Icon(Icons.add, size: 18),
//                       label: const Text('New Project'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.secondary,
//                         foregroundColor: AppColors.onSecondary,
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//                         textStyle: AppTypography.labelMd(),
//                         elevation: 0,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: AppSpacing.xxxl),
            
//             // --- Projects Grid ---
//             GridView.count(
//               crossAxisCount: AppBreakpoints.isDesktop(MediaQuery.of(context).size.width) ? 3 : 2,
//               crossAxisSpacing: AppSpacing.lg,
//               mainAxisSpacing: AppSpacing.lg,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               childAspectRatio: 1.1,
//               children: [
//                 _buildProjectCard(context, 'Project Alpha Nexus', 'Global infrastructure migration to secure cloud environments.', '65%', '24/40', 'Oct 15, 2024', true),
//                 _buildProjectCard(context, 'Project Beta Core', 'Legacy system decommissioning and data archiving protocols.', '100%', '50/50', 'Aug 01, 2024', false),
//                 _buildProjectCard(context, 'Delta Framework', 'New frontend architecture deployment across all internal...', '30%', '12/85', 'Dec 10, 2024', true),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.outlineVariant),
//         borderRadius: BorderRadius.circular(AppRadius.sm),
//         color: AppColors.surfaceContainerLowest,
//       ),
//       child: Row(
//         children: [
//           Text(text, style: AppTypography.bodyMd(color: AppColors.onBackground)),
//           const SizedBox(width: AppSpacing.md),
//           const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.outline),
//         ],
//       ),
//     );
//   }

//   Widget _buildProjectCard(BuildContext context, String title, String subtitle, String progress, String tasks, String date, bool isActive) {
//     return Container(
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceContainerLowest,
//         borderRadius: BorderRadius.circular(AppRadius.md),
//         border: Border.all(color: AppColors.outlineVariant),
//         boxShadow: AppShadow.card(context),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: isActive ? AppColors.surfaceContainerLow : AppColors.surfaceContainerHighest,
//                   borderRadius: BorderRadius.circular(AppRadius.full),
//                 ),
//                 child: Text(
//                   isActive ? 'ACTIVE' : 'ARCHIVED', 
//                   style: AppTypography.labelSm(color: isActive ? AppColors.secondary : AppColors.onSurfaceVariant),
//                 ),
//               ),
//               const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.lg),
//           Text(title, style: AppTypography.headlineSm(color: AppColors.onBackground), maxLines: 1, overflow: TextOverflow.ellipsis),
//           const SizedBox(height: AppSpacing.sm),
//           Text(subtitle, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
//           const Spacer(),
          
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Progress', style: AppTypography.labelMd(color: AppColors.outline)),
//               Text(progress, style: AppTypography.labelMd(color: AppColors.onBackground)),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.sm),
//           LinearProgressIndicator(
//             value: double.parse(progress.replaceAll('%', '')) / 100,
//             backgroundColor: AppColors.surfaceContainerHigh,
//             valueColor: AlwaysStoppedAnimation<Color>(isActive ? AppColors.secondary : AppColors.outline),
//             borderRadius: BorderRadius.circular(4),
//             minHeight: 6,
//           ),
          
//           const SizedBox(height: AppSpacing.lg),
//           const Divider(color: AppColors.surfaceContainerHigh, height: 1),
//           const SizedBox(height: AppSpacing.md),
          
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const Icon(Icons.checklist, size: 18, color: AppColors.outline),
//                   const SizedBox(width: AppSpacing.xs),
//                   Text(tasks, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
//                 ],
//               ),
//               Row(
//                 children: [
//                   const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.outline),
//                   const SizedBox(width: AppSpacing.xs),
//                   Text(date, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_constants.dart' hide AppColors, AppRadius;
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';
import 'package:tms/modules/super_admin/projects/view/widget/project_deliverables_dialog.dart';
import 'package:tms/shared/widgets/app_top_bar.dart';

class ProjectsOverviewScreen extends GetView<ProjectController> {
  const ProjectsOverviewScreen({
    super.key,
    this.onMenuPressed,
  });

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    Get.put(ProjectController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ==========================================================
        // TOP BAR
        // ==========================================================
        AppTopBar(
          title: 'Projects Overview',
          subtitle: 'Manage and monitor all active enterprise initiatives.',
          userName: 'Super Admin',
          userRole: 'Super Admin',
          onMenuPressed: onMenuPressed,
        ),

        // ==========================================================
        // BODY
        // ==========================================================
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // Add refresh logic if available in ProjectController
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // BREADCRUMB
                      // ==================================================
                      Text(
                        '> Projects Overview',
                        style: AppTypography.labelSm(
                          color: _muted(isDark),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // ==================================================
                      // TITLE & ACTIONS HEADER
                      // ==================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Projects Overview',
                                style: AppTypography.headlineMd(
                                  color: _text(isDark),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 760),
                                child: Text(
                                  'Manage and monitor all active enterprise initiatives.',
                                  style: AppTypography.bodyMd(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildDropdown('All Statuses', isDark),
                              const SizedBox(width: AppSpacing.md),
                              _buildDropdown('All Managers', isDark),
                              const SizedBox(width: AppSpacing.md),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.dialog(
                                    const ProjectDeliverablesDialog(),
                                    barrierColor: AppColors.primaryContainer.withOpacity(0.5),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('New Project'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.onSecondary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  textStyle: AppTypography.labelMd(),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ==================================================
                      // PROJECTS GRID
                      // ==================================================
                      GridView.count(
                        crossAxisCount: AppBreakpoints.isDesktop(MediaQuery.sizeOf(context).width) ? 3 : 2,
                        crossAxisSpacing: AppSpacing.lg,
                        mainAxisSpacing: AppSpacing.lg,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.1,
                        children: [
                          _buildProjectCard(context, 'Project Alpha Nexus', 'Global infrastructure migration to secure cloud environments.', '65%', '24/40', 'Oct 15, 2024', true, isDark),
                          _buildProjectCard(context, 'Project Beta Core', 'Legacy system decommissioning and data archiving protocols.', '100%', '50/50', 'Aug 01, 2024', false, isDark),
                          _buildProjectCard(context, 'Delta Framework', 'New frontend architecture deployment across all internal...', '30%', '12/85', 'Dec 10, 2024', true, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
      ),
      child: Row(
        children: [
          Text(text, style: AppTypography.bodyMd(color: _text(isDark))),
          const SizedBox(width: AppSpacing.md),
          const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.outline),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, String title, String subtitle, String progress, String tasks, String date, bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppShadow.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surfaceContainerLow : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'ARCHIVED',
                  style: AppTypography.labelSm(color: isActive ? AppColors.secondary : AppColors.onSurfaceVariant),
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTypography.headlineSm(color: _text(isDark)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTypography.labelMd(color: AppColors.outline)),
              Text(progress, style: AppTypography.labelMd(color: _text(isDark))),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: double.parse(progress.replaceAll('%', '')) / 100,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(isActive ? AppColors.secondary : AppColors.outline),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.surfaceContainerHigh, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.checklist, size: 18, color: AppColors.outline),
                  const SizedBox(width: AppSpacing.xs),
                  Text(tasks, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.outline),
                  const SizedBox(width: AppSpacing.xs),
                  Text(date, style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COLORS
// ============================================================================

Color _text(bool isDark) =>
    isDark ? AppColors.darkOnSurface : AppColors.onSurface;

Color _muted(bool isDark) =>
    isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;