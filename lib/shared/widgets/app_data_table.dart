import 'package:flutter/material.dart';
import 'package:tms/core/constants/app_colors.dart';
import 'package:tms/core/constants/app_sizes.dart';
import 'package:tms/core/constants/app_typography.dart';

class AppColumnDef {
  final String label;
  final double? width;
  final Alignment alignment;

  const AppColumnDef({
    required this.label,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

class AppDataTable extends StatelessWidget {
  final String title;
  final List<AppColumnDef> columns;
  final List<List<Widget>> rows;
  final Widget? headerAction;
  final String? emptyMessage;

  const AppDataTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.headerAction,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppBreakpoints.isMobile(MediaQuery.sizeOf(context).width);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppColors.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLg(
                    color: isDark ? AppColors.darkOnSurface : AppColors.primary,
                  ),
                ),
                if (headerAction != null) headerAction!,
              ],
            ),
          ),

          const Divider(),

          // Empty state
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  emptyMessage ?? 'No records available',
                  style: AppTypography.bodyMd(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else if (isMobile)
            // Mobile Card View
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, rowIndex) {
                final cells = rows[rowIndex];
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      cells.length.clamp(0, columns.length),
                      (colIndex) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                '${columns[colIndex].label}:',
                                style: AppTypography.labelSm(
                                  color: isDark
                                      ? AppColors.darkOnSurfaceVariant
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(child: cells[colIndex]),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            // Desktop / Tablet Table View
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.sizeOf(context).width -
                      AppSizes.sidebarWidth -
                      (AppSpacing.xl * 2),
                ),
                child: Table(
                  columnWidths: {
                    for (int i = 0; i < columns.length; i++)
                      if (columns[i].width != null)
                        i: FixedColumnWidth(columns[i].width!)
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Column Headers
                    TableRow(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceContainer
                            : AppColors.surfaceContainerLow.withOpacity(0.5),
                      ),
                      children: columns
                          .map(
                            (col) => Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Align(
                                alignment: col.alignment,
                                child: Text(
                                  col.label.toUpperCase(),
                                  style: AppTypography.labelSm(
                                    color: isDark
                                        ? AppColors.darkOnSurfaceVariant
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    // Table Data Rows
                    ...rows.map(
                      (rowCells) => TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : AppColors.outlineVariant.withOpacity(0.2),
                            ),
                          ),
                        ),
                        children: List.generate(
                          rowCells.length,
                          (idx) => Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Align(
                              alignment: idx < columns.length
                                  ? columns[idx].alignment
                                  : Alignment.centerLeft,
                              child: rowCells[idx],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
