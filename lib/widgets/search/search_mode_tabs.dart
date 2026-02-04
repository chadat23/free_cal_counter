import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:free_cal_counter1/models/search_mode.dart';
import 'package:free_cal_counter1/providers/search_provider.dart';
import 'package:free_cal_counter1/screens/barcode_scanner_screen.dart';

class SearchModeTabs extends StatelessWidget {
  const SearchModeTabs({super.key});

  Future<void> _handleScanTap(BuildContext context) async {
    final provider = Provider.of<SearchProvider>(context, listen: false);

    // Launch the barcode scanner
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    // If a barcode was scanned, perform the search
    if (barcode != null && barcode.isNotEmpty) {
      provider.barcodeSearch(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(
              0xFF2D2D2D,
            ), // Use smallWidgetBackground type color
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              _buildTab(context, provider, SearchMode.text, Icons.search),
              _buildScanTab(context, provider),
              _buildTab(
                context,
                provider,
                SearchMode.recipe,
                Icons.restaurant_menu,
              ),
              _buildTab(context, provider, SearchMode.food, Icons.restaurant),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanTab(BuildContext context, SearchProvider provider) {
    // Scan tab is never "selected" since it immediately launches scanner
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleScanTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    SearchProvider provider,
    SearchMode mode,
    IconData icon,
  ) {
    final isSelected = provider.searchMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSearchMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }
}
