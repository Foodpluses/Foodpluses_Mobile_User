import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomCartWidget extends StatelessWidget {
  final int? restaurantId;
  final bool fromDineIn;
  const BottomCartWidget({super.key, this.restaurantId, this.fromDineIn = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
        return Container(
          height: GetPlatform.isIOS ? 100 : 80, 
          width: Get.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Cart icon and info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCF0F14).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: const Color(0xFFCF0F14),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Cart details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${cartController.cartList.length} ${cartController.cartList.length == 1 ? 'item' : 'items'}',
                          style: robotoMedium.copyWith(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PriceConverter.convertPrice(cartController.calculationCart()),
                          style: robotoMedium.copyWith(
                            fontSize: 18,
                            color: const Color(0xFFCF0F14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // View Cart button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BBD07),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6BBD07).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          // Check if user is logged in
                          if (!AuthHelper.isLoggedIn()) {
                            // Show login required dialog
                            _showLoginRequiredDialog(context);
                          } else {
                            // User is logged in, proceed to cart
                            await Get.toNamed(RouteHelper.getCombinedCartCheckoutRoute(fromDineIn: fromDineIn));
                            Get.find<RestaurantController>().makeEmptyRestaurant();
                            if(restaurantId != null) {
                              Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Cart',
                                style: robotoMedium.copyWith(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 14,
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
          ),
        );
      });
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.login,
                color: const Color(0xFFCF0F14),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Login Required',
                style: robotoMedium.copyWith(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          content: Text(
            'Please sign in to view your cart and proceed with checkout.',
            style: robotoRegular.copyWith(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Navigate to sign-in screen with return route
                await Get.toNamed(RouteHelper.getSignInRoute('cart'));
                // After returning from sign-in, check if user is now logged in
                if (AuthHelper.isLoggedIn()) {
                  // User successfully logged in, proceed to cart
                  await Get.toNamed(RouteHelper.getCombinedCartCheckoutRoute(fromDineIn: fromDineIn));
                  Get.find<RestaurantController>().makeEmptyRestaurant();
                  if(restaurantId != null) {
                    Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: restaurantId));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BBD07),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sign In',
                style: robotoMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
