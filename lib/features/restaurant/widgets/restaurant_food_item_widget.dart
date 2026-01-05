import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/closed_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantFoodItemWidget extends StatelessWidget {
  final Product product;
  final int index;
  final int? length;

  const RestaurantFoodItemWidget({
    super.key,
    required this.product,
    required this.index,
    this.length,
  });

  @override
  Widget build(BuildContext context) {
    double? discount = product.restaurantDiscount == 0 ? product.discount : product.restaurantDiscount;
    String? discountType = product.restaurantDiscount == 0 ? product.discountType : 'percent';
    double price = product.price ?? 0;
    double discountPrice = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price;

    // Check if item should hide add button
    bool shouldHideAddButton = _shouldShowClosedOverlay(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: CustomInkWellWidget(
        onTap: () {
          if (product.restaurantStatus == 1) {
            Get.bottomSheet(
              ProductBottomSheetWidget(product: product, inRestaurantPage: true),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            );
          } else {
            showCustomSnackBar('item_is_not_available'.tr);
          }
        },
        radius: 12,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food details - Left side with enhanced styling
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food name with accent
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 20,
                              margin: const EdgeInsets.only(right: 8, top: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                product.name ?? 'Unknown Item',
                                style: robotoMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        
                        // Description
                        if (product.description != null && product.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 11),
                            child: Text(
                              product.description ?? '',
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    
                    // Price section - bottom left, no background
                    Padding(
                      padding: const EdgeInsets.only(left: 11, top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (discount! > 0) ...[
                            Text(
                              PriceConverter.convertPrice(product.price),
                              style: robotoRegular.copyWith(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Icon(
                            Icons.local_offer,
                            size: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            PriceConverter.convertPrice(product.price, discount: discount, discountType: discountType),
                            style: robotoMedium.copyWith(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w700, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Image and Add button - Right side (grouped together)
              Column(
                children: [
                  // Food image container
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageWidget(
                        image: product.imageFullUrl ?? '',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        isFood: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Add button - hide when restaurant is closed, same width as image
                  if (!shouldHideAddButton)
                    GetBuilder<CartController>(
                      builder: (cartController) {
                        int cartQty = cartController.cartQuantity(product.id ?? 0);
                        int cartIndex = cartController.isExistInCart(product.id, null);
                        
                        return cartQty != 0 ? SizedBox(
                          width: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: cartController.isLoading ? null : () {
                                    if (cartController.cartList[cartIndex].quantity! > 1) {
                                      cartController.setQuantity(false, cartController.cartList[cartIndex], cartIndex: cartIndex);
                                    } else {
                                      cartController.removeFromCart(cartIndex);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  cartQty.toString(),
                                  style: robotoMedium.copyWith(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                InkWell(
                                  onTap: cartController.isLoading ? null : () {
                                    cartController.setQuantity(true, cartController.cartList[cartIndex], cartIndex: cartIndex);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) : SizedBox(
                          width: 100,
                          child: InkWell(
                            onTap: () => Get.find<ProductController>().productDirectlyAddToCart(product, context),
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Center(
                                child: Text(
                                  'Add',
                                  style: robotoMedium.copyWith(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if item should show closed overlay
  bool _shouldShowClosedOverlay(Product product) {
    // Check if business is shutdown
    bool isBusinessShutdown = Get.find<SplashController>().configModel?.businessShutdown ?? false;
    if (isBusinessShutdown) {
      return true;
    }

    // Check if restaurant is active (vendor closed) - use restaurantController
    RestaurantController restaurantController = Get.find<RestaurantController>();
    if (restaurantController.restaurant != null) {
      if (restaurantController.restaurant!.active == false) {
        return true;
      }

      // Check if restaurant is open based on schedules
      bool isRestaurantOpen = restaurantController.isRestaurantOpenNow(
        restaurantController.restaurant!.active!,
        restaurantController.restaurant!.schedules
      );
      if (!isRestaurantOpen) {
        return true;
      }
    }

    return false;
  }

  // Get the appropriate closed text for the overlay
  String _getClosedText(Product product) {
    // Check if business is shutdown
    bool isBusinessShutdown = Get.find<SplashController>().configModel?.businessShutdown ?? false;
    if (isBusinessShutdown) {
      return 'business_closed'.tr;
    }

    // Check if restaurant is active (vendor closed) - use restaurantController
    RestaurantController restaurantController = Get.find<RestaurantController>();
    if (restaurantController.restaurant != null) {
      if (restaurantController.restaurant!.active == false) {
        return 'restaurant_temporarily_closed'.tr;
      }

      // Check if restaurant is open based on schedules
      bool isRestaurantOpen = restaurantController.isRestaurantOpenNow(
        restaurantController.restaurant!.active!,
        restaurantController.restaurant!.schedules
      );
      if (!isRestaurantOpen) {
        return 'restaurant_is_closed'.tr;
      }
    }

    return 'closed'.tr;
  }
}
