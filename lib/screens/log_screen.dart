import 'package:flutter/material.dart';

// Data models for food logging
class Food {
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double grams; // Weight in grams
  final String emoji; // Emoji, image path, or icon identifier

  const Food({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.grams,
    required this.emoji,
  });
}

class FoodLogEntry {
  final DateTime timestamp;
  final List<Food> foods;

  const FoodLogEntry({
    required this.timestamp,
    required this.foods,
  });
}

class FoodItemWidget extends StatelessWidget {
  final Food food;
  final bool isSelected;

  const FoodItemWidget({super.key, required this.food, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            spreadRadius: isSelected ? 2 : 1,
            blurRadius: isSelected ? 4 : 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Emoji, Name, Calories
          Row(
            children: [
              // Emoji/Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    food.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Food name
              Expanded(
                child: Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Calories
              Text(
                '${food.calories.toInt()} cal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom row: Nutritional info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutritionChip('P', '${food.protein.toStringAsFixed(1)}', Colors.red),
              _buildNutritionChip('F', '${food.fat.toStringAsFixed(1)}', Colors.yellow),
              _buildNutritionChip('C', '${food.carbs.toStringAsFixed(1)}', Colors.green),
              _buildNutritionChip('', '${food.grams.toStringAsFixed(0)}g', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class DraggableFoodItemWidget extends StatefulWidget {
  final Food food;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isInSelectionMode;

  const DraggableFoodItemWidget({
    super.key,
    required this.food,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isInSelectionMode = false,
  });

  @override
  State<DraggableFoodItemWidget> createState() => _DraggableFoodItemWidgetState();
}

class _DraggableFoodItemWidgetState extends State<DraggableFoodItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragOffset = 0.0;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    // Pan start - no state changes needed
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      // Limit the drag distance
      _dragOffset = _dragOffset.clamp(-100.0, 100.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Determine if we should show edit or delete action
    if (_dragOffset > 30) {
      // Dragged right - show edit actions
      setState(() {
        _showActions = true;
        _dragOffset = 60.0; // Show edit action
      });
    } else if (_dragOffset < -30) {
      // Dragged left - show delete actions
      setState(() {
        _showActions = true;
        _dragOffset = -60.0; // Show delete action
      });
    } else {
      // Snap back to center
      _snapBack();
    }
  }

  void _onEditTap() {
    if (widget.onEdit != null) {
      widget.onEdit!();
    }
    _snapBack();
  }

  void _onDeleteTap() {
    if (widget.onDelete != null) {
      widget.onDelete!();
    }
    _snapBack();
  }

  void _snapBack() {
    setState(() {
      _dragOffset = 0.0;
      _showActions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Stack(
        children: [
          // Edit action (left edge) - always present
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 60, // Fixed width for the action button
            child: GestureDetector(
              onTap: _onEditTap,
              child: Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue[400]!, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          // Delete action (right edge) - always present
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 60, // Fixed width for the action button
            child: GestureDetector(
              onTap: _onDeleteTap,
              child: Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.red[200],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red[400]!, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          // Draggable content - positioned on top
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTap: _showActions ? _snapBack : (widget.isInSelectionMode ? widget.onTap : null), // Tap works in selection mode or to close actions
              onLongPress: widget.onLongPress, // Long press to select item
              child: FoodItemWidget(food: widget.food, isSelected: widget.isSelected),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodLogEntryWidget extends StatelessWidget {
  final FoodLogEntry entry;
  final Function(FoodLogEntry entry, Food food)? onEditFood;
  final Function(FoodLogEntry entry, Food food)? onDeleteFood;
  final Function(FoodLogEntry entry, Food food)? onTapFood;
  final Function(FoodLogEntry entry, Food food)? onLongPressFood;
  final bool Function(FoodLogEntry entry, Food food)? isFoodSelected;
  final bool isInSelectionMode;

  const FoodLogEntryWidget({
    super.key, 
    required this.entry,
    this.onEditFood,
    this.onDeleteFood,
    this.onTapFood,
    this.onLongPressFood,
    this.isFoodSelected,
    this.isInSelectionMode = false,
  });

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals for this entry
    final totalCalories = entry.foods.fold(0.0, (sum, food) => sum + food.calories);
    final totalProtein = entry.foods.fold(0.0, (sum, food) => sum + food.protein);
    final totalFat = entry.foods.fold(0.0, (sum, food) => sum + food.fat);
    final totalCarbs = entry.foods.fold(0.0, (sum, food) => sum + food.carbs);
    final totalGrams = entry.foods.fold(0.0, (sum, food) => sum + food.grams);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp with totals
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                // Timestamp
                Text(
                  _formatTime(entry.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                // Totals
                Row(
                  children: [
                    _buildTotalChip('${totalCalories.toInt()} cal', Colors.orange),
                    const SizedBox(width: 4),
                    _buildTotalChip('P ${totalProtein.toStringAsFixed(1)}', Colors.red),
                    const SizedBox(width: 4),
                    _buildTotalChip('F ${totalFat.toStringAsFixed(1)}', Colors.yellow),
                    const SizedBox(width: 4),
                    _buildTotalChip('C ${totalCarbs.toStringAsFixed(1)}', Colors.green),
                    const SizedBox(width: 4),
                    _buildTotalChip('${totalGrams.toInt()}g', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Food items
          ...entry.foods.map((food) => DraggableFoodItemWidget(
            food: food,
            onEdit: () => onEditFood?.call(entry, food),
            onDelete: () => onDeleteFood?.call(entry, food),
            onTap: () => onTapFood?.call(entry, food),
            onLongPress: () => onLongPressFood?.call(entry, food),
            isSelected: isFoodSelected?.call(entry, food) ?? false,
            isInSelectionMode: isInSelectionMode,
          )),
        ],
      ),
    );
  }

  Widget _buildTotalChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class HorizontalBarChart extends StatelessWidget {
  final String character;
  final int currentValue;
  final int maxValue;
  final Color barColor;

  const HorizontalBarChart({
    super.key,
    required this.character,
    required this.currentValue,
    required this.maxValue,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage (0.0 to 1.0)
    final double percentage = maxValue > 0 ? (currentValue / maxValue).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      children: [
        // Horizontal bar chart
        Container(
          height: 4, // Much shorter - about 1mm
          width: 80, // Reduced width to fit 4 across screen
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 200, 200, 200), // Background track color
            borderRadius: BorderRadius.circular(2), // Much smaller radius
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 4,
              width: 80 * percentage,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2), // Much smaller radius
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Text display: "char num1/num2"
        Text(
          '$character $currentValue/$maxValue',
          style: const TextStyle(
            fontSize: 10, // Slightly smaller text
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  DateTime _currentDate = DateTime.now();
  
  // Selection state management
  final Set<String> _selectedItems = <String>{};
  bool _isInSelectionMode = false;
  
  // Sample food log data
  final List<FoodLogEntry> _foodLogEntries = [
    FoodLogEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 12)), // 12 hours ago (dinner)
      foods: [
        const Food(name: 'Oatmeal', calories: 154, protein: 5, fat: 3, carbs: 27, grams: 40, emoji: '🥣'),
        const Food(name: 'Banana', calories: 89, protein: 1.1, fat: 0.3, carbs: 23, grams: 120, emoji: '🍌'),
      ],
    ),
    FoodLogEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 6)), // 6 hours ago (breakfast)
      foods: [
        const Food(name: 'Greek Yogurt', calories: 100, protein: 17, fat: 0, carbs: 6, grams: 150, emoji: '🥛'),
        const Food(name: 'Mixed Berries', calories: 40, protein: 1, fat: 0.4, carbs: 10, grams: 60, emoji: '🫐'),
        const Food(name: 'Almonds', calories: 164, protein: 6, fat: 14, carbs: 6, grams: 25, emoji: '🥜'),
      ],
    ),
    FoodLogEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 2)), // 2 hours ago (lunch)
      foods: [
        const Food(name: 'Grilled Chicken Breast', calories: 165, protein: 31, fat: 3.6, carbs: 0, grams: 100, emoji: '🍗'),
        const Food(name: 'Brown Rice', calories: 112, protein: 2.6, fat: 0.9, carbs: 22, grams: 80, emoji: '🍚'),
        const Food(name: 'Steamed Broccoli', calories: 25, protein: 3, fat: 0.4, carbs: 5, grams: 50, emoji: '🥦'),
      ],
    ),
  ];

  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

  void _editFood(FoodLogEntry entry, Food food) {
    // Reload the log tab by triggering a rebuild
    setState(() {
      // This will cause the entire log screen to rebuild
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${food.name} - Log reloaded'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteFood(FoodLogEntry entry, Food food) {
    // Reload the log tab by triggering a rebuild
    setState(() {
      // This will cause the entire log screen to rebuild
    });
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delete ${food.name} - Log reloaded'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Generate unique ID for food item based on entry timestamp and food name
  String _getFoodItemId(FoodLogEntry entry, Food food) {
    return '${entry.timestamp.millisecondsSinceEpoch}_${food.name}';
  }

  // Handle item selection (for long press - starts selection mode)
  void _startSelectionMode(FoodLogEntry entry, Food food) {
    setState(() {
      final itemId = _getFoodItemId(entry, food);
      _isInSelectionMode = true;
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
        // If no items selected, exit selection mode
        if (_selectedItems.isEmpty) {
          _isInSelectionMode = false;
        }
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  // Handle item selection (for tap - only works in selection mode)
  void _toggleItemSelection(FoodLogEntry entry, Food food) {
    if (!_isInSelectionMode) return; // Only work in selection mode
    
    setState(() {
      final itemId = _getFoodItemId(entry, food);
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
        // If no items selected, exit selection mode
        if (_selectedItems.isEmpty) {
          _isInSelectionMode = false;
        }
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  // Check if item is selected
  bool _isItemSelected(FoodLogEntry entry, Food food) {
    final itemId = _getFoodItemId(entry, food);
    return _selectedItems.contains(itemId);
  }

  // Clear all selections
  void _clearAllSelections() {
    setState(() {
      _selectedItems.clear();
      _isInSelectionMode = false;
    });
  }

  // Action button handlers
  void _onCopyPressed() {
    // For now, just clear selections
    _clearAllSelections();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copy action - selections cleared'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onMovePressed() {
    // For now, just clear selections
    _clearAllSelections();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Move action - selections cleared'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onDeletePressed() {
    // For now, just clear selections
    _clearAllSelections();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delete action - selections cleared'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onCancelPressed() {
    // Clear selections
    _clearAllSelections();
  }

  // Helper method to build action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow';
    } else {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      final dayOfWeek = days[date.weekday % 7];
      final month = months[date.month - 1];
      final day = date.day;
      
      return '$dayOfWeek, $month $day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Header with date navigation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous day button
                IconButton(
                  onPressed: _previousDay,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: const CircleBorder(),
                  ),
                ),
                // Date display
                Text(
                  _formatDate(_currentDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Next day button
                IconButton(
                  onPressed: _nextDay,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal bar charts section (stays at top)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HorizontalBarChart(
                  character: '🔥',
                  currentValue: 2000,
                  maxValue: 3000,
                  barColor: Colors.blue,
                ),
                HorizontalBarChart(
                  character: 'P',
                  currentValue: 125,
                  maxValue: 160,
                  barColor: Colors.red,
                ),
                HorizontalBarChart(
                  character: 'F',
                  currentValue: 45,
                  maxValue: 88,
                  barColor: Colors.yellow,
                ),
                HorizontalBarChart(
                  character: 'C',
                  currentValue: 100,
                  maxValue: 225,
                  barColor: Colors.green,
                ),
              ],
            ),
          ),
          // Scrollable content below
          Expanded(
            child: GestureDetector(
              onTap: _clearAllSelections, // Tap outside to clear selections
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food log entries
                      if (_foodLogEntries.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No food logged yet for this day',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._foodLogEntries.map((entry) => FoodLogEntryWidget(
                          entry: entry,
                          onEditFood: _editFood,
                          onDeleteFood: _deleteFood,
                          onTapFood: _toggleItemSelection, // Regular tap works in selection mode
                          onLongPressFood: _startSelectionMode, // Long press starts selection mode
                          isFoodSelected: _isItemSelected,
                          isInSelectionMode: _isInSelectionMode,
                        )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Action buttons row (only shown when items are selected) - positioned at bottom
          if (_selectedItems.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(
                  top: BorderSide(color: Colors.blue[200]!),
                  bottom: BorderSide(color: Colors.blue[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    color: Colors.blue,
                    onPressed: _onCopyPressed,
                  ),
                  _buildActionButton(
                    icon: Icons.drive_file_move,
                    label: 'Move',
                    color: Colors.orange,
                    onPressed: _onMovePressed,
                  ),
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: Colors.red,
                    onPressed: _onDeletePressed,
                  ),
                  _buildActionButton(
                    icon: Icons.cancel,
                    label: 'Cancel',
                    color: Colors.grey,
                    onPressed: _onCancelPressed,
                  ),
                ],
              ),
            ),
        ],
    );
  }
}