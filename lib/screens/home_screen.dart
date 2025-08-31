import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
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
                _buildBarChartCell(Colors.blue, 100, dayColor: const Color.fromARGB(255, 0, 0, 150)),
                _buildBarChartCell(Colors.blue, 80),
                _buildBarChartCell(Colors.blue, 60, selectionColor: const Color.fromARGB(255, 160, 160, 160)),
                _buildBarChartCell(Colors.blue, 40),
                _buildBarChartCell(Colors.blue, 20),
                _buildBarChartCell(Colors.blue, 0),
                _buildBarChartCell(Colors.blue, 20),
                _buildLabelCell('2000 🔥', 'of 3000'),
              ],
            ),
            // Row 2 (with an empty cell)
            TableRow(
              children: <Widget>[
                _buildBarChartCell(Colors.red, 100, dayColor: const Color.fromARGB(255, 0, 0, 150)),
                _buildBarChartCell(Colors.red, 20),
                _buildBarChartCell(Colors.red, 20, selectionColor: const Color.fromARGB(255, 160, 160, 160)),
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
                _buildBarChartCell(Colors.yellow, 100, dayColor: const Color.fromARGB(255, 0, 0, 150)),
                _buildBarChartCell(Colors.yellow, 20),
                _buildBarChartCell(Colors.yellow, 20, selectionColor: const Color.fromARGB(255, 160, 160, 160)),
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
                _buildBarChartCell(Colors.green, 100, dayColor: const Color.fromARGB(255, 0, 0, 150)),
                _buildBarChartCell(Colors.green, 20),
                _buildBarChartCell(Colors.green, 20, selectionColor: const Color.fromARGB(255, 160, 160, 160)),
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
                _buildEmptyCell(),
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
        // Removed border to eliminate borders between cells
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
        // Removed border to eliminate borders between cells
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

  Widget _buildEmptyCell() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
    );
  }

  // Constants for consistent cell sizing for bar charts
  final double _barChartCellHeight = 50.0; // Example fixed height for the entire cell
  final double _barWidth = 4.0; // Fixed bar width
  final double _maxBarHeight= 20.0; // Max height for the bar itself (at 100%)
  final double _barGraphTrackWidth = 20.0;

  Widget _buildBarChartCell(Color color, double value, {Color dayColor = const Color.fromARGB(255, 110, 110, 110), Color selectionColor = const Color.fromARGB(255, 135, 135, 135)}) {
    // 1. Error Checking: Ensure value is within 0-100
    if (value < 0) {
      debugPrint('Warning: Bar chart value $value is less than 0. Clamping to 0.');
      value = 0;
    }
    if (value > 100) {
      debugPrint('Warning: Bar chart value $value is greater than 100. Clamping to 100.');
      value = 100;
    }

    // Calculate actual bar height based on percentage
    final double currentBarHeight = (_maxBarHeight * (value / 100));

    return Container(
      height: _barChartCellHeight, // Outer container for the entire grid cell
      // Outer container provides overall cell styling (background, rounded border for the cell itself)
      decoration: BoxDecoration(
        color: selectionColor,
      ),
      alignment: Alignment.center, // Center the bar graph component within the cell
      padding: const EdgeInsets.all(4.0), // Padding around the bar graph component from cell edge
      child: SizedBox(
        width: _barGraphTrackWidth, // Defines the total width for the track and bar
        height: _maxBarHeight, // Defines the total height for the track and bar
        child: Stack(
          // The bar should simply grow from the bottom of this Stack
          alignment: Alignment.bottomCenter, // **Crucial: All children align to bottom center**
          children: [
            // 1. Background Track (Rectangular)
            Container(
              width: _barGraphTrackWidth,
              height: _maxBarHeight,
              color: dayColor, // Light grey background for the rectangular track
            ),
            // 2. The Actual Bar (Rectangular, grows upwards from the bottom)
            Container(
              width: _barWidth, // This is the narrower width of the actual bar
              height: currentBarHeight, // Bar grows from bottom up to this height
              color: color, // The actual bar color
            ),
          ],
        ),
      ),
    );
  }
}