import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/routes/app_pages.dart';
import 'core/services/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  InitialBinding().dependencies();
  runApp(const TmsApp());
}

class TmsApp extends StatelessWidget {
  const TmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 1024),
      minTextAdapt: true,
      builder: (_, child) => GetX<ThemeController>(
        builder: (themeController) {
          return GetMaterialApp(
            title: 'TMS',
            debugShowCheckedModeBanner: false,
            initialBinding: InitialBinding(),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            initialRoute: AppRoutes.splash,//splash,
            getPages: AppPages.pages,
          );
        },
      ),
    );
  }
}
