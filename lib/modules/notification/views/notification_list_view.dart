import 'package:flutter/material.dart';
import '../../../shared/widgets/module_list_view.dart';

class NotificationListView extends StatelessWidget {
  const NotificationListView({super.key});
  @override
  Widget build(BuildContext context) => const ModuleListView(title: 'Notifications', subtitle: 'Realtime updates, read state, and approval alerts.', icon: Icons.notifications_outlined);
}
