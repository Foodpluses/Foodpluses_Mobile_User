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

class PopularRestaurantsViewWidget extends StatelessWidget {
  final bool isRecentlyViewed;
  const PopularRestaurantsViewWidget({super.key, this.isRecentlyViewed = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = isRecentlyViewed ? restController.recentlyViewedRestaurantList : restController.popularRestaurantList;
      return (restaurantList != null && restaurantList.isEmpty) ? const SizedBox() : Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
        child: SizedBox(
          height: 300, width: Dimensions.webMaxWidth,

          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ResponsiveHelper.isDesktop(context) ? Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(isRecentlyViewed ? 'recently_viewed_restaurants'.tr : 'Trending Now 🔥',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                ),
                ArrowIconButtonWidget(onTap: () {
                  Get.toNamed(RouteHelper.getAllRestaurantRoute(isRecentlyViewed ? 'recently_viewed' : 'popular'));
                }),
              ]),
            ) : Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeLarge),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(isRecentlyViewed ? 'recently_viewed_restaurants'.tr : 'Trending Now 🔥',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                ),
                ArrowIconButtonWidget(onTap: () {
                  Get.toNamed(RouteHelper.getAllRestaurantRoute(isRecentlyViewed ? 'recently_viewed' : 'popular'));
                }),
              ]),
            ),
          restaurantList != null ? SizedBox(
              height: 240,
              child: ListView.builder(
                itemCount: restaurantList.length,
                padding: EdgeInsets.only(right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isAvailable = restaurantList[index].open == 1 && restaurantList[index].active!;
                  String characteristics = '';
                  if(restaurantList[index].characteristics != null) {
                    for (var v in restaurantList[index].characteristics!) {
                      characteristics = '$characteristics${characteristics.isNotEmpty ? ', ' : ''}$v';
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : Dimensions.paddingSizeDefault),
                    child: Container(
                      height: 250, width: ResponsiveHelper.isDesktop(context) ? 320 : MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: CustomInkWellWidget(
                        onTap: () => Get.toNamed(RouteHelper.getRestaurantRoute(restaurantList[index].id),
                          arguments: RestaurantScreen(restaurant: restaurantList[index]),
                        ),
                        radius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hero Image Section (Top Half)
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  // Food Image
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CustomImageWidget(
                                        image: '${restaurantList[index].coverPhotoFullUrl}',
                                        fit: BoxFit.cover,
                                        isRestaurant: true,
                                      ),
                                    ),
                                  ),
                                  
                                  // Discount Badge (20% OFF)
                                  Positioned(
                                    bottom: 12, right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.15),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.local_offer,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '20% OFF First Order',
                                            style: robotoBold.copyWith(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Favorite Button (Top Right)
                                  Positioned(
                                    top: 12, right: 12,
                                    child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                                      bool isWished = favouriteController.wishRestIdList.contains(restaurantList[index].id);
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
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
                                          borderRadius: BorderRadius.circular(10),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              isWished ? Icons.favorite : Icons.favorite_border,
                                              size: 18,
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
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          color: Colors.black.withOpacity(0.4),
                                        ),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.access_time, size: 16, color: Colors.white),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'closed_now'.tr,
                                                  style: robotoMedium.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 12,
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
                            
                            // Restaurant Information Section (Bottom Half)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Restaurant Name and Address
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurantList[index].name!,
                                          style: robotoBold.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // const SizedBox(height: 2),
                                        // Text(
                                        //   characteristics.isNotEmpty ? characteristics : 'Restaurant',
                                        //   style: robotoRegular.copyWith(
                                        //     fontSize: 10,
                                        //     color: Colors.grey.shade600,
                                        //   ),
                                        //   maxLines: 1,
                                        //   overflow: TextOverflow.ellipsis,
                                        // ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 10),
                                    
                                    // Price and Delivery Time Row
                                    Row(
                                      children: [
                                        // Price Range
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Icon(
                                              //   Icons.attach_money,
                                              //   size: 10,
                                              //   color: Colors.orange.shade600,
                                              // ),
                                              Text(
                                                'From -',
                                                style: robotoMedium.copyWith(
                                                  fontSize: 9,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '₦${restaurantList[index].minimumOrder?.toStringAsFixed(0) ?? '550'}',
                                                style: robotoMedium.copyWith(
                                                  fontSize: 9,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        const SizedBox(width: 6),
                                        
                                        // Delivery Time
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.delivery_dining,
                                                size: 10,
                                                color: Colors.green.shade600,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${restaurantList[index].deliveryTime}',
                                                style: robotoMedium.copyWith(
                                                  fontSize: 9,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        const Spacer(),
                                        
                                        // Cool Feature: Free Delivery Badge or Rating
                                        // if(restaurantList[index].freeDelivery!)
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.purple.shade50,
                                        //       borderRadius: BorderRadius.circular(6),
                                        //     ),
                                        //     child: Row(
                                        //       mainAxisSize: MainAxisSize.min,
                                        //       children: [
                                        //         Icon(
                                        //           Icons.local_shipping,
                                        //           size: 10,
                                        //           color: Colors.purple.shade600,
                                        //         ),
                                        //         const SizedBox(width: 2),
                                        //         Text(
                                        //           'FREE',
                                        //           style: robotoBold.copyWith(
                                        //             fontSize: 8,
                                        //             color: Colors.purple.shade700,
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   )
                                        // else if(restaurantList[index].ratingCount! > 0)
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        //     decoration: BoxDecoration(
                                        //       color: Colors.amber.shade50,
                                        //       borderRadius: BorderRadius.circular(6),
                                        //     ),
                                        //     child: Row(
                                        //       mainAxisSize: MainAxisSize.min,
                                        //       children: [
                                        //         Icon(
                                        //           Icons.star,
                                        //           size: 10,
                                        //           color: Colors.amber.shade600,
                                        //         ),
                                        //         const SizedBox(width: 2),
                                        //         Text(
                                        //           '${restaurantList[index].avgRating!.toStringAsFixed(1)}',
                                        //           style: robotoBold.copyWith(
                                        //             fontSize: 9,
                                        //             color: Colors.amber.shade700,
                                        //           ),
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),


                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.local_shipping,
                                                  size: 10,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  'FREE 5km',
                                                  style: robotoBold.copyWith(
                                                    fontSize: 8,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 10,
                                                  color: Colors.amber.shade600,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  restaurantList[index].avgRating!.toStringAsFixed(1),
                                                  style: robotoBold.copyWith(
                                                    fontSize: 9,
                                                    color: Colors.amber.shade700,
                                                  ),
                                                ),
                                              ],
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
  }
}

class PopularRestaurantShimmer extends StatelessWidget {
  const PopularRestaurantShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0, right: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : Dimensions.paddingSizeDefault),
            height: 250, width: ResponsiveHelper.isDesktop(context) ? 320 : MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).shadowColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image shimmer
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    child: Shimmer(
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ),
                ),
                
                // Content shimmer
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant name shimmer
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: Shimmer(
                            child: Container(
                              height: 14,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Info badges shimmer
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 20,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).shadowColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 20,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).shadowColor,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 20,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).shadowColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Shimmer(
                                child: Container(
                                  height: 20,
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

