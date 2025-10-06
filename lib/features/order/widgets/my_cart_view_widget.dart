import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/features/checkout/screens/checkout_screen.dart';

class MyCartViewWidget extends StatelessWidget {
  const MyCartViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        return GetBuilder<RestaurantController>(
          builder: (restaurantController) {
            if (cartController.cartList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'your_cart_is_empty'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'add_some_items_to_cart'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Group cart items by restaurant
            Map<int, List<dynamic>> restaurantGroups = {};
            for (var cart in cartController.cartList) {
              int restaurantId = cart.product!.restaurantId!;
              if (!restaurantGroups.containsKey(restaurantId)) {
                restaurantGroups[restaurantId] = [];
              }
              restaurantGroups[restaurantId]!.add(cart);
            }

            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: Column(
                children: [
                  // Clear Cart Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                title: Text('clear_cart'.tr),
                                content: Text('are_you_sure_to_clear_cart'.tr),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('cancel'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      cartController.clearCartList();
                                      Get.back();
                                    },
                                    child: Text(
                                      'clear'.tr,
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.clear_all,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                          label: Text(
                            'clear_cart'.tr,
                            style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Cart Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      itemCount: restaurantGroups.length,
                      itemBuilder: (context, index) {
                        int restaurantId = restaurantGroups.keys.elementAt(index);
                        List<dynamic> restaurantCarts = restaurantGroups[restaurantId]!;
                        CartModel firstCart = restaurantCarts[0];

                        int totalItems = restaurantCarts.fold<int>(0, (int sum, cart) => sum + (cart.quantity as int? ?? 0));
                        double totalPrice = restaurantCarts.fold(0.0, (double sum, cart) => sum + ((cart.discountedPrice ?? 0.0) * (cart.quantity ?? 0)));
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Restaurant Info Row
                                Row(
                                  children: [
                                     // Restaurant Image
                                     ClipRRect(
                                       borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                       child: CustomImageWidget(
                                         image: '', // Use placeholder since we don't have restaurant image in cart
                                         height: 50,
                                         width: 50,
                                         fit: BoxFit.cover,
                                         isRestaurant: true,
                                       ),
                                     ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    
                                    // Restaurant Name and Item Count
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            firstCart.product!.restaurantName ?? 'Restaurant',
                                            style: robotoMedium.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$totalItems Item${totalItems > 1 ? 's' : ''} • ${PriceConverter.convertPrice(totalPrice)}',
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: Theme.of(context).disabledColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // View Selection Button
                                    TextButton.icon(
                                      onPressed: () {
                                        // Navigate to restaurant or cart details
                                        Get.toNamed(RouteHelper.getRestaurantRoute(restaurantId));
                                      },
                                      icon: Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      label: Text(
                                        'view_selection'.tr,
                                        style: robotoMedium.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: Dimensions.fontSizeSmall,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                
                                // Delivery Address
                                Row(
                                  children: [
                                    Icon(
                                      Icons.delivery_dining,
                                      size: 16,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                      child: Text(
                                        'delivering_to_address'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).disabledColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: Dimensions.paddingSizeDefault),
                                
                                // Checkout Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                     onPressed: () {
                                       Get.toNamed(RouteHelper.getCombinedCartCheckoutRoute());
                                     },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeDefault,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      ),
                                    ),
                                    child: Text(
                                      'checkout'.tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                
                                // Clear Selection Button
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      // Remove all items from this restaurant
                                      List<int> indicesToRemove = [];
                                      for (int i = 0; i < cartController.cartList.length; i++) {
                                        if (cartController.cartList[i].product!.restaurantId == restaurantId) {
                                          indicesToRemove.add(i);
                                        }
                                      }
                                      for (int i = indicesToRemove.length - 1; i >= 0; i--) {
                                        cartController.removeFromCart(indicesToRemove[i]);
                                      }
                                    },
                                    child: Text(
                                      'clear_selection'.tr,
                                      style: robotoMedium.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
