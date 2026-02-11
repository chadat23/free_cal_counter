import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_of_record/models/goal_settings.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/widgets/screen_background.dart';
import 'package:meal_of_record/utils/ui_utils.dart';

class GoalSettingsScreen extends StatefulWidget {
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen> {
  late TextEditingController _anchorWeightController;
  late TextEditingController _maintenanceCalController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbController;
  late TextEditingController _fiberController;
  late TextEditingController _fixedDeltaController;
  late GoalMode _mode;
  late MacroCalculationMode _calcMode;
  late bool _useMetric;
  late bool _enableSmartTargets;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<GoalsProvider>(
      context,
      listen: false,
    ).settings;

    _anchorWeightController = TextEditingController(
      text: settings.anchorWeight.toString(),
    );
    _maintenanceCalController = TextEditingController(
      text: settings.maintenanceCaloriesStart.toString(),
    );
    _proteinController = TextEditingController(
      text: settings.proteinTarget.toString(),
    );
    _fatController = TextEditingController(text: settings.fatTarget.toString());
    _carbController = TextEditingController(
      text: settings.carbTarget.toString(),
    );
    _fiberController = TextEditingController(
      text: settings.fiberTarget.toString(),
    );
    _fixedDeltaController = TextEditingController(
      text: settings.fixedDelta.toString(),
    );
    _mode = settings.mode;
    _calcMode = settings.calculationMode;
    _useMetric = settings.useMetric;
    _enableSmartTargets = settings.enableSmartTargets;
  }

  @override
  void dispose() {
    _anchorWeightController.dispose();
    _maintenanceCalController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbController.dispose();
    _fiberController.dispose();
    _fixedDeltaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validate required fields
    final maintenanceCal = double.tryParse(_maintenanceCalController.text);
    if (maintenanceCal == null || maintenanceCal <= 0) {
      UiUtils.showAutoDismissDialog(
        context,
        'Please enter valid maintenance calories',
      );
      return;
    }

    final protein = double.tryParse(_proteinController.text);
    if (protein == null || protein <= 0) {
      UiUtils.showAutoDismissDialog(
        context,
        'Please enter valid protein target',
      );
      return;
    }

    final fat = double.tryParse(_fatController.text);
    if (_calcMode == MacroCalculationMode.proteinFat &&
        (fat == null || fat <= 0)) {
      UiUtils.showAutoDismissDialog(context, 'Please enter valid fat target');
      return;
    }

    final carbs = double.tryParse(_carbController.text);
    if (_calcMode == MacroCalculationMode.proteinCarbs &&
        (carbs == null || carbs <= 0)) {
      UiUtils.showAutoDismissDialog(context, 'Please enter valid carb target');
      return;
    }

    final fiber = double.tryParse(_fiberController.text);
    if (fiber == null || fiber <= 0) {
      UiUtils.showAutoDismissDialog(context, 'Please enter valid fiber target');
      return;
    }

    // For maintain mode, validate target weight
    double? targetWeight;
    if (_mode == GoalMode.maintain) {
      targetWeight = double.tryParse(_anchorWeightController.text);
      if (targetWeight == null || targetWeight <= 0) {
        UiUtils.showAutoDismissDialog(
          context,
          'Please enter a valid target weight',
        );
        return;
      }
    }

    // For lose/gain modes, validate delta
    double? delta;
    if (_mode != GoalMode.maintain) {
      delta = double.tryParse(_fixedDeltaController.text);
      if (delta == null || delta <= 0) {
        UiUtils.showAutoDismissDialog(context, 'Please enter a valid delta');
        return;
      }
    }

    // Detect if this is initial setup
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    final isInitialSetup = !goalsProvider.isGoalsSet;

    final newSettings = GoalSettings(
      anchorWeight:
          targetWeight ?? double.tryParse(_anchorWeightController.text) ?? 0.0,
      maintenanceCaloriesStart: maintenanceCal,
      proteinTarget: protein,
      fatTarget: fat ?? 0.0,
      carbTarget: carbs ?? 0.0,
      fiberTarget: fiber,
      mode: _mode,
      calculationMode: _calcMode,
      fixedDelta: _mode != GoalMode.maintain ? delta! : 0.0,
      lastTargetUpdate: goalsProvider.settings.lastTargetUpdate,
      useMetric: _useMetric,
      isSet: true,
      enableSmartTargets: _enableSmartTargets,
    );

    await goalsProvider.saveSettings(
      newSettings,
      isInitialSetup: isInitialSetup,
    );

    // Switch to Overview tab
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    navProvider.changeTab(0);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      appBar: AppBar(
        title: const Text('Goals & Targets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Goal Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildModeSelector(),
          const Divider(height: 40),
          if (_mode == GoalMode.maintain)
            _buildTextField(
              controller: _anchorWeightController,
              label: 'Target Weight (${_useMetric ? 'kg' : 'lb'})',
              hint: 'Your target weight',
            ),
          SwitchListTile(
            title: const Text('Smart Target Calculations'),
            subtitle: const Text(
              'When enabled, targets are automatically adjusted based on weight trends after the first week.',
            ),
            value: _enableSmartTargets,
            onChanged: (val) => setState(() => _enableSmartTargets = val),
          ),
          SwitchListTile(
            title: const Text('Use Metric Units (kg)'),
            subtitle: const Text('Affects calorie drift calculation'),
            value: _useMetric,
            onChanged: (val) => setState(() => _useMetric = val),
          ),
          _buildTextField(
            controller: _maintenanceCalController,
            label: 'Initial Maintenance Calories',
            hint: 'Your estimated TDEE',
            keyboardType: TextInputType.number,
          ),
          if (_mode != GoalMode.maintain)
            _buildTextField(
              controller: _fixedDeltaController,
              label: _mode == GoalMode.gain ? 'Serplus' : 'Deficit',
              hint: 'e.g. 500',
              keyboardType: TextInputType.number,
            ),
          const Divider(height: 40),
          const Text(
            'Macro Split Strategy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildCalcModeSelector(),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _proteinController,
            label: 'Protein (g)',
            keyboardType: TextInputType.number,
          ),
          if (_calcMode == MacroCalculationMode.proteinFat)
            _buildTextField(
              controller: _fatController,
              label: 'Fat (g)',
              keyboardType: TextInputType.number,
            ),
          if (_calcMode == MacroCalculationMode.proteinCarbs)
            _buildTextField(
              controller: _carbController,
              label: 'Carbs (g)',
              keyboardType: TextInputType.number,
            ),
          _buildTextField(
            controller: _fiberController,
            label: 'Fiber (g)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose what to calculate as the remainder:',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SegmentedButton<MacroCalculationMode>(
          segments: const [
            ButtonSegment(
              value: MacroCalculationMode.proteinCarbs,
              label: Text('Calc Fat'),
              tooltip: 'Enter Protein & Carbs',
            ),
            ButtonSegment(
              value: MacroCalculationMode.proteinFat,
              label: Text('Calc Carbs'),
              tooltip: 'Enter Protein & Fat',
            ),
          ],
          selected: {_calcMode},
          onSelectionChanged: (newSelection) {
            setState(() {
              _calcMode = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return SegmentedButton<GoalMode>(
      segments: const [
        ButtonSegment(value: GoalMode.lose, label: Text('Lose')),
        ButtonSegment(value: GoalMode.maintain, label: Text('Maintain')),
        ButtonSegment(value: GoalMode.gain, label: Text('Gain')),
      ],
      selected: {_mode},
      onSelectionChanged: (newSelection) {
        setState(() {
          _mode = newSelection.first;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
