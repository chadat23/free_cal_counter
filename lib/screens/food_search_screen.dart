import 'package:flutter/material.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  int consumedCalories = 0;
  int totalCalories = 2000; // Example total calories
  List<String> provisionalFoods = []; // List to hold emojis of provisionally added foods
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus the search box when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
          // Fixed header - always visible, doesn't scroll
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                // Calories display (X/Y format)
                Text(
                  '$consumedCalories/$totalCalories',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Emoji area for provisionally added foods
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        // Display emojis of provisionally added foods
                        if (provisionalFoods.isEmpty)
                          Text(
                            'Added foods...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: provisionalFoods.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    provisionalFoods[index],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Dropdown arrow (⬇️)
                GestureDetector(
                  onTap: () {
                    // TODO: Show detailed view of provisionally added foods
                    _showProvisionalFoodsDetails();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⬇️',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Close button (X)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable content area for food search results
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                  // Placeholder for future food search results
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.search,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Food Search Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Search results will appear here',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Example food items (placeholder)
                  ...List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('🍎', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Food Item ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${(index + 1) * 50} calories',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Add to provisional foods
                              _addToProvisionalFoods('🍎');
                            },
                            icon: const Icon(Icons.add),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    );
                  }),
                  ],
                ),
              ),
            ),
          ),
          
          // Search box at the bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: '🔍 Search for foods...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onTapOutside: (event) {
                // Hide keyboard when tapping outside the text field
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _addToProvisionalFoods(String emoji) {
    setState(() {
      provisionalFoods.add(emoji);
      consumedCalories += 50; // Example: add 50 calories per food
    });
  }

  void _showProvisionalFoodsDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Provisional Foods'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provisionalFoods.isEmpty)
              const Text('No provisional foods added yet')
            else
              ...provisionalFoods.map((emoji) => ListTile(
                leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                title: Text('Food with $emoji'),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      provisionalFoods.remove(emoji);
                      consumedCalories -= 50; // Example: remove 50 calories
                    });
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}