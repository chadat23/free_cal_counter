# Image Refactoring Implementation Plan

## Overview
This plan addresses two code quality improvements for the image-related functionality:
1. Consolidate the `_localPrefix` constant to a single location
2. Use `FoodImageWidget` in `FoodEditScreen` preview instead of duplicating logic

**Recommended Approach for Improvement 2:** Modify `FoodImageWidget` API to accept optional parameters (Approach 2)

---

## Improvement 1: Consolidate `_localPrefix` Constant

### Current State
The `_localPrefix` constant is duplicated in two files:

| File | Line | Constant |
|------|------|----------|
| [`lib/models/food.dart`](lib/models/food.dart:5) | 5 | `static const String _localPrefix = 'local:';` |
| [`lib/services/image_storage_service.dart`](lib/services/image_storage_service.dart:12) | 12 | `static const String _localPrefix = 'local:';` |

### Problem
- Risk of inconsistency if one is changed without updating the other
- Violates DRY (Don't Repeat Yourself) principle
- Makes the code harder to maintain

### Solution Options

#### Option A: Move to `ImageStorageService` (Recommended)
Make `ImageStorageService` the single source of truth and expose the constant publicly.

**Pros:**
- `ImageStorageService` is already the central service for image operations
- Logical place for image-related constants
- Minimal changes to existing code

**Cons:**
- `Food` model would need to reference the service (minor coupling)

#### Option B: Create a Constants File
Create a new `lib/config/image_constants.dart` file.

**Pros:**
- Clear separation of concerns
- Easy to add more image-related constants in the future
- No coupling between model and service

**Cons:**
- Adds a new file for a single constant
- May be overkill for just one constant

### Recommended Approach: Option A

### Implementation Steps

#### Step 1: Update `ImageStorageService`
Change the `_localPrefix` from private to public:

```dart
// lib/services/image_storage_service.dart
class ImageStorageService {
  static final ImageStorageService instance = ImageStorageService._();
  ImageStorageService._();

  // Change from private to public
  static const String localPrefix = 'local:';
  static const String _imagesFolderName = 'app_images';
  static const int _maxImageSize = 200;
  static const int _jpegQuality = 85;
  
  // ... rest of the code
  
  /// Check if a thumbnail string refers to a local image
  bool isLocalImage(String? thumbnail) {
    return thumbnail != null && thumbnail.startsWith(localPrefix);
  }

  /// Extract the GUID from a local thumbnail string
  String? extractGuid(String thumbnail) {
    if (!isLocalImage(thumbnail)) {
      return null;
    }
    return thumbnail.substring(localPrefix.length);
  }
}
```

#### Step 2: Update `Food` Model
Remove the duplicate constant and reference `ImageStorageService.localPrefix`:

```dart
// lib/models/food.dart
import 'package:meal_of_record/services/image_storage_service.dart';

class Food {
  // Remove this line:
  // static const String _localPrefix = 'local:';
  
  final int id;
  final String source;
  final String name;
  final String? emoji;
  final String? thumbnail;
  // ... rest of the fields
  
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
  String? getDisplayThumbnail() {
    if (!isLocalImage()) {
      return thumbnail;
    }
    return thumbnail;
  }
}
```

#### Step 3: Update `FoodEditScreen`
Update the string manipulation to use the constant:

```dart
// lib/screens/food_edit_screen.dart

Widget _buildThumbnailImage() {
  // Use the constant instead of hardcoded string
  final guid = _thumbnail?.replaceFirst(
    ImageStorageService.localPrefix, 
    ''
  );
  if (guid == null) {
    return _buildEmptyPlaceholder();
  }
  
  // ... rest of the code
}
```

#### Step 4: Verify All References
Search for any other occurrences of `'local:'` string literal in the codebase:

```bash
# Search for hardcoded 'local:' strings
grep -r "local:" lib/ --include="*.dart"
```

Update any found occurrences to use `ImageStorageService.localPrefix`.

---

## Improvement 2: Use `FoodImageWidget` in `FoodEditScreen`

### Current State
[`FoodEditScreen._buildThumbnailImage()`](lib/screens/food_edit_screen.dart:302) duplicates the image loading logic from [`FoodImageWidget._buildLocalImage()`](lib/widgets/food_image_widget.dart:32):

```dart
// FoodEditScreen - duplicated logic (lines 302-332)
Widget _buildThumbnailImage() {
  final guid = _thumbnail?.replaceFirst('local:', '');
  if (guid == null) {
    return _buildEmptyPlaceholder();
  }

  return FutureBuilder<String>(
    future: ImageStorageService.instance.getImagePath(guid),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return _buildEmptyPlaceholder();
      }

      final imagePath = snapshot.data!;
      final imageFile = File(imagePath);

      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildEmptyPlaceholder();
          },
        ),
      );
    },
  );
}
```

### Problem
- Code duplication
- Maintenance burden (changes need to be made in two places)
- Inconsistent styling between preview and actual display

### Solution
Modify `FoodImageWidget` to accept optional parameters directly, allowing it to work with or without a full `Food` object.

**Why this approach is recommended:**
- Better design principle (Interface Segregation)
- More reusable for future use cases (recipes, custom meals, etc.)
- Cleaner code - no need to create fake/temporary objects
- Better performance - no unnecessary object allocation
- More maintainable - decoupled from `Food` structure

### Implementation Steps

**Step 1: Search for all FoodImageWidget usages**
Before modifying the API, verify all existing usages:

```bash
# Search for all usages
grep -r "FoodImageWidget" lib/ --include="*.dart"
```

Expected findings:
- [`lib/widgets/portion_widget.dart:61`](lib/widgets/portion_widget.dart:61) - Uses `food` parameter
- Any other usages?

**Step 2: Modify `FoodImageWidget` API**

```dart
// lib/widgets/food_image_widget.dart

/// Widget for displaying food images with fallbacks.
///
/// Priority: local image > network thumbnail > emoji > placeholder
///
/// Usage with a Food object:
/// ```dart
/// FoodImageWidget(food: myFood, size: 40)
/// ```
///
/// Usage with individual parameters (e.g., during editing):
/// ```dart
/// FoodImageWidget(thumbnail: 'local:abc123', emoji: '🍎', size: 80)
/// ```
class FoodImageWidget extends StatelessWidget {
  final Food? food;
  final String? thumbnail;
  final String? emoji;
  final double? size;
  final VoidCallback? onTap;

  const FoodImageWidget({
    super.key,
    this.food,
    this.thumbnail,
    this.emoji,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided food if available, otherwise use individual parameters
    final displayThumbnail = food?.thumbnail ?? thumbnail;
    final displayEmoji = food?.emoji ?? emoji;
    
    // Priority: local image > OFF thumbnail > emoji > placeholder
    if (displayThumbnail != null && displayThumbnail.startsWith(ImageStorageService.localPrefix)) {
      return _buildLocalImage(context, displayThumbnail);
    } else if (displayThumbnail != null && displayThumbnail.isNotEmpty) {
      return _buildNetworkImage(context, displayThumbnail);
    } else if (displayEmoji != null && displayEmoji.isNotEmpty) {
      return _buildEmoji(context, displayEmoji);
    } else {
      return _buildPlaceholder(context);
    }
  }

  Widget _buildLocalImage(BuildContext context, String thumbnail) {
    final guid = thumbnail.replaceFirst(ImageStorageService.localPrefix, '');
    if (guid.isEmpty) {
      return _buildPlaceholder(context);
    }

    return FutureBuilder<String>(
      future: ImageStorageService.instance.getImagePath(guid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildPlaceholder(context);
        }

        final imagePath = snapshot.data!;
        final imageFile = File(imagePath);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkImage(BuildContext context, String thumbnail) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: thumbnail,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(context),
            errorWidget: (context, url, error) => _buildPlaceholder(context),
          ),
        ),
      ),
    );
  }

  Widget _buildEmoji(BuildContext context, String emoji) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size != null ? size! * 0.6 : 32),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.restaurant,
            size: size != null ? size! * 0.6 : 32,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
