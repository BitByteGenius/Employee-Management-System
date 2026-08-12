import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final stats = {'Projects': '24', 'Active tasks': '186', 'Team members': '38', 'Due soon': '11'}.obs;
  final chartValues = <double>[8, 14, 21, 16, 27, 18, 30].obs;
}
