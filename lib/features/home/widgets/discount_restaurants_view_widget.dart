import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountRestaurantsViewWidget extends StatelessWidget {
  const DiscountRestaurantsViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restController) {
      List<Restaurant>? restaurantList = restController.discountedRestaurantList;
      return (restaurantList != null && restaurantList.isEmpty) ? const SizedBox() : Padding(
        padding: EdgeInsets.only(top: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault, bottom: 4),
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Discounts 🏷️',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                ),
                ArrowIconButtonWidget(onTap: () {
                  Get.toNamed(RouteHelper.getAllRestaurantRoute('discounted'));
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
                  final r = restaurantList[index];
                  bool isAvailable = r.open == 1 && r.active!;
                  return Padding(
                    padding: EdgeInsets.only(left: (ResponsiveHelper.isDesktop(context) && index == 0 && Get.find<LocalizationController>().isLtr) ? 0 : Dimensions.paddingSizeDefault),
                    child: Container(
                      height: ResponsiveHelper.isMobile(context) ? 160 : 180,
                      width: ResponsiveHelper.isMobile(context) ? 210 : 400,
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
                        onTap: () => Get.toNamed(RouteHelper.getRestaurantRoute(r.id),
                          arguments: RestaurantScreen(restaurant: r),
                        ),
                        radius: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Fixed image height to minimize bottom whitespace
                            SizedBox(
                              height: ResponsiveHelper.isMobile(context) ? 110 : 125,
                              child: Stack(children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                    child: CustomImageWidget(image: '${r.coverPhotoFullUrl}', fit: BoxFit.cover, isRestaurant: true),
                                  ),
                                ),
                                if (r.discount != null && r.discount!.discount != null)
                                  Positioned(
                                    bottom: 8, right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.redAccent.shade400, borderRadius: BorderRadius.circular(8), boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 1))
                                      ]),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        const Icon(Icons.local_offer, size: 10, color: Colors.white),
                                        const SizedBox(width: 2),
                                        Text('${r.discount!.discountType?.toLowerCase() == 'percent' ? r.discount!.discount!.toStringAsFixed(0)+'%' : ''} ${'OFF'}', style: robotoBold.copyWith(fontSize: 8, color: Colors.white)),
                                      ]),
                                    ),
                                  ),
                                Positioned(
                                  top: 8, right: 8,
                                  child: GetBuilder<FavouriteController>(builder: (fav) {
                                    bool isWished = fav.wishRestIdList.contains(r.id);
                                    return Container(
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(8), boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1)),
                                      ]),
                                      child: InkWell(
                                        onTap: () => isWished ? fav.removeFromFavouriteList(r.id, true) : fav.addToFavouriteList(null, r.id, true),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(padding: const EdgeInsets.all(6), child: Icon(isWished ? Icons.favorite : Icons.favorite_border, size: 16, color: isWished ? Colors.orange : Colors.grey.shade600)),
                                      ),
                                    );
                                  }),
                                ),
                                if (!isAvailable)
                                  Positioned.fill(child: Container(
                                    decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)), color: Colors.black.withOpacity(0.35)),
                                  )),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(r.name!, style: robotoMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Icon(Icons.delivery_dining, size: 10, color: Colors.grey.shade600),
                                    const SizedBox(width: 3),
                                    Text('${r.deliveryTime}', style: robotoRegular.copyWith(fontSize: 9, color: Colors.grey.shade700)),
                                    const SizedBox(width: 8),
                                    Icon(Icons.star, size: 10, color: Colors.amber.shade600),
                                    const SizedBox(width: 2),
                                    Text(r.avgRating!.toStringAsFixed(1), style: robotoRegular.copyWith(fontSize: 9, color: Colors.grey.shade700)),
                                  ]),
                                ]),
                            ),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ) : const SizedBox()
          ]),
        ),
      );
    });
  }
}


