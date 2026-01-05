import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WhatOnYourMindViewWidget extends StatelessWidget {
  const WhatOnYourMindViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ResponsiveHelper.isDesktop(context) ? Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('what_on_your_mind'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),
            ArrowIconButtonWidget(onTap: () => Get.toNamed(RouteHelper.getCategoryRoute())),
          ]),
        ) : Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('what_on_your_mind'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
            ArrowIconButtonWidget(onTap: () => Get.toNamed(RouteHelper.getCategoryRoute())),
          ]),
        ),

        SizedBox(
          height: ResponsiveHelper.isMobile(context) ? 100 : 140,
          child: categoryController.categoryList != null ? ListView.builder(
            physics: ResponsiveHelper.isMobile(context) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
            itemCount: categoryController.categoryList!.length > 10 ? 10 : categoryController.categoryList!.length,
            itemBuilder: (context, index) {

              if(index == 9) {
                return ResponsiveHelper.isDesktop(context) ? Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault),
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall, top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                        child: Container(
                          height: 40, width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ): const SizedBox();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault),
                child: Container(
                  width: ResponsiveHelper.isMobile(context) ? 65 : 90,
                  height: ResponsiveHelper.isMobile(context) ? 85 : 120,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: CustomInkWellWidget(
                    onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                      categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                    )),
                    radius: Dimensions.radiusSmall,
                    child: Column(children: [

                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImageWidget(
                            image: '${categoryController.categoryList![index].imageFullUrl}',
                            height: ResponsiveHelper.isMobile(context) ? 62 : 88, width: ResponsiveHelper.isMobile(context) ? 62 : 88, fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault),

                      Expanded(child: Text(
                        categoryController.categoryList![index].name!,
                        style: robotoRegular.copyWith(
                          fontSize: ResponsiveHelper.isMobile(context) ? 11 : 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      )),

                    ]),
                  ),
                ),
              );
            },
          ) : WebWhatOnYourMindViewShimmer(categoryController: categoryController),
        ),
      ]);
    });
  }
}

class WebWhatOnYourMindViewShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const WebWhatOnYourMindViewShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isMobile(context) ? 96 : 132,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
            child: Container(
              width: ResponsiveHelper.isMobile(context) ? 62 : 88,
              height: ResponsiveHelper.isMobile(context) ? 82 : 116,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              margin: EdgeInsets.only(top: ResponsiveHelper.isMobile(context) ? 0 : Dimensions.paddingSizeSmall),
              child: Column(children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),  
                  child: Shimmer(
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).shadowColor),
                      height: ResponsiveHelper.isMobile(context) ? 58 : 84, width: ResponsiveHelper.isMobile(context) ? 58 : 84,
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeSmall),

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Shimmer(
                    child: Container(
                      height: ResponsiveHelper.isMobile(context) ? 8 : 10, width: 56,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor),
                    ),
                  ),
                ),

              ]),
            ),
          );
        },
      ),
    );
  }
}