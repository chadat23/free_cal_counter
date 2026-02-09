enum GoalMode { gain, lose, maintain }

enum MacroCalculationMode {
  proteinFat, // Legacy: Enter Protein + Fat, Carbs is remainder
  proteinCarbs, // New: Enter Protein + Carbs, Fat is remainder
}

class GoalSettings {
  final double anchorWeight;
  final double maintenanceCaloriesStart;
  final double proteinTarget; // In grams
  final double fatTarget; // In grams
  final double carbTarget; // In grams
  final double fiberTarget; // In grams
  final GoalMode mode;
  final MacroCalculationMode calculationMode;
  final double fixedDelta; // Used for gain/lose modes
  final DateTime lastTargetUpdate;
  final bool useMetric;
  final bool isSet;
  final bool enableSmartTargets;

  GoalSettings({
    required this.anchorWeight,
    required this.maintenanceCaloriesStart,
    required this.proteinTarget,
    required this.fatTarget,
    required this.carbTarget,
    required this.fiberTarget,
    required this.mode,
    required this.calculationMode,
    required this.fixedDelta,
    required this.lastTargetUpdate,
    this.useMetric = false,
    this.isSet = true,
    this.enableSmartTargets = true,
  });

  factory GoalSettings.fromJson(Map<String, dynamic> json) {
    return GoalSettings(
      anchorWeight: (json['anchorWeight'] as num).toDouble(),
      maintenanceCaloriesStart: (json['maintenanceCaloriesStart'] as num)
          .toDouble(),
      proteinTarget: (json['proteinTarget'] as num).toDouble(),
      fatTarget: (json['fatTarget'] as num? ?? 0.0).toDouble(),
      carbTarget: (json['carbTarget'] as num? ?? 0.0).toDouble(),
      fiberTarget: (json['fiberTarget'] as num).toDouble(),
      mode: GoalMode.values.firstWhere(
        (e) => e.toString() == (json['mode'] as String),
        orElse: () => GoalMode.maintain,
      ),
      calculationMode: MacroCalculationMode.values.firstWhere(
        (e) => e.toString() == (json['calculationMode'] as String),
        orElse: () => MacroCalculationMode.proteinCarbs,
      ),
      fixedDelta: (json['fixedDelta'] as num? ?? 0.0).toDouble(),
      lastTargetUpdate: DateTime.fromMillisecondsSinceEpoch(
        json['lastTargetUpdate'] as int? ?? 0,
      ),
      useMetric: json['useMetric'] as bool? ?? false,
      isSet: json['isSet'] as bool? ?? true,
      enableSmartTargets: json['enableSmartTargets'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anchorWeight': anchorWeight,
      'maintenanceCaloriesStart': maintenanceCaloriesStart,
      'proteinTarget': proteinTarget,
      'fatTarget': fatTarget,
      'carbTarget': carbTarget,
      'fiberTarget': fiberTarget,
      'mode': mode.toString(),
      'calculationMode': calculationMode.toString(),
      'fixedDelta': fixedDelta,
      'lastTargetUpdate': lastTargetUpdate.millisecondsSinceEpoch,
      'useMetric': useMetric,
      'isSet': isSet,
      'enableSmartTargets': enableSmartTargets,
    };
  }

  // Helper to create a default settings object
  factory GoalSettings.defaultSettings() {
    return GoalSettings(
      anchorWeight: 0.0,
      maintenanceCaloriesStart: 2000.0,
      proteinTarget: 150.0,
      fatTarget: 70.0,
      carbTarget: 200.0,
      fiberTarget: 38.0,
      mode: GoalMode.maintain,
      calculationMode: MacroCalculationMode.proteinCarbs,
      fixedDelta: 0.0,
      lastTargetUpdate: DateTime(2000), // Far in the past to trigger update
      useMetric: false,
      isSet: false,
      enableSmartTargets: true,
    );
  }

  // Helper to create a copy with some fields changed
  GoalSettings copyWith({
    double? anchorWeight,
    double? maintenanceCaloriesStart,
    double? proteinTarget,
    double? fatTarget,
    double? carbTarget,
    double? fiberTarget,
    GoalMode? mode,
    MacroCalculationMode? calculationMode,
    double? fixedDelta,
    DateTime? lastTargetUpdate,
    bool? useMetric,
    bool? isSet,
    bool? enableSmartTargets,
  }) {
    return GoalSettings(
      anchorWeight: anchorWeight ?? this.anchorWeight,
      maintenanceCaloriesStart:
          maintenanceCaloriesStart ?? this.maintenanceCaloriesStart,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      carbTarget: carbTarget ?? this.carbTarget,
      fiberTarget: fiberTarget ?? this.fiberTarget,
      mode: mode ?? this.mode,
      calculationMode: calculationMode ?? this.calculationMode,
      fixedDelta: fixedDelta ?? this.fixedDelta,
      lastTargetUpdate: lastTargetUpdate ?? this.lastTargetUpdate,
      useMetric: useMetric ?? this.useMetric,
      isSet: isSet ?? this.isSet,
      enableSmartTargets: enableSmartTargets ?? this.enableSmartTargets,
    );
  }
}
