import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/modules/project/controllers/project_controller.dart';
import 'package:tms/shared/views/placeholder_view.dart';

class ProjectView extends GetView<ProjectController> {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(title: 'Projects');
  }
}
