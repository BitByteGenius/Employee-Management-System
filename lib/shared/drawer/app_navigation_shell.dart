import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_controller.dart';
import '../widgets/responsive_layout.dart';

class AppNavigationItem {
  const AppNavigationItem(this.label, this.icon, this.route, {this.permission});
  final String label;
  final IconData icon;
  final String route;
  final String? permission;
}

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({super.key, required this.title, required this.items, required this.child});
  final String title;
  final List<AppNavigationItem> items;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final drawer = _NavigationList(title: title, items: items);
    return ResponsiveLayout(
      mobile: Scaffold(appBar: AppBar(title: Text(title)), drawer: Drawer(child: drawer), body: child),
      tablet: Scaffold(body: Row(children: [NavigationRail(destinations: items.map((e) => NavigationRailDestination(icon: Icon(e.icon), label: Text(e.label))).toList(), selectedIndex: 0), Expanded(child: child)])),
      desktop: Scaffold(body: Row(children: [SizedBox(width: 260, child: drawer), Expanded(child: child)])),
    );
  }
}

class _NavigationList extends StatelessWidget {
  const _NavigationList({required this.title, required this.items});
  final String title;
  final List<AppNavigationItem> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          ListTile(title: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
          Expanded(
            child: ListView(children: items.map((item) => ListTile(leading: Icon(item.icon), title: Text(item.label), onTap: () => Get.offNamed(item.route))).toList()),
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () {
              final controller = Get.find<ThemeController>();
              controller.changeTheme(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
            },
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
    );
  }
}
