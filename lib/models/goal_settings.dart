enum GoalMode { gain, lose, maintain }

enum MacroCalculationMode {
  proteinFat, // Legacy: Enter Protein + Fat, Carbs is remainder
  proteinCarbs, // New: Enter Protein + Carbs, Fat is remainder
}

enum ProteinTargetMode {
  fixed, // User enters specific grams
  percentageOfWeight, // User enters multiplier (g per weight unit)
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
  final ProteinTargetMode proteinTargetMode;
  final double proteinMultiplier;
  final double fixedDelta; // Used for gain/lose modes
  final DateTime lastTargetUpdate;
  final bool useMetric;
  final bool isSet;
  final bool enableSmartTargets;
  final int correctionWindowDays;

  GoalSettings({
    required this.anchorWeight,
    required this.maintenanceCaloriesStart,
    required this.proteinTarget,
    required this.fatTarget,
    required this.carbTarget,
    required this.fiberTarget,
    required this.mode,
    required this.calculationMode,
    required this.proteinTargetMode,
    required this.proteinMultiplier,
    required this.fixedDelta,
    required this.lastTargetUpdate,
    this.useMetric = false,
    this.isSet = true,
    this.enableSmartTargets = true,
    this.correctionWindowDays = 30,
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
      proteinTargetMode: ProteinTargetMode.values.firstWhere(
        (e) => e.toString() == (json['proteinTargetMode'] as String? ?? ''),
        orElse: () => ProteinTargetMode.fixed,
      ),
      proteinMultiplier: (json['proteinMultiplier'] as num? ?? 1.0).toDouble(),
      fixedDelta: (json['fixedDelta'] as num? ?? 0.0).toDouble(),
      lastTargetUpdate: DateTime.fromMillisecondsSinceEpoch(
        json['lastTargetUpdate'] as int? ?? 0,
      ),
      useMetric: json['useMetric'] as bool? ?? false,
      isSet: json['isSet'] as bool? ?? true,
      enableSmartTargets: json['enableSmartTargets'] as bool? ?? true,
      correctionWindowDays: json['correctionWindowDays'] as int? ?? 30,
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
      'proteinTargetMode': proteinTargetMode.toString(),
      'proteinMultiplier': proteinMultiplier,
      'fixedDelta': fixedDelta,
      'lastTargetUpdate': lastTargetUpdate.millisecondsSinceEpoch,
      'useMetric': useMetric,
      'isSet': isSet,
      'enableSmartTargets': enableSmartTargets,
      'correctionWindowDays': correctionWindowDays,
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
      proteinTargetMode: ProteinTargetMode.fixed,
      proteinMultiplier: 1.0,
      fixedDelta: 0.0,
      lastTargetUpdate: DateTime(2000), // Far in the past to trigger update
      useMetric: false,
      isSet: false,
      enableSmartTargets: true,
      correctionWindowDays: 30,
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
    ProteinTargetMode? proteinTargetMode,
    double? proteinMultiplier,
    double? fixedDelta,
    DateTime? lastTargetUpdate,
    bool? useMetric,
    bool? isSet,
    bool? enableSmartTargets,
    int? correctionWindowDays,
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
      proteinTargetMode: proteinTargetMode ?? this.proteinTargetMode,
      proteinMultiplier: proteinMultiplier ?? this.proteinMultiplier,
      fixedDelta: fixedDelta ?? this.fixedDelta,
      lastTargetUpdate: lastTargetUpdate ?? this.lastTargetUpdate,
      useMetric: useMetric ?? this.useMetric,
      isSet: isSet ?? this.isSet,
      enableSmartTargets: enableSmartTargets ?? this.enableSmartTargets,
      correctionWindowDays: correctionWindowDays ?? this.correctionWindowDays,
    );
  }
}
