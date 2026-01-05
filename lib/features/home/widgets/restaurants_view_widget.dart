import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RestaurantsViewWidget extends StatelessWidget {
  final List<Restaurant?>? restaurants;
  const RestaurantsViewWidget({super.key, this.restaurants});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: restaurants != null ? restaurants!.isNotEmpty ? GridView.builder(
        shrinkWrap: true,
        itemCount: restaurants!.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : ResponsiveHelper.isTab(context) ? 3 : 4,
          mainAxisSpacing: Dimensions.paddingSizeLarge,
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisExtent: 140,
        ),
        padding: EdgeInsets.symmetric(horizontal: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : 0),
        itemBuilder: (context, index) {
          return RestaurantView(restaurant: restaurants![index]!);
        },
      ) : Center(child: Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeOverLarge),
        child: Column(
          children: [
            const SizedBox(height: 110),
            const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text('there_is_no_restaurant'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
          ],
        ),
      )) : GridView.builder(
        shrinkWrap: true,
        itemCount: 12,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : ResponsiveHelper.isTab(context) ? 3 : 4,
          mainAxisSpacing: Dimensions.paddingSizeLarge,
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisExtent: 140,
        ),
        padding: EdgeInsets.symmetric(horizontal: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
        itemBuilder: (context, index) {
          return const WebRestaurantShimmer();
        },
      ),

    );
  }
}

class RestaurantView extends StatelessWidget {
  final Restaurant restaurant;
  final Function()? onTap;
  final bool isSelected;
  const RestaurantView({super.key, required this.restaurant, this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    // Check business shutdown status
    bool isBusinessShutdown = Get.find<SplashController>().configModel?.businessShutdown ?? false;
    // Check restaurant availability (open status, active status, and business shutdown)
    bool isAvailable = !isBusinessShutdown && restaurant.open == 1 && restaurant.active!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Get.isDarkMode? Colors.black.withValues(alpha: 0.15) : Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: CustomInkWellWidget(
        onTap: onTap ?? () {
          if(restaurant.restaurantStatus == 1){
            Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id), arguments: RestaurantScreen(restaurant: restaurant));
          }else {
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        radius: Dimensions.radiusDefault,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(children: [
                CustomImageWidget(image: '${restaurant.coverPhotoFullUrl}', fit: BoxFit.cover, height: 108, width: 108, isRestaurant: true),
                if(!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'closed_now'.tr,
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(width: 10),
            // Content
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(restaurant.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold.copyWith(fontSize: 14))),
                GetBuilder<FavouriteController>(builder: (favouriteController) {
                  bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                  return Icon(isWished ? Icons.favorite : Icons.favorite_border, size: 18, color: isWished ? Colors.orange : Colors.grey.shade500);
                }),
              ]),
              const SizedBox(height: 6),
              Text(restaurant.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey.shade600)),
              const Spacer(),
              Wrap(spacing: 6, runSpacing: -6, children: [
                if(restaurant.ratingCount! > 0) _Pill(icon: Icons.star, label: restaurant.avgRating!.toStringAsFixed(1)),
                _Pill(icon: Icons.access_time_outlined, label: '${restaurant.deliveryTime}'),
                if(restaurant.freeDelivery == true) _Pill(icon: Icons.local_shipping, label: 'free'.tr),
                _Pill(icon: Icons.place, label: '${Get.find<RestaurantController>().getRestaurantDistance(LatLng(double.parse(restaurant.latitude!), double.parse(restaurant.longitude!))).toStringAsFixed(1)} km'),
              ]),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon; final String label;
  const _Pill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: Colors.grey.shade700),
        const SizedBox(width: 3),
        Text(label, style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade700)),
      ]),
    );
  }
}

class WebRestaurantShimmer extends StatelessWidget {
  final bool isDineInRestaurant;
  const WebRestaurantShimmer({super.key, this.isDineInRestaurant = false});

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).shadowColor,
        border: Border.all(color: Theme.of(context).shadowColor),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Stack(clipBehavior: Clip.none, children: [

            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
              child: Shimmer(
                child: Container(
                  height: 93, width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 60, left: 10, right: isDineInRestaurant ? null : 0,
              child: Column(
                crossAxisAlignment: isDineInRestaurant ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    height: 70, width: 70,
                    decoration:  BoxDecoration(
                      color: Theme.of(context).shadowColor,
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Shimmer(
                      child: Container(height: 15, width: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Shimmer(
                      child: Container(height: 10, width: 220, decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconWithTextRowWidget(
                        icon: Icons.star_border, text: '0.0',
                        color: Theme.of(context).shadowColor,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).shadowColor),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                        child: ImageWithTextRowWidget(
                          widget: Image.asset(Images.deliveryIcon, height: 20, width: 20, color: Theme.of(context).shadowColor),
                          text: 'free'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).shadowColor),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      IconWithTextRowWidget(
                        icon: Icons.access_time_outlined, text: '10-30 min',
                        color: Theme.of(context).shadowColor,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).shadowColor),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
              child: Icon(
                Icons.favorite,  size: 20,
                color: Theme.of(context).shadowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}