import 'package:flutter/material.dart';

/// A reusable widget that provides a dropdown of existing units
/// and a "Custom..." option that reveals a text field.
class UnitSelectField extends StatefulWidget {
  final String label;
  final String value;
  final List<String> availableUnits;
  final ValueChanged<String> onChanged;

  const UnitSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.availableUnits,
    required this.onChanged,
  });

  @override
  State<UnitSelectField> createState() => _UnitSelectFieldState();
}

class _UnitSelectFieldState extends State<UnitSelectField> {
  bool _isCustom = false;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _checkInitialValue();
  }

  void _checkInitialValue() {
    // If value is not 'serving' and not in available units, it's custom
    final isKnown = ['serving', ...widget.availableUnits].contains(widget.value);
    _isCustom = !isKnown && widget.value.isNotEmpty;
    _customController = TextEditingController(text: _isCustom ? widget.value : '');
  }

  @override
  void didUpdateWidget(UnitSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value || widget.availableUnits != oldWidget.availableUnits) {
       _checkValueUpdate();
    }
  }

  void _checkValueUpdate() {
    final isKnown = ['serving', ...widget.availableUnits].contains(widget.value);
    final shouldBeCustom = !isKnown && widget.value.isNotEmpty;
    
    if (shouldBeCustom != _isCustom) {
      setState(() {
        _isCustom = shouldBeCustom;
        if (_isCustom) {
          _customController.text = widget.value;
        }
      });
    } else if (_isCustom && _customController.text != widget.value) {
      _customController.text = widget.value;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCustom) {
      return TextFormField(
        controller: _customController,
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() {
                _isCustom = false;
                _customController.clear();
                widget.onChanged('serving');
              });
            },
          ),
        ),
        onChanged: widget.onChanged,
        autofocus: true,
      );
    }

    final units = <String>['serving'];
    for (final unit in widget.availableUnits) {
      if (!units.contains(unit)) {
        units.add(unit);
      }
    }

    // Ensure current value is in the list for the dropdown
    String? dropdownValue = widget.value;
    if (!units.contains(dropdownValue)) {
      dropdownValue = 'serving';
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          dropdownColor: Colors.grey[800],
          isExpanded: true,
          isDense: true,
          items: [
            ...units.map(
              (unit) => DropdownMenuItem(
                value: unit,
                child: Text(unit),
              ),
            ),
            const DropdownMenuItem(
              value: '_custom_',
              child: Text('Custom...'),
            ),
          ],
          onChanged: (val) {
            if (val == '_custom_') {
              setState(() {
                _isCustom = true;
              });
            } else if (val != null) {
              widget.onChanged(val);
            }
          },
        ),
      ),
    );
  }
}
