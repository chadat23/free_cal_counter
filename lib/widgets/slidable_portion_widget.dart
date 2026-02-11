import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meal_of_record/models/food_portion.dart';
import 'package:meal_of_record/widgets/portion_widget.dart';

class SlidablePortionWidget extends StatelessWidget {
  final FoodPortion serving;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const SlidablePortionWidget({
    super.key,
    required this.serving,
    required this.onDelete,
    this.onEdit,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // The key is important for Slidable to close other items when one is opened
      key: key ?? ValueKey(serving),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        color: Theme.of(context).canvasColor,
        child: PortionWidget(
          portion: serving,
          onEdit: onEdit,
          onTap: onTap,
          onLongPress: onLongPress,
          isSelected: isSelected,
        ),
      ),
    );
  }
}
