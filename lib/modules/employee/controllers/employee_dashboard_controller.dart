import 'package:get/get.dart';

class EmployeeDashboardController extends GetxController {
  final stats = {'My tasks': '12', 'In review': '3', 'Projects': '4', 'Notifications': '7'}.obs;
  final chartValues = <double>[4, 7, 5, 9, 6, 8, 10].obs;
}
