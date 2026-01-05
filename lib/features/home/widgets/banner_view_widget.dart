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

class BannerViewWidget extends StatelessWidget {
  const BannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<HomeController>(builder: (homeController) {
      // Debug logging
      debugPrint('=== MIDDLE BANNER DEBUG ===');
      debugPrint('middleBannerImageList is null: ${homeController.middleBannerImageList == null}');
      debugPrint('middleBannerImageList length: ${homeController.middleBannerImageList?.length ?? 'null'}');
      debugPrint('middleBannerImageList: ${homeController.middleBannerImageList}');
      debugPrint('middleBannerDataList: ${homeController.middleBannerDataList?.length ?? 'null'}');
      debugPrint('currentIndex: ${homeController.currentIndex}');
      
      // Show shimmer while loading, hide only if explicitly empty after load
      if (homeController.middleBannerImageList == null) {
        debugPrint('MIDDLE BANNER: Showing shimmer (loading state)');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Shimmer(
              child: Container(
                height: GetPlatform.isDesktop ? 500 : 205,
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
      if (homeController.middleBannerImageList!.isEmpty) {
        debugPrint('MIDDLE BANNER: Hiding (empty list)');
        return const SizedBox();
      }
      
      debugPrint('MIDDLE BANNER: Showing carousel with ${homeController.middleBannerImageList!.length} banners');
      
      return Container(
        width: MediaQuery.of(context).size.width,
        height: GetPlatform.isDesktop ? 500 : 205,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
        child: homeController.middleBannerImageList != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                aspectRatio: 2.5,
                enlargeFactor: 0.3,
                autoPlay: true,
                enlargeCenterPage: true,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  homeController.setCurrentIndex(index, true);
                },
              ),
              itemCount: homeController.middleBannerImageList!.isEmpty ? 1 : homeController.middleBannerImageList!.length,
              itemBuilder: (context, index, _) {
                return InkWell(
                  onTap: () {
                    if(homeController.middleBannerDataList![index] is Product) {
                      Product? product = homeController.middleBannerDataList![index];
                      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
                        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                        builder: (con) => ProductBottomSheetWidget(product: product),
                      ) : showDialog(context: context, builder: (con) => Dialog(
                          child: ProductBottomSheetWidget(product: product)),
                      );
                    }else if(homeController.middleBannerDataList![index] is Restaurant) {
                      Restaurant restaurant = homeController.middleBannerDataList![index];
                      Get.toNamed(
                        RouteHelper.getRestaurantRoute(restaurant.id),
                        arguments: RestaurantScreen(restaurant: restaurant),
                      );
                    }else if(homeController.middleBannerDataList![index] is BasicCampaignModel) {
                      BasicCampaignModel campaign = homeController.middleBannerDataList![index];
                      Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: GetBuilder<SplashController>(builder: (splashController) {
                        return CustomImageWidget(
                          image: '${homeController.middleBannerImageList![index]}',
                          fit: BoxFit.cover,
                        );
                      },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: homeController.middleBannerImageList!.map((bnr) {
                int index = homeController.middleBannerImageList!.indexOf(bnr);
                int totalBanner = homeController.middleBannerImageList!.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: index == homeController.currentIndex ? Container(
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Text('${(index) + 1}/$totalBanner', style: robotoRegular.copyWith(color: Colors.white, fontSize: 12)),
                  ) : Container(
                    height: 4.18, width: 5.57,
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  ),
                );
              }).toList(),
            ),
          ],
        ) : Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: Shimmer(
              child: Container(decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).shadowColor,
              )),
            ),
          ),
        ),
      );
    });
  }

}
