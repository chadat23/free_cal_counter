import 'package:meal_of_record/models/food_serving.dart';
import 'package:meal_of_record/services/image_storage_service.dart';

class Food {
  final int id;
  final String source;
  final String name;
  final String? emoji;
  final String? thumbnail;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;
  final List<FoodServing> servings;
  final String? usageNote;
  final int? parentId;
  final int? sourceFdcId;
  final String? sourceBarcode;
  final bool hidden;

  Food({
    required this.id,
    required this.source,
    required this.name,
    this.emoji,
    this.thumbnail,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    this.servings = const [], // Initialize with an empty list
    this.usageNote,
    this.parentId,
    this.sourceFdcId,
    this.sourceBarcode,
    this.hidden = false,
  });

  Food copyWith({
    int? id,
    String? source,
    String? name,
    String? emoji,
    String? thumbnail,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? fiber,
    List<FoodServing>? servings,
    String? usageNote,
    int? parentId,
    int? sourceFdcId,
    String? sourceBarcode,
    bool? hidden,
  }) {
    return Food(
      id: id ?? this.id,
      source: source ?? this.source,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      thumbnail: thumbnail ?? this.thumbnail,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      fiber: fiber ?? this.fiber,
      servings: servings ?? this.servings,
      usageNote: usageNote ?? this.usageNote,
      parentId: parentId ?? this.parentId,
      sourceFdcId: sourceFdcId ?? this.sourceFdcId,
      sourceBarcode: sourceBarcode ?? this.sourceBarcode,
      hidden: hidden ?? this.hidden,
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as int,
      source: json['source'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      thumbnail: json['thumbnail'] as String?,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      servings:
          (json['servings'] as List<dynamic>?)
              ?.map((e) => FoodServing.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      usageNote: json['usageNote'] as String?,
      parentId: json['parentId'] as int?,
      sourceFdcId: json['sourceFdcId'] as int?,
      sourceBarcode: json['sourceBarcode'] as String?,
      hidden: json['hidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'name': name,
      'emoji': emoji,
      'thumbnail': thumbnail,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'fiber': fiber,
      'servings': servings.map((e) => e.toJson()).toList(),
      'usageNote': usageNote,
      'parentId': parentId,
      'sourceFdcId': sourceFdcId,
      'sourceBarcode': sourceBarcode,
      'hidden': hidden,
    };
  }

  /// Check if the thumbnail refers to a local image
  bool isLocalImage() {
    return thumbnail != null &&
        thumbnail!.startsWith(ImageStorageService.localPrefix);
  }

  /// Extract the GUID from a local thumbnail string
  String? getLocalImageGuid() {
    if (!isLocalImage()) {
      return null;
    }
    return thumbnail!.substring(ImageStorageService.localPrefix.length);
  }

  /// Get the display thumbnail (local path or URL)
  /// For local images, returns the full file path
  /// For URLs, returns the URL as-is
  String? getDisplayThumbnail() {
    if (!isLocalImage()) {
      return thumbnail;
    }
    // For local images, return the GUID with prefix
    // The caller will use ImageStorageService.getImagePath() to get the full path
    return thumbnail;
  }
}
