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

    // Check if item should show closed overlay
    bool shouldShowOverlay = _shouldShowClosedOverlay(product);
    String closedText = _getClosedText(product);

    return ClosedOverlayWidget(
      isClosed: shouldShowOverlay,
      closedText: closedText,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
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
        radius: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Food details - Left side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name
                    Text(
                      product.name ?? 'Unknown Item',
                      style: robotoMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Description
                    Text(
                      product.description ?? '',
                      style: robotoRegular.copyWith(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Price section
                    Row(
                      children: [
                        if (discount! > 0) ...[
                          Text(
                            PriceConverter.convertPrice(product.price),
                            style: robotoRegular.copyWith(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          PriceConverter.convertPrice(product.price, discount: discount, discountType: discountType),
                          style: robotoMedium.copyWith(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600, 
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Image and Add button - Right side (grouped together)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Food image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        image: product.imageFullUrl ?? '',
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        isFood: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Add button
                    GetBuilder<CartController>(
                      builder: (cartController) {
                        int cartQty = cartController.cartQuantity(product.id ?? 0);
                        int cartIndex = cartController.isExistInCart(product.id, null);
                        
                        return cartQty != 0 ? Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  cartQty.toString(),
                                  style: robotoMedium.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
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
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) : InkWell(
                          onTap: () => Get.find<ProductController>().productDirectlyAddToCart(product, context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Add +',
                              style: robotoMedium.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
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
