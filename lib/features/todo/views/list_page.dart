import 'package:flutter/material.dart';
import 'package:maestro_test/core/design_system/app_spacing.dart';

class ListPageBuilder extends StatefulWidget {
  const ListPageBuilder({super.key});

  @override
  State<ListPageBuilder> createState() => ListPageBuilderState();
}

class ListPageBuilderState extends State<ListPageBuilder> {
  late List<bool> _toggled;

  @override
  void initState() {
    super.initState();
    // Initialize toggle state for each item. If the item count changes
    // dynamically later, you'll want to update this accordingly.
    _toggled = List<bool>.filled(2, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            index: index,
            onPressed: (val) {
              setState(() {
                _toggled[index] = val;
              });
            },
            value: _toggled[index],
          );
        },
        itemCount: _toggled.length,
      ),
    );
  }
}

class Card extends StatelessWidget {
  final void Function(bool val) onPressed;
  final bool value;
  final int index;
  const Card({
    super.key,
    required this.index,
    required this.onPressed,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return newMethod(index);
  }

  ListTile newMethod(int index) {
    return ListTile(
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            identifier: 'delete_icon',
            label: 'delete_icon',
            // child: IconButton(icon: Icon(Icons.delete), onPressed: () {}),
            child: Icon(Icons.delete),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            identifier: 'toggle_item',
            label: 'toggle_item',
            child: ExcludeSemantics(
              child: Switch(value: value, onChanged: (val) => onPressed(val)),
            ),
          ),
        ],
      ),

      title: Text('Item $index'),
    );
  }
}
