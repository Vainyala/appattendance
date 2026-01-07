import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode { mergeGraph, employeeOverview, activeProjects }

class GraphToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onModeChanged;

  const GraphToggle({
    required this.currentMode,
    required this.onModeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: ViewMode.values.map((m) => m == currentMode).toList(),
      onPressed: (index) {
        onModeChanged(ViewMode.values[index]);
      },
      children: const [
        Padding(padding: EdgeInsets.all(8), child: Text('Merge Graph')),
        Padding(padding: EdgeInsets.all(8), child: Text('Employee Overview')),
        Padding(padding: EdgeInsets.all(8), child: Text('Active Projects')),
      ],
    );
  }
}
