import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:video_player/video_player.dart';

class AdvertisementModalWidget extends StatefulWidget {
  final AdvertisementModel advertisement;
  final VoidCallback onClose;

  const AdvertisementModalWidget({
    super.key,
    required this.advertisement,
    required this.onClose,
  });

  @override
  State<AdvertisementModalWidget> createState() => _AdvertisementModalWidgetState();
}

class _AdvertisementModalWidgetState extends State<AdvertisementModalWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    // Initialize video player if it's a video promotion
    if (widget.advertisement.addType == 'video_promotion' && 
        widget.advertisement.videoAttachmentFullUrl != null) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final videoUrl = widget.advertisement.videoAttachmentFullUrl ?? "";
      if (videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }
      
      debugPrint('Initializing video from URL: $videoUrl');
      
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      
      // Add timeout to prevent infinite loading
      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );
      
      // Check if video is actually initialized
      if (!_videoPlayerController!.value.isInitialized) {
        throw Exception('Video controller not initialized');
      }
      
      // Get aspect ratio, default to 1.0 if invalid
      double aspectRatio = _videoPlayerController!.value.aspectRatio;
      if (aspectRatio <= 0 || aspectRatio.isNaN || aspectRatio.isInfinite) {
        aspectRatio = 1.0;
      }
      
      debugPrint('Video initialized successfully. Aspect ratio: $aspectRatio');
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        aspectRatio: aspectRatio,
        showControls: true,
      );
      _chewieController?.setVolume(0); // Mute by default
      
      // Add error listener to detect playback errors
      _videoPlayerController!.addListener(_videoListener);
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _hasVideoError = true;
        });
      }
      // Dispose controllers on error
      _chewieController?.dispose();
      _videoPlayerController?.dispose();
      _chewieController = null;
      _videoPlayerController = null;
    }
  }

  void _videoListener() {
    if (_videoPlayerController != null && _videoPlayerController!.value.hasError) {
      debugPrint('Video player error: ${_videoPlayerController!.value.errorDescription}');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
          _hasVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideo = widget.advertisement.addType == 'video_promotion' && 
                         widget.advertisement.videoAttachmentFullUrl != null;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.orange.shade50, // Touch of orange background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Column(
        children: [
          // Close button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Writeup at the top - Styled header
          if (widget.advertisement.title != null || widget.advertisement.description != null)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                border: Border.all(
                  color: Colors.orange.shade200.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.advertisement.title != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Text(
                        widget.advertisement.title!,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge + 2,
                          color: Colors.orange.shade900,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (widget.advertisement.title != null && widget.advertisement.description != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                      width: 60,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade300,
                            Colors.orange.shade600,
                            Colors.orange.shade300,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  if (widget.advertisement.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Text(
                        widget.advertisement.description!,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault + 1,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Square image or video in the center (smaller size)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: AspectRatio(
                aspectRatio: isVideo && _isVideoInitialized && _videoPlayerController != null && 
                             _videoPlayerController!.value.isInitialized
                    ? (_videoPlayerController!.value.aspectRatio > 0 && 
                       !_videoPlayerController!.value.aspectRatio.isNaN && 
                       !_videoPlayerController!.value.aspectRatio.isInfinite
                        ? _videoPlayerController!.value.aspectRatio 
                        : 1.0)
                    : 1.0, // Square for image, video aspect ratio for video
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: isVideo && _isVideoInitialized && _chewieController != null && 
                           _videoPlayerController != null && 
                           _videoPlayerController!.value.isInitialized
                        ? Chewie(controller: _chewieController!)
                        : isVideo && !_isVideoInitialized && !_hasVideoError
                            ? const Center(child: CircularProgressIndicator())
                            : isVideo && _hasVideoError
                                ? Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline, 
                                            color: Colors.grey.shade600, 
                                            size: 40),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Video unavailable',
                                            style: robotoRegular.copyWith(
                                              color: Colors.grey.shade600,
                                              fontSize: Dimensions.fontSizeSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : CustomImageWidget(
                                    image: widget.advertisement.coverImageFullUrl ?? '',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                  ),
                ),
              ),
            ),
          ),

          // Order now button directly under the image
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: InkWell(
              onTap: () {
                if (widget.advertisement.restaurantId != null) {
                  widget.onClose();
                  Get.toNamed(
                    RouteHelper.getRestaurantRoute(widget.advertisement.restaurantId!),
                    arguments: RestaurantScreen(
                      restaurant: Restaurant(id: widget.advertisement.restaurantId),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Order now',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

