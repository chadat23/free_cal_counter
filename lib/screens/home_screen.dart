import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bar Graph Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  // Row 1: Bars + X F of Y
                  Row(
                    children: [
                      // 7 bar graphs for row 1 - using fixed column widths
                      Expanded(
                        child: Row(
                          children: List.generate(7, (columnIndex) {
                            bool isToday = columnIndex == 2;
                            return Expanded(
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.blue[400] : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TinyBar(value: 0.5),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // X F of Y labels for row 1
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'X 🔥',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'of Y',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Row 2: Bars + X P of Y
                  Row(
                    children: [
                      // 7 bar graphs for row 2 - using fixed column widths
                      Expanded(
                        child: Row(
                          children: List.generate(7, (columnIndex) {
                            bool isToday = columnIndex == 2;
                            return Expanded(
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.blue[400] : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // X P of Y labels for row 2
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'X P',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'of Y',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Row 3: Bars + X F of Y
                  Row(
                    children: [
                      // 7 bar graphs for row 3 - using fixed column widths
                      Expanded(
                        child: Row(
                          children: List.generate(7, (columnIndex) {
                            bool isToday = columnIndex == 2;
                            return Expanded(
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.blue[400] : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // X F of Y labels for row 3
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'X F',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'of Y',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Row 4: Bars + X C of Y
                  Row(
                    children: [
                      // 7 bar graphs for row 4 - using fixed column widths
                      Expanded(
                        child: Row(
                          children: List.generate(7, (columnIndex) {
                            bool isToday = columnIndex == 2;
                            return Expanded(
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isToday ? Colors.blue[400] : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // X C of Y labels for row 4
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'X C',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'of Y',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Day labels row - now with consistent spacing
                  Row(
                    children: [
                      // 7 day labels aligned with their respective bar columns
                      Expanded(
                        child: Row(
                          children: [
                            // Use the same spacing logic as the bars
                            ...List.generate(7, (columnIndex) {
                              bool isToday = columnIndex == 2;
                              return Expanded(
                                child: Center(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'D', // Placeholder: will be programmatically set
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isToday ? Colors.blue[700] : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Blank space to maintain consistent layout
                      const SizedBox(width: 20, height: 30),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Placeholder for additional content
            Text(
              'Additional dashboard content will go here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double mmToLogicalPx(BuildContext context, double mm) {
  final dpi = MediaQuery.of(context).devicePixelRatio * 160;
  return mm * dpi / 25.4;
}

class TinyBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  const TinyBar({super.key, required this.value});

  double mmToLogicalPx(BuildContext context, double mm) {
    final dpi = MediaQuery.of(context).devicePixelRatio * 160;
    return mm * dpi / 25.4;
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = mmToLogicalPx(context, 1.5);
    final barHeight = mmToLogicalPx(context, 5);

    return Container(
      width: barWidth,
      height: barHeight,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: FractionallySizedBox(
        heightFactor: value, // scales bar fill
        child: Container(color: Colors.blue),
      ),
    );
  }
}