import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meal_of_record/models/food.dart';
import 'package:meal_of_record/models/food_serving.dart' as model_unit;
import 'package:meal_of_record/widgets/search_result_tile.dart';

class SlidableRecipeSearchResult extends StatefulWidget {
  final Food food;
  final void Function(model_unit.FoodServing) onTap;
  final void Function(model_unit.FoodServing)? onAdd;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final void Function(model_unit.FoodServing) onDecompose;
  final String? note;
  final bool isUpdate;

  const SlidableRecipeSearchResult({
    super.key,
    required this.food,
    required this.onTap,
    this.onAdd,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
    required this.onDecompose,
    this.note,
    this.isUpdate = false,
  });

  @override
  State<SlidableRecipeSearchResult> createState() =>
      _SlidableRecipeSearchResultState();
}

class _SlidableRecipeSearchResultState
    extends State<SlidableRecipeSearchResult> {
  final GlobalKey<SearchResultTileState> _tileKey =
      GlobalKey<SearchResultTileState>();

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.food.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => widget.onEdit(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => widget.onCopy(),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.copy,
            label: 'Copy',
          ),
          SlidableAction(
            onPressed: (context) {
              final tileState = _tileKey.currentState;
              if (tileState != null) {
                widget.onDecompose(tileState.currentServing);
              }
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: Icons.account_tree,
            label: 'Dump',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _confirmDelete(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: SearchResultTile(
        key: _tileKey,
        food: widget.food,
        onTap: widget.onTap,
        onAdd: widget.onAdd,
        note: widget.note,
        isUpdate: widget.isUpdate,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${widget.food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
