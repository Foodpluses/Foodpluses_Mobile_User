import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/icon_with_text_row_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';

class PopularRestaurantsViewWidget extends StatefulWidget {
  final bool isRecentlyViewed;
  const PopularRestaurantsViewWidget({super.key, this.isRecentlyViewed = false});

  @override
  State<PopularRestaurantsViewWidget> createState() => _PopularRestaurantsViewWidgetState();
}

class _PopularRestaurantsViewWidgetState extends State<PopularRestaurantsViewWidget> {
  @override
  void initState() {
    super.initState();
    // Load coupon list once when widget is created, not in build method
    final couponController = Get.find<CouponController>();
    if(couponController.couponList == null) {
      couponController.ensureCouponListLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponController>(builder: (couponCtrlOuter) {
      return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = widget.isRecentlyViewed ? restController.recentlyViewedRestaurantList : restController.popularRestaurantList;
      return (restaurantList != null && restaurantList.isEmpty) ? const SizedBox() : Padding(
        padding: EdgeInsets.only(top: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault, bottom: 4),
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ResponsiveHelper.isDesktop(context) ? Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(widget.isRecentlyViewed ? 'recently_viewed_restaurants'.tr : 'Trending Now 🔥',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                ),
                ArrowIconButtonWidget(onTap: () {
                  Get.toNamed(RouteHelper.getAllRestaurantRoute(widget.isRecentlyViewed ? 'recently_viewed' : 'popular'));
                }),
              ]),
            ) : Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(widget.isRecentlyViewed ? 'recently_viewed_restaurants'.tr : 'Trending Now 🔥',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                ),
                ArrowIconButtonWidget(onTap: () {
                  Get.toNamed(RouteHelper.getAllRestaurantRoute(widget.isRecentlyViewed ? 'recently_viewed' : 'popular'));
                }),
              ]),
            ),
          restaurantList != null ? SizedBox(
              height: ResponsiveHelper.isMobile(context) ? 160 : 180,
              child: ListView.builder(
                itemCount: restaurantList.length,
                padding: EdgeInsets.only(right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  // Check business shutdown status
                  bool isBusinessShutdown = Get.find<SplashController>().configModel?.businessShutdown ?? false;
                  // Check restaurant availability (open status, active status, and business shutdown)
                  bool isAvailable = !isBusinessShutdown && restaurantList[index].open == 1 && restaurantList[index].active!;
                  String characteristics = '';
                  if(restaurantList[index].characteristics != null) {
                    for (var v in restaurantList[index].characteristics!) {
                      characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : Dimensions.paddingSizeDefault),
                    child: Container(
                      height: ResponsiveHelper.isMobile(context) ? 160 : 180,
                      width: ResponsiveHelper.isMobile(context) ? 230 : 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: CustomInkWellWidget(
                        onTap: () => Get.toNamed(RouteHelper.getRestaurantRoute(restaurantList[index].id),
                          arguments: RestaurantScreen(restaurant: restaurantList[index]),
                        ),
                        radius: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section - With discount/free delivery tags
                            // Fixed image height to minimize bottom whitespace
                            Container(
                              height: ResponsiveHelper.isMobile(context) ? 110 : 125,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Stack(
                                  children: [
                                    // Food Image
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: CustomImageWidget(
                                          image: '${restaurantList[index].coverPhotoFullUrl}',
                                          fit: BoxFit.cover,
                                          isRestaurant: true,
                                        ),
                                      ),
                                    ),
                                    
                                    // Dynamic Discount Badge from admin or first-order fallback
                                    GetBuilder<CouponController>(builder: (couponCtrl) {
                                      final discount = restaurantList[index].discount;
                                      if (discount == null || (discount.discount == null)) {
                                        // Fallback: show first-order coupon badge when applicable
                                        final profile = Get.find<ProfileController>().userInfoModel;
                                        final isFirstOrder = (profile?.orderCount ?? 0) == 0;
                                        if(couponCtrl.couponList == null) {
                                          // Don't call ensureCouponListLoaded here - it's already called in initState
                                          // This prevents infinite rebuild loops
                                          return const SizedBox();
                                        }
                                        final firstOrderCoupon = couponCtrl.firstOrderCoupon;
                                        if(isFirstOrder && firstOrderCoupon != null) {
                                          // Check if it's free delivery or discount
                                          final isFreeDelivery = couponCtrl.hasFirstOrderFreeDelivery;
                                          String badgeText;
                                          if (isFreeDelivery) {
                                            badgeText = 'Free delivery on your first order';
                                          } else {
                                            // It's a discount coupon - show the discount value
                                            final discountType = (firstOrderCoupon.discountType ?? '').toLowerCase();
                                            if (discountType == 'percent') {
                                              badgeText = '${firstOrderCoupon.discount?.toStringAsFixed(0) ?? '0'}% off your first order';
                                            } else {
                                              // Amount discount
                                              badgeText = '${PriceConverter.convertPrice(firstOrderCoupon.discount ?? 0)} off your first order';
                                            }
                                          }
                                          
                                          return Positioned(
                                            bottom: 8, right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade600,
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1)),
                                                ],
                                              ),
                                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                const Icon(Icons.card_giftcard, size: 10, color: Colors.white),
                                                const SizedBox(width: 2),
                                                Text(badgeText, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w600)),
                                              ]),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      }

                                      bool isActive = true;
                                      try {
                                        if (discount.startDate != null && discount.endDate != null) {
                                          DateTime start = DateTime.parse('${discount.startDate!} ${discount.startTime ?? '00:00'}');
                                          DateTime end = DateTime.parse('${discount.endDate!} ${discount.endTime ?? '23:59'}');
                                          DateTime now = DateTime.now();
                                          isActive = now.isAfter(start) && now.isBefore(end);
                                        }
                                      } catch (_) {}

                                      if (!isActive) {
                                        final profile = Get.find<ProfileController>().userInfoModel;
                                        final isFirstOrder = (profile?.orderCount ?? 0) == 0;
                                        final couponCtrl = Get.find<CouponController>();
                                        final firstOrderCoupon = couponCtrl.firstOrderCoupon;
                                        if(isFirstOrder && firstOrderCoupon != null) {
                                          // Check if it's free delivery or discount
                                          final isFreeDelivery = couponCtrl.hasFirstOrderFreeDelivery;
                                          String badgeText;
                                          if (isFreeDelivery) {
                                            badgeText = 'Free delivery on your first order';
                                          } else {
                                            // It's a discount coupon - show the discount value
                                            final discountType = (firstOrderCoupon.discountType ?? '').toLowerCase();
                                            if (discountType == 'percent') {
                                              badgeText = '${firstOrderCoupon.discount?.toStringAsFixed(0) ?? '0'}% off your first order';
                                            } else {
                                              // Amount discount
                                              badgeText = '${PriceConverter.convertPrice(firstOrderCoupon.discount ?? 0)} off your first order';
                                            }
                                          }
                                          
                                          return Positioned(
                                            bottom: 8, right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade600,
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1)),
                                                ],
                                              ),
                                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                const Icon(Icons.card_giftcard, size: 10, color: Colors.white),
                                                const SizedBox(width: 2),
                                                Text(badgeText, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w600)),
                                              ]),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      }

                                      String label;
                                      final bool isPercent = (discount.discountType ?? '').toLowerCase() == 'percent';
                                      if (isPercent) {
                                        label = 'Save up to ${discount.discount!.toStringAsFixed(0)}% off';
                                      } else {
                                        label = 'Save up to ${PriceConverter.convertPrice(discount.discount!)} off';
                                      }

                                      return Positioned(
                                        bottom: 8, right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade600,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1)),
                                            ],
                                          ),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            const Icon(Icons.local_offer, size: 10, color: Colors.white),
                                            const SizedBox(width: 2),
                                            Text(label, style: robotoBold.copyWith(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w600)),
                                          ]),
                                        ),
                                      );
                                    }),
                                    
                                    // Favorite Button (Top Right) - Smaller
                                    Positioned(
                                      top: 8, right: 8,
                                      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                                        bool isWished = favouriteController.wishRestIdList.contains(restaurantList[index].id);
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.95),
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if(isWished) {
                                                favouriteController.removeFromFavouriteList(restaurantList[index].id, true);
                                              } else {
                                                favouriteController.addToFavouriteList(null, restaurantList[index].id, true);
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Icon(
                                                isWished ? Icons.favorite : Icons.favorite_border,
                                                size: 16,
                                                color: isWished ? Colors.orange : Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                    
                                    // Closed Now Overlay
                                    if (!isAvailable)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                            color: Colors.black.withOpacity(0.35),
                                          ),
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.access_time, size: 14, color: Colors.white),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'closed_now'.tr,
                                                    style: robotoMedium.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            // Restaurant Information Section - compact
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    // Restaurant Name
                                    Text(
                                      restaurantList[index].name!,
                                      style: robotoMedium.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    
                                    const SizedBox(height: 4),
                                    
                                    // Info Row - Clean with delivery info
                                    Row(
                                      children: [
                                        // Delivery Time - Simple text
                                        Icon(Icons.delivery_dining, size: 10, color: Colors.grey.shade600),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${restaurantList[index].deliveryTime}',
                                          style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade700),
                                        ),
                                        
                                        const SizedBox(width: 8),
                                        
                                        // Rating - Simple text
                                        Icon(Icons.star, size: 10, color: Colors.amber.shade600),
                                        const SizedBox(width: 2),
                                        Text(
                                          restaurantList[index].avgRating!.toStringAsFixed(1),
                                          style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade700),
                                        ),
                                        
                                        const Spacer(),
                                        
                                        // Free Delivery Info - Clean text
                                        Builder(builder: (_) {
                                          final Restaurant rest = restaurantList[index];
                                          final config = Get.find<SplashController>().configModel;
                                          final address = AddressHelper.getAddressFromSharedPref();

                                          ZoneData? zoneData;
                                          try {
                                            if (address?.zoneData != null && rest.zoneId != null) {
                                              zoneData = address!.zoneData!.firstWhere((z) => z.id == rest.zoneId);
                                            }
                                          } catch (_) {}

                                          String badgeText = '';
                                          if (rest.selfDeliverySystem == 1 && rest.freeDeliveryDistanceStatus == true && rest.freeDeliveryDistanceValue != null) {
                                            badgeText = 'Free ${rest.freeDeliveryDistanceValue!.toStringAsFixed(0)} km';
                                          } else if (rest.selfDeliverySystem == 0 && (config?.freeDeliveryDistance != null)) {
                                            badgeText = 'Free ${config!.freeDeliveryDistance!.toStringAsFixed(0)} km';
                                          } else if (rest.freeDelivery == true) {
                                            badgeText = 'Free';
                                          } else {
                                            final double perKm = rest.selfDeliverySystem == 1
                                                ? (rest.perKmShippingCharge ?? 0)
                                                : (zoneData?.perKmShippingCharge ?? 0);
                                            if (perKm > 0) {
                                              badgeText = '${PriceConverter.convertPrice(perKm)}/km';
                                            }
                                          }

                                          return badgeText.isNotEmpty ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.local_shipping, size: 9, color: Colors.grey.shade600),
                                              const SizedBox(width: 2),
                                              Text(badgeText, style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade700)),
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
                  );
                },
              ),
            )  : const PopularRestaurantShimmer()
          ]),
        ),
      );
    });
    });
  }
}

class PopularRestaurantShimmer extends StatelessWidget {
  const PopularRestaurantShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isMobile(context) ? 180 : 200, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0, right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSizeDefault),
            height: ResponsiveHelper.isMobile(context) ? 170 : 190,
            width: ResponsiveHelper.isMobile(context) ? 160 : 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).shadowColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image shimmer
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      child: Shimmer(
                        child: Container(
                          width: double.infinity,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Content shimmer
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Restaurant name shimmer
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: Shimmer(
                            child: Container(
                              height: 12,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                        ),
                        
                        // Info row shimmer
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 9,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).shadowColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 9,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).shadowColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

