import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/product/domain/models/basic_campaign_model.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class TopBannerViewWidget extends StatelessWidget {
  const TopBannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      // Debug logging
      debugPrint('=== TOP BANNER DEBUG ===');
      debugPrint('topBannerImageList is null: ${homeController.topBannerImageList == null}');
      debugPrint('topBannerImageList length: ${homeController.topBannerImageList?.length ?? 'null'}');
      debugPrint('topBannerImageList: ${homeController.topBannerImageList}');
      debugPrint('topBannerDataList: ${homeController.topBannerDataList?.length ?? 'null'}');
      
      // Show shimmer while loading, hide only if explicitly empty after load
      if (homeController.topBannerImageList == null) {
        debugPrint('TOP BANNER: Showing shimmer (loading state)');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Shimmer(
              child: Container(
                height: ResponsiveHelper.isMobile(context) ? 120 : 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).shadowColor,
                ),
              ),
            ),
          ),
        );
      }
      
      // Hide only if explicitly empty
      if (homeController.topBannerImageList!.isEmpty) {
        debugPrint('TOP BANNER: Hiding (empty list)');
        return const SizedBox();
      }
      
      debugPrint('TOP BANNER: Showing carousel with ${homeController.topBannerImageList!.length} banners');
      
      return Container(
        width: MediaQuery.of(context).size.width,
        height: ResponsiveHelper.isMobile(context) ? 70 : 160,
        margin: EdgeInsets.only(bottom: ResponsiveHelper.isMobile(context) ? 12 : 16),
        child: homeController.topBannerImageList != null ? CarouselSlider.builder(
          options: CarouselOptions(
            height: ResponsiveHelper.isMobile(context) ? 120 : 160,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              // Use a different index tracking for top banner if needed
              // For now, we can use the same controller
            },
          ),
          itemCount: homeController.topBannerImageList!.isEmpty ? 1 : homeController.topBannerImageList!.length,
          itemBuilder: (context, index, _) {
            return InkWell(
              onTap: () {
                if(homeController.topBannerDataList![index] is Product) {
                  Product? product = homeController.topBannerDataList![index];
                  ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (con) => ProductBottomSheetWidget(product: product),
                  ) : showDialog(context: context, builder: (con) => Dialog(
                      child: ProductBottomSheetWidget(product: product)),
                  );
                }else if(homeController.topBannerDataList![index] is Restaurant) {
                  Restaurant restaurant = homeController.topBannerDataList![index];
                  Get.toNamed(
                    RouteHelper.getRestaurantRoute(restaurant.id),
                    arguments: RestaurantScreen(restaurant: restaurant),
                  );
                }else if(homeController.topBannerDataList![index] is BasicCampaignModel) {
                  BasicCampaignModel campaign = homeController.topBannerDataList![index];
                  Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: SizedBox(
                    width: double.infinity,
                    height: ResponsiveHelper.isMobile(context) ? 120 : 160,
                    child: CustomImageWidget(
                      image: '${homeController.topBannerImageList![index]}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        ) : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Shimmer(
              child: Container(
                height: ResponsiveHelper.isMobile(context) ? 120 : 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  color: Theme.of(context).shadowColor,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
