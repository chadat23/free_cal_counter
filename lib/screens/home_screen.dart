import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table Grid with Boxes')),
      body: Center(
        child: Table(
          // No border on the Table itself, as cells will have their own
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1.0), // Column 1 content
            1: FlexColumnWidth(1.0), // Column 2 content
            2: FlexColumnWidth(1.0), // Column 3 content
            3: FlexColumnWidth(1.0), // Column 4 content
            4: FlexColumnWidth(1.0), // Column 5 content
            5: FlexColumnWidth(1.0), // Column 6 content
            6: FlexColumnWidth(1.0), // Column 7 content
            7: FixedColumnWidth(80.0), // Row labels
          },
          children: <TableRow>[
            // Row 1
            TableRow(
              children: <Widget>[
                _buildBarChartCell(Colors.blue, 100),
                _buildBarChartCell(Colors.blue, 20),
                _buildBarChartCell(Colors.blue, 20),
                _buildBarChartCell(Colors.blue, 20),
                _buildBarChartCell(Colors.blue, 20),
                _buildBarChartCell(Colors.blue, 20),
                _buildBarChartCell(Colors.blue, 20),
                _buildLabelCell('2000 🔥', 'of 3000'),
              ],
            ),
            // Row 2 (with an empty cell)
            TableRow(
              children: <Widget>[
                _buildBarChartCell(Colors.red, 100),
                _buildBarChartCell(Colors.red, 20),
                _buildBarChartCell(Colors.red, 20),
                _buildBarChartCell(Colors.red, 20),
                _buildBarChartCell(Colors.red, 20),
                _buildBarChartCell(Colors.red, 20),
                _buildBarChartCell(Colors.red, 20),
                _buildLabelCell('125 P', 'of 160'),
              ],
            ),
            // Row 3
            TableRow(
              children: <Widget>[
                _buildBarChartCell(Colors.yellow, 100),
                _buildBarChartCell(Colors.yellow, 20),
                _buildBarChartCell(Colors.yellow, 20),
                _buildBarChartCell(Colors.yellow, 20),
                _buildBarChartCell(Colors.yellow, 20),
                _buildBarChartCell(Colors.yellow, 20),
                _buildBarChartCell(Colors.yellow, 20),
                _buildLabelCell('45 F', 'of 88'),
              ],
            ),
            // Row 4
            TableRow(
              children: <Widget>[
                _buildBarChartCell(Colors.green, 100),
                _buildBarChartCell(Colors.green, 20),
                _buildBarChartCell(Colors.green, 20),
                _buildBarChartCell(Colors.green, 20),
                _buildBarChartCell(Colors.green, 20),
                _buildBarChartCell(Colors.green, 20),
                _buildBarChartCell(Colors.green, 20),
                _buildLabelCell('100 C', 'of 225'),
              ],
            ),
            // Column Labels Row
            TableRow(
              children: <Widget>[
                _buildFooterCell('M'),
                _buildFooterCell('T'),
                _buildFooterCell('W'),
                _buildFooterCell('T'),
                _buildFooterCell('F'),
                _buildFooterCell('S'),
                _buildFooterCell('S'),
                const SizedBox(
                    height: 50,
                    child: Center(child: Text(''))), // Empty top-left corner
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Header cells with a subtle border and background
  Widget _buildFooterCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      height: 50,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Row label cells with a subtle border and background
  Widget _buildLabelCell(String text1, String text2) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            text1,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0),
          ),
          Text(
            text2,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10.0),
          ),
        ],
      ),
    );
  }

  // Content cells now have a clear border
  Widget _buildContentCell(Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), // Light background color
        border: Border.all(color: Colors.black, width: 0.8), // Distinct box border
      ),
      child: Text(text),
    );
  }

  // Empty cells also have a clear border to show they are "boxes"
  Widget _buildEmptyCell() {
    return Container(
      // The height will be determined by the tallest content in the row
      // We are just adding decoration to make it visible as a box
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.black, width: 0.8), // Distinct box border
      ),
    );
  }

  // Constants for consistent cell sizing for bar charts
  final double _barChartCellHeight = 50.0; // Example fixed height for the entire cell
  final double _barWidthFixed = 4.0; // Fixed bar width
  final double _maxBarHeightFixed = 20.0; // Max height for the bar itself (at 100%)

  Widget _buildBarChartCell(Color color, double value) {
    // 1. Error Checking: Ensure value is within 0-100
    if (value < 0) {
      debugPrint('Warning: Bar chart value $value is less than 0. Clamping to 0.');
      value = 0;
    }
    if (value > 100) {
      debugPrint('Warning: Bar chart value $value is greater than 100. Clamping to 100.');
      value = 100;
    }
  
    // 2. Calculate actual bar height based on percentage
    final double barHeight = (_maxBarHeightFixed * (value / 100));
  
    // 3. Create the bar using a Container
    final Widget bar = Container(
      width: _barWidthFixed,
      height: barHeight,
      color: color,
    );
  
    // 4. Wrap the bar and text in a Container with a fixed height
    return Container(
      height: _barChartCellHeight, // <--- **Crucial Change: Fixed height for the cell**
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          bar,
        ],
      ),
    );
  }
}