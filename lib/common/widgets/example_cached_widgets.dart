import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/helper/simple_image_cache.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';

/// Example of how to use cached images in banner widgets
class ExampleCachedBannerWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;
  final double height;

  const ExampleCachedBannerWidget({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CachedBannerImage(
          imageUrl: imageUrl,
          height: height,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
      ),
    );
  }
}

/// Example of how to use cached images for restaurant/food items
class ExampleCachedItemWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const ExampleCachedItemWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cached image
            CachedImageWidget(
              imageUrl: imageUrl,
              height: 120,
              width: double.infinity,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Dimensions.radiusDefault),
                topRight: Radius.circular(Dimensions.radiusDefault),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

