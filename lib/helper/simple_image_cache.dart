import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Simple image caching helper for better performance
class SimpleImageCache {
  static final CacheManager _cacheManager = DefaultCacheManager();
  
  /// Preload images for better performance
  static Future<void> preloadImages(List<String> imageUrls) async {
    try {
      for (String url in imageUrls) {
        if (url.isNotEmpty) {
          // Preload image without blocking UI
          _cacheManager.getSingleFile(url).catchError((e) {
            // Silently handle errors - don't break the app
            print('Failed to preload image: $url');
          });
        }
      }
    } catch (e) {
      print('Error preloading images: $e');
    }
  }
  
  /// Preload a single image
  static Future<void> preloadImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    
    try {
      await _cacheManager.getSingleFile(imageUrl);
    } catch (e) {
      print('Failed to preload image: $imageUrl');
    }
  }
  
  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }
}

/// Enhanced Image widget with better caching
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => errorWidget ?? Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error_outline),
        ),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      ),
    );
  }
}

/// Banner image widget with optimized caching
class CachedBannerImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const CachedBannerImage({
    super.key,
    required this.imageUrl,
    required this.height,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CachedImageWidget(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        borderRadius: borderRadius,
        placeholder: Container(
          height: height,
          width: double.infinity,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: Container(
          height: height,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 50),
        ),
      ),
    );
  }
}