```

**Step 3: Update `FoodEditScreen` to use the new API**

```dart
// lib/screens/food_edit_screen.dart

Widget _buildImagePreview() {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[600]!, width: 2),
    ),
    child: _thumbnail != null
        ? _buildThumbnailImage()
        : _buildEmptyPlaceholder(),
  );
}

Widget _buildThumbnailImage() {
  return FoodImageWidget(
    thumbnail: _thumbnail,
    emoji: _emojiController.text,
    size: 80,
    onTap: _pickImage,
  );
}

Widget _buildEmptyPlaceholder() {
  return GestureDetector(
    onTap: _pickImage,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          'No Image',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    ),
  );
}
```

**Step 4: Remove duplicated code**
Delete the old `_buildThumbnailImage()` method (lines 302-332) that duplicated the logic from `FoodImageWidget`.

**Step 5: Verify backward compatibility**
Ensure existing usages still work:
- [`lib/widgets/portion_widget.dart:61`](lib/widgets/portion_widget.dart:61) should continue to work with `FoodImageWidget(food: portion.food, size: 40.0)`

---

## Implementation Order

### Phase 1: Consolidate `_localPrefix` Constant
1. Update `ImageStorageService` to make `localPrefix` public
2. Update `Food` model to use `ImageStorageService.localPrefix`
3. Update `FoodEditScreen` to use `ImageStorageService.localPrefix`
4. Search and update any other occurrences
5. Test all screens that display images

### Phase 2: Use `FoodImageWidget` in `FoodEditScreen`
1. Search for all FoodImageWidget usages
2. Modify FoodImageWidget API to accept optional parameters
3. Update FoodEditScreen to use the new API
4. Remove duplicated code from FoodEditScreen
5. Test image preview in FoodEditScreen
6. Verify all existing image displays still work correctly

---

## Testing Checklist

### After Improvement 1:
- [ ] Images display correctly in FoodEditScreen preview
- [ ] Images display correctly in LogQueueScreen
- [ ] Images display correctly in LogScreen
- [ ] Images display correctly in SearchScreen
- [ ] Image picker works (camera and gallery)
- [ ] Image removal works
- [ ] Image replacement works (old image deleted, new image saved)

### After Improvement 2:
- [ ] Image preview shows correctly in FoodEditScreen
- [ ] Image preview updates when image is changed
- [ ] Image preview shows placeholder when no image
- [ ] Tapping preview opens image picker
- [ ] All existing image displays still work correctly
- [ ] No visual differences between preview and actual display

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing image display | Low | High | Comprehensive testing after each change |
| Performance regression | Low | Low | No significant performance changes expected |
| Increased coupling between Food and ImageStorageService | Low | Low | Acceptable trade-off for eliminating duplication |
| Ripple effects from modifying FoodImageWidget | Low | Medium | Search all usages first; existing code with `food` parameter continues to work |
| Confusion about when to use food vs individual parameters | Low | Low | Add clear documentation comments to FoodImageWidget |

---

## Files to Modify

### Improvement 1:
1. [`lib/services/image_storage_service.dart`](lib/services/image_storage_service.dart)
2. [`lib/models/food.dart`](lib/models/food.dart)
3. [`lib/screens/food_edit_screen.dart`](lib/screens/food_edit_screen.dart)

### Improvement 2:
1. [`lib/widgets/food_image_widget.dart`](lib/widgets/food_image_widget.dart)
2. [`lib/screens/food_edit_screen.dart`](lib/screens/food_edit_screen.dart)

---

## Summary

These improvements will:
- ✅ Eliminate code duplication
- ✅ Improve maintainability
- ✅ Reduce risk of inconsistencies
- ✅ Make the codebase more DRY
- ✅ Provide a single source of truth for image-related constants

The changes are low-risk and will improve code quality without affecting functionality.
