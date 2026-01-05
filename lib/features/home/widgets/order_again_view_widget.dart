import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';

class OrderAgainViewWidget extends StatelessWidget {
  const OrderAgainViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponController>(builder: (couponCtrlOuter) {
      if(couponCtrlOuter.couponList == null) {
        couponCtrlOuter.ensureCouponListLoaded();
      }
    return GetBuilder<RestaurantController>(builder: (restController) {
      return (restController.orderAgainRestaurantList != null && restController.orderAgainRestaurantList!.isNotEmpty) ? Padding(
          padding: EdgeInsets.only(top: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault, bottom: 4),
        child: SizedBox(
          width: Dimensions.webMaxWidth,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ResponsiveHelper.isDesktop(context) ? Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Order Again 🎯',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                  ),
                  ArrowIconButtonWidget(onTap: () {
                    Get.toNamed(RouteHelper.getAllRestaurantRoute('order_again'));
                  }),
                ]),
              ) : Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Order Again 🎯',
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                  ),
                  ArrowIconButtonWidget(onTap: () {
                    Get.toNamed(RouteHelper.getAllRestaurantRoute('order_again'));
                  }),
              ]),
            ),
              restController.orderAgainRestaurantList != null ? SizedBox(
                height: ResponsiveHelper.isMobile(context) ? 115 : 125,
              child: ListView.builder(
                itemCount: restController.orderAgainRestaurantList!.length,
                padding: EdgeInsets.only(right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                    // Check business shutdown status
                    bool isBusinessShutdown = Get.find<SplashController>().configModel?.businessShutdown ?? false;
                    // Check restaurant availability (open status, active status, and business shutdown)
                    bool isAvailable = !isBusinessShutdown && restController.orderAgainRestaurantList![index].open == 1 && restController.orderAgainRestaurantList![index].active!;
                  return Padding(
                    padding: EdgeInsets.only(left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : Dimensions.paddingSizeDefault),
                      child: Container(
                        height: ResponsiveHelper.isMobile(context) ? 115 : 125,
                        width: ResponsiveHelper.isMobile(context) ? 300 : 340,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200.withOpacity(0.5), width: 0.5),
                        ),
                        child: CustomInkWellWidget(
                          onTap: () => Get.toNamed(RouteHelper.getRestaurantRoute(restController.orderAgainRestaurantList![index].id),
                            arguments: RestaurantScreen(restaurant: restController.orderAgainRestaurantList![index]),
                          ),
                          radius: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                // Small Logo Image
                                Stack(
                                  children: [
                                    Container(
                                      width: ResponsiveHelper.isMobile(context) ? 75 : 85,
                                      height: ResponsiveHelper.isMobile(context) ? 75 : 85,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey.shade200.withOpacity(0.3), width: 0.5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CustomImageWidget(
                                          image: '${restController.orderAgainRestaurantList![index].logoFullUrl}',
                                          fit: BoxFit.cover,
                                          isRestaurant: true,  
                                        ),
                                      ),
                                    ),
                                    // Subtle "Order Again" indicator dot
                                    Positioned(
                                      top: 4, right: 4,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade400,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                      ),
                                    ),
                                    // Closed overlay
                                    if (!isAvailable)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.black.withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                
                                // Restaurant Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Restaurant Name with Favorite
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              restController.orderAgainRestaurantList![index].name!,
                                              style: robotoMedium.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade900,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          GetBuilder<FavouriteController>(builder: (favouriteController) {
                                            bool isWished = favouriteController.wishRestIdList.contains(restController.orderAgainRestaurantList![index].id);
                                            return InkWell(
                                              onTap: () {
                                                if(isWished) {
                                                  favouriteController.removeFromFavouriteList(restController.orderAgainRestaurantList![index].id, true);
                                                } else {
                                                  favouriteController.addToFavouriteList(null, restController.orderAgainRestaurantList![index].id, true);
                                                }
                                              },
                                              child: Icon(
                                                isWished ? Icons.favorite : Icons.favorite_border,
                                                size: 16,
                                                color: isWished ? Colors.orange.shade400 : Colors.grey.shade400,
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // First Info Row - Rating & Time
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                                          const SizedBox(width: 3),
                                          Text(
                                            restController.orderAgainRestaurantList![index].avgRating!.toStringAsFixed(1),
                                            style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade700),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${restController.orderAgainRestaurantList![index].deliveryTime}',
                                            style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                          const Spacer(),
                                          if (!isAvailable)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'closed_now'.tr,
                                                style: robotoRegular.copyWith(fontSize: 9, color: Colors.red.shade600),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Second Info Row - Items & Free Delivery
                                      Row(
                                        children: [
                                          if (restController.orderAgainRestaurantList![index].foodsCount != null && restController.orderAgainRestaurantList![index].foodsCount! > 0)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.restaurant_menu, size: 11, color: Colors.grey.shade500),
                                                const SizedBox(width: 3),
                                                Text(
                                                  '${restController.orderAgainRestaurantList![index].foodsCount}+ items',
                                                  style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(width: 12),
                                          Builder(builder: (_) {
                                            final Restaurant rest = restController.orderAgainRestaurantList![index];
                                            final config = Get.find<SplashController>().configModel;
                                            final address = AddressHelper.getAddressFromSharedPref();

                                            ZoneData? zoneData;
                                            try {
                                              if (address?.zoneData != null && rest.zoneId != null) {
                                                zoneData = address!.zoneData!.firstWhere((z) => z.id == rest.zoneId);
                                              }
                                            } catch (_) {}

                                            bool hasFreeDelivery = false;
                                            String deliveryText = '';
                                            if (rest.selfDeliverySystem == 1 && rest.freeDeliveryDistanceStatus == true && rest.freeDeliveryDistanceValue != null) {
                                              hasFreeDelivery = true;
                                              deliveryText = 'Free ${rest.freeDeliveryDistanceValue!.toStringAsFixed(0)} km';
                                            } else if (rest.selfDeliverySystem == 0 && (config?.freeDeliveryDistance != null)) {
                                              hasFreeDelivery = true;
                                              deliveryText = 'Free ${config!.freeDeliveryDistance!.toStringAsFixed(0)} km';
                                            } else if (rest.freeDelivery == true) {
                                              hasFreeDelivery = true;
                                              deliveryText = 'Free delivery';
                                            }

                                            return hasFreeDelivery ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.local_shipping, size: 11, color: Colors.grey.shade500),
                                                const SizedBox(width: 3),
                                                Text(
                                                  deliveryText,
                                                  style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ) : const SizedBox();
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ),
                  );
                },
              ),
              ) : const OrderAgainShimmer()
          ]),
        ),
      ) : const SizedBox();
    });
    });
  }
}

class OrderAgainShimmer extends StatelessWidget {
  const OrderAgainShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isMobile(context) ? 115 : 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0, right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSizeDefault),
            height: ResponsiveHelper.isMobile(context) ? 115 : 125,
            width: ResponsiveHelper.isMobile(context) ? 300 : 340,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200.withOpacity(0.5), width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Logo shimmer
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Shimmer(
                      child: Container(
                        width: ResponsiveHelper.isMobile(context) ? 70 : 80,
                        height: ResponsiveHelper.isMobile(context) ? 70 : 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Name shimmer
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Shimmer(
                            child: Container(
                              height: 14,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Info row shimmer
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Shimmer(
                                child: Container(
                                  height: 11,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Shimmer(
                                child: Container(
                                  height: 11,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}