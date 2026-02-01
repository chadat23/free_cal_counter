import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:free_cal_counter1/models/food.dart';
import 'package:free_cal_counter1/services/image_storage_service.dart';
import 'package:free_cal_counter1/services/emoji_service.dart';

/// Widget for displaying food images with fallbacks.
///
/// Priority: local image > network thumbnail > custom emoji (not default) > smart emoji > placeholder
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

    // Priority: local image > network thumbnail > custom emoji (not default) > smart emoji > placeholder
    if (displayThumbnail != null &&
        displayThumbnail.startsWith(ImageStorageService.localPrefix)) {
      return _buildLocalImage(context, displayThumbnail);
    } else if (displayThumbnail != null && displayThumbnail.isNotEmpty) {
      return _buildNetworkImage(context, displayThumbnail);
    } else if (displayEmoji != null &&
        displayEmoji.isNotEmpty &&
        displayEmoji != '🍴') {
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
