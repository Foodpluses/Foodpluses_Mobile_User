import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/cart/domain/models/cart_model.dart';
import 'package:stackfood_multivendor/features/cart/widgets/cart_suggested_item_view_widget.dart';
import 'package:stackfood_multivendor/features/cart/widgets/pricing_view_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/pricing_view_model.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart';
import 'package:stackfood_multivendor/features/checkout/domain/models/place_order_body_model.dart' as place_order_model;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CombinedCartCheckoutScreen extends StatefulWidget {
  final bool fromNav;
  final bool fromReorder;
  final bool fromDineIn;
  
  const CombinedCartCheckoutScreen({
    super.key, 
    required this.fromNav, 
    this.fromReorder = false, 
    this.fromDineIn = false
  });

  @override
  State<CombinedCartCheckoutScreen> createState() => _CombinedCartCheckoutScreenState();
}

class _CombinedCartCheckoutScreenState extends State<CombinedCartCheckoutScreen> {
  
  int _currentTabIndex = 0;
  
  // Payment and checkout related variables
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  bool _isWalletActive = false;
  double? _payableAmount = 0;
  
  // Guest checkout controllers
  final TextEditingController guestContactPersonNameController = TextEditingController();
  final TextEditingController guestContactPersonNumberController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkBusinessStatus();
  }
  
  void _checkBusinessStatus() {
    // Check business shutdown status without refreshing config
    // This avoids routing issues
    Future.delayed(Duration(milliseconds: 500), () {
      _refreshBusinessStatusOnly();
    });
  }
  
  void _refreshBusinessStatusOnly() async {
    try {
      // Make a direct API call to get business shutdown status
      // This doesn't trigger the SplashController routing logic
      var response = await Get.find<ApiClient>().getData('/api/v1/config');
      if (response.statusCode == 200) {
        var data = response.body;
        bool businessShutdown = data['business_shutdown'] ?? false;
        
        // Update the config model directly without triggering routing
        var configModel = Get.find<SplashController>().configModel;
        if (configModel != null) {
          configModel.businessShutdown = businessShutdown;
          // Trigger UI update
          Get.find<SplashController>().update();
        }
      }
    } catch (e) {
      print('Business status check failed: $e');
    }
  }

  Future<void> _initializeData() async {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    
    // Initialize checkout controllers
    Get.find<CheckoutController>().streetNumberController.text = AddressHelper.getAddressFromSharedPref()!.road ?? '';
    Get.find<CheckoutController>().houseController.text = AddressHelper.getAddressFromSharedPref()!.house ?? '';
    Get.find<CheckoutController>().floorController.text = AddressHelper.getAddressFromSharedPref()!.floor ?? '';
    Get.find<CheckoutController>().couponController.text = '';
    
    Get.find<CheckoutController>().getDmTipMostTapped();
    Get.find<CheckoutController>().setPreferenceTimeForView('', false, isUpdate: false);
    Get.find<CheckoutController>().setCustomDate(null, false, canUpdate: false);
    
    Get.find<CheckoutController>().getOfflineMethodList();
    Get.find<CheckoutController>().initDineInSetup();
    
    Get.find<LocationController>().getZone(
      AddressHelper.getAddressFromSharedPref()!.latitude,
      AddressHelper.getAddressFromSharedPref()!.longitude, false, updateInAddress: true,
    );
    
    if(isLoggedIn){
      if(Get.find<ProfileController>().userInfoModel == null && Get.find<ProfileController>().userInfoModel!.userInfo == null) {
        Get.find<ProfileController>().getUserInfo();
      }
      
      Get.find<CouponController>().getCouponList();
      
      if(Get.find<AddressController>().addressList == null) {
        Get.find<AddressController>().getAddressList(canInsertAddress: true);
      }
    } else {
      // Initialize guest address from shared preferences
      _initializeGuestAddress();
    }
    
    // Initialize cart and restaurant data
    Get.find<RestaurantController>().makeEmptyRestaurant(willUpdate: false);
    Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
    Get.find<CheckoutController>().setInstruction(-1, willUpdate: false);
    await Get.find<CartController>().getCartDataOnline();
    
    if (Get.find<CartController>().cartList.isNotEmpty) {
      await Get.find<RestaurantController>().getRestaurantDetails(
        Restaurant(id: Get.find<CartController>().cartList[0].product!.restaurantId, name: null), 
        fromCart: true
      );
      Get.find<CartController>().calculationCart();
      
      // Set restaurant details for checkout
      await Get.find<CheckoutController>().setRestaurantDetails(restaurantId: Get.find<CartController>().cartList[0].product!.restaurantId);
      await Get.find<CheckoutController>().initCheckoutData(Get.find<CartController>().cartList[0].product!.restaurantId);
      
      // Initialize address after restaurant data is loaded
      if (isLoggedIn) {
        await _initializeDefaultAddress();
      } else {
        // Initialize guest address after restaurant data is loaded
        _initializeGuestAddress();
      }
    }
    
    Get.find<CouponController>().setCoupon('', isUpdate: false);
    Get.find<CheckoutController>().stopLoader(isUpdate: false);
    Get.find<CheckoutController>().updateTimeSlot(0, false, notify: false);
    
    // Set payment method availability
    _isCashOnDeliveryActive = Get.find<SplashController>().configModel!.cashOnDelivery;
    _isDigitalPaymentActive = Get.find<SplashController>().configModel!.digitalPayment;
    _isOfflinePaymentActive = Get.find<SplashController>().configModel!.offlinePaymentStatus!;
    _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
    
    Get.find<CheckoutController>().updateTips(
      Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 0, notify: false,
    );
    Get.find<CheckoutController>().tipController.text = Get.find<CheckoutController>().selectedTips != -1 ? AppConstants.tips[Get.find<CheckoutController>().selectedTips] : '';
    
    _setSinglePaymentActive();
    
    // Set guest contact info if logged in
    if(AuthHelper.isLoggedIn()) {
      String phone = await _splitPhoneNumber(Get.find<ProfileController>().userInfoModel?.userInfo?.phone ?? '');
      
      guestContactPersonNameController.text = '${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.userInfo?.lName ?? ''}';
      guestContactPersonNumberController.text = phone;
      guestEmailController.text = Get.find<ProfileController>().userInfoModel?.userInfo?.email ?? '';
    }
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if(!Get.find<SplashController>().configModel!.homeDelivery! && Get.find<SplashController>().configModel!.takeAway!) {
        Get.find<CheckoutController>().setOrderType('take_away', notify: true);
      }
      
      if(Get.find<CheckoutController>().isPartialPay){
        Get.find<CheckoutController>().changePartialPayment(isUpdate: false);
      }
      
      if(widget.fromDineIn) {
        _selectDineIn();
      }
    });
  }

  Future<String> _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    Get.find<CheckoutController>().countryDialCode = '+${phoneNumber.countryCode}';
    return phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }

  void _initializeGuestAddress() {
    CheckoutController checkoutController = Get.find<CheckoutController>();
    AddressModel? defaultAddress = AddressHelper.getAddressFromSharedPref();
    
    if (defaultAddress != null) {
      // Set the guest address from shared preferences
      checkoutController.setGuestAddress(defaultAddress);
      
      // Calculate distance for the guest address
      if (checkoutController.restaurant != null && 
          defaultAddress.latitude != null && 
          defaultAddress.longitude != null &&
          checkoutController.restaurant!.latitude != null &&
          checkoutController.restaurant!.longitude != null) {
        checkoutController.getDistanceInKM(
          LatLng(double.parse(defaultAddress.latitude!), double.parse(defaultAddress.longitude!)),
          LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
        );
      }
    }
  }

  Future<void> _initializeDefaultAddress() async {
    CheckoutController checkoutController = Get.find<CheckoutController>();
    AddressModel? defaultAddress = AddressHelper.getAddressFromSharedPref();
    
    if (defaultAddress != null) {
      // Wait for addresses to be loaded
      int attempts = 0;
      while (checkoutController.address.isEmpty && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      // If addresses are loaded, find the matching address or add the default one
      if (checkoutController.address.isNotEmpty) {
        // Try to find matching address in the list
        int matchingIndex = -1;
        for (int i = 0; i < checkoutController.address.length; i++) {
          if (checkoutController.address[i].address == defaultAddress.address &&
              checkoutController.address[i].latitude == defaultAddress.latitude &&
              checkoutController.address[i].longitude == defaultAddress.longitude) {
            matchingIndex = i;
            break;
          }
        }
        
        if (matchingIndex != -1) {
          // Set the matching address as selected
          checkoutController.setAddressIndex(matchingIndex);
        } else {
          // Add the default address to the list and set it as selected
          checkoutController.insertAddresses(Get.context!, defaultAddress, notify: true);
          checkoutController.setAddressIndex(checkoutController.address.length - 1);
        }
      } else {
        // If no addresses loaded, add the default address
        checkoutController.insertAddresses(Get.context!, defaultAddress, notify: true);
        checkoutController.setAddressIndex(0);
      }
      
      // Calculate distance for the selected address
      if (checkoutController.restaurant != null && 
          defaultAddress.latitude != null && 
          defaultAddress.longitude != null &&
          checkoutController.restaurant!.latitude != null &&
          checkoutController.restaurant!.longitude != null) {
        checkoutController.getDistanceInKM(
          LatLng(double.parse(defaultAddress.latitude!), double.parse(defaultAddress.longitude!)),
          LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
        );
      }
    }
  }

  void _setSinglePaymentActive() {
    if(!(_isCashOnDeliveryActive ?? false) && (_isDigitalPaymentActive ?? false) && Get.find<SplashController>().configModel!.activePaymentMethodList!.length == 1 && !_isWalletActive) {
      Get.find<CheckoutController>().setPaymentMethod(2, willUpdate: false);
      Get.find<CheckoutController>().changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![0].getWay!);
    }
  }

  Future<void> _selectDineIn() async {
    Future.delayed(Duration(milliseconds: 800), () {
      Get.find<CheckoutController>().setOrderType('dine_in', notify: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWidget(
        title: 'checkout'.tr,
        isBackButtonExist: !widget.fromNav,
      ),
      body: GetBuilder<CartController>(builder: (cartController) {
        return GetBuilder<RestaurantController>(builder: (restaurantController) {
        bool isRestaurantOpen = true;
        bool isBusinessShutdown = Get.find<SplashController>().configModel?.businessShutdown ?? false;
        

        if (restaurantController.restaurant != null) {
          isRestaurantOpen = restaurantController.isRestaurantOpenNow(
            restaurantController.restaurant!.active!,
            restaurantController.restaurant!.schedules
          );
        }

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
                  const SizedBox(height: 16),
                  Text(
                    'you_have_not_add_to_cart_yet'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator with clickable labels
              _buildProgressIndicator(),
              
              // Content based on current tab
              Expanded(
                child: _currentTabIndex == 0 
                  ? _buildYourOrderTab(cartController, restaurantController, isRestaurantOpen, isBusinessShutdown)
                  : _buildDeliveryPaymentTab(cartController, restaurantController, isRestaurantOpen, isBusinessShutdown),
              ),
            ],
          );
        });
      }),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentTabIndex >= 0 ? Colors.orange : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentTabIndex >= 1 ? Colors.orange : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Clickable labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = 0;
                  });
                },
                child: Text(
                  'Your Order',
                  style: robotoMedium.copyWith(
                    fontSize: 14,
                    color: _currentTabIndex >= 0 ? Colors.orange : Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = 1;
                  });
                },
                child: Text(
                  'Delivery & Payment',
                  style: robotoMedium.copyWith(
                    fontSize: 14,
                    color: _currentTabIndex >= 1 ? Colors.orange : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYourOrderTab(CartController cartController, RestaurantController restaurantController, bool isRestaurantOpen, bool isBusinessShutdown) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant info
          _buildRestaurantInfo(restaurantController),
          
          const SizedBox(height: 16),
          
          // Cart items
          _buildCartItems(cartController, isRestaurantOpen),
          
          const SizedBox(height: 16),
          
          // Suggested items
          CartSuggestedItemViewWidget(cartList: cartController.cartList),
          
          const SizedBox(height: 16),
          
          // Add more items button
          _buildAddMoreItemsButton(cartController, isRestaurantOpen),
          
          const SizedBox(height: 16),
          
          // Pricing view
          PricingViewWidget(
            cartController: cartController, 
            isRestaurantOpen: isRestaurantOpen, 
            fromDineIn: widget.fromDineIn,
          ),
          
          const SizedBox(height: 16),
          
          // Make Payment button
          _buildMakePaymentButton(),
          
          const SizedBox(height: 12),
          
          // Clear cart button
          _buildClearCartButton(cartController),
        ],
      ),
    );
  }

  Widget _buildRestaurantInfo(RestaurantController restaurantController) {
    if (restaurantController.restaurant == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.orange.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                restaurantController.restaurant!.logoFullUrl ?? '',
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    color: Colors.orange,
                    size: 24,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantController.restaurant!.name ?? 'Restaurant',
                  style: robotoMedium.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Get.find<CartController>().cartList.length} ${Get.find<CartController>().cartList.length > 1 ? 'items' : 'item'}',
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartController cartController, bool isRestaurantOpen) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cart items list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartController.cartList.length,
            itemBuilder: (context, index) {
              return _buildStylishCartItem(cartController.cartList[index], index, cartController, isRestaurantOpen);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStylishCartItem(CartModel cart, int index, CartController cartController, bool isRestaurantOpen) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header with image and basic info
          Row(
            children: [
              // Item image
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: cart.product?.imageFullUrl != null
                    ? Image.network(
                        cart.product!.imageFullUrl!,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fastfood,
                            color: Colors.orange,
                            size: 30,
                          );
                        },
                      )
                    : Icon(
                        Icons.fastfood,
                        color: Colors.orange,
                        size: 30,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cart.product?.name ?? 'Item',
                      style: robotoMedium.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cart.product?.restaurantName ?? 'Restaurant',
                      style: robotoRegular.copyWith(
                        fontSize: 12, 
                        color: Theme.of(context).disabledColor, 
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      PriceConverter.convertPrice(cart.price!),
                      style: robotoMedium.copyWith(
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Remove button
              IconButton(
                onPressed: cartController.isLoading ? null : () {
                  cartController.removeFromCart(index);
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
              ),
            ],
          ),
          
          // Add-ons if any
          if (cart.addOns != null && cart.addOns!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add-ons:',
                    style: robotoMedium.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...cart.addOns!.map((addon) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${addon.name}',
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Quantity controls and total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Minus button
                    IconButton(
                      onPressed: cartController.isLoading ? null : () {
                        if (cart.quantity! > 1) {
                          cartController.setQuantity(false, cart, cartIndex: index);
                        } else {
                          cartController.removeFromCart(index);
                        }
                      },
                      icon: Icon(
                        cart.quantity! == 1 ? Icons.delete_outline : Icons.remove,
                        color: cart.quantity! == 1 ? Theme.of(context).colorScheme.error : Colors.orange,
                        size: 18,
                      ),
                    ),
                    
                    // Quantity display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        '${cart.quantity}',
                        style: robotoMedium.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    
                    // Plus button
                    IconButton(
                      onPressed: cartController.isLoading ? null : () {
                        cartController.setQuantity(true, cart, cartIndex: index);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.orange,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Total price for this item
              Text(
                PriceConverter.convertPrice(cart.price! * cart.quantity!),
                style: robotoBold.copyWith(
                  fontSize: 16,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreItemsButton(CartController cartController, bool isRestaurantOpen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: CustomInkWellWidget(
        onTap: () {
          // Always navigate to the restaurant where the order was made
          Get.toNamed(
            RouteHelper.getRestaurantRoute(cartController.cartList[0].product!.restaurantId),
            arguments: RestaurantScreen(restaurant: Restaurant(id: cartController.cartList[0].product!.restaurantId)),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Another Item',
              style: robotoMedium.copyWith(
                color: Colors.orange,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMakePaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currentTabIndex = 1;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Make Payment',
          style: robotoMedium.copyWith(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildClearCartButton(CartController cartController) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: cartController.isClearCartLoading ? null : () {
          _showClearCartDialog(cartController);
        },
        icon: cartController.isClearCartLoading 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
        label: Text(
          cartController.isClearCartLoading 
            ? 'Clearing...' 
            : 'Clear Order',
          style: robotoMedium.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Theme.of(context).colorScheme.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryPaymentTab(CartController cartController, RestaurantController restaurantController, bool isRestaurantOpen, bool isBusinessShutdown) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order type section
          // _buildOrderTypeSection(),
          
          // const SizedBox(height: 16),
          
          // Delivery section
          _buildDeliverySection(),
          
          const SizedBox(height: 16),
          
          // Payment method section
          _buildPaymentMethodSection(),
          
          const SizedBox(height: 16),
          
          // Coupon section
          _buildCouponSection(),
          
          const SizedBox(height: 16),
          
          // Additional note section
          _buildAdditionalNoteSection(),
          
          const SizedBox(height: 16),
          
          // Pricing summary
          _buildPricingSummary(cartController),
          
          const SizedBox(height: 20),
          
          // Place order button
          _buildPlaceOrderButton(cartController, isRestaurantOpen, isBusinessShutdown),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSection() {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Type',
                style: robotoMedium.copyWith(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOrderTypeOption(
                      'Regular Order', 
                      Icons.restaurant, 
                      !checkoutController.subscriptionOrder,
                      () {
                        checkoutController.setSubscription(false);
                        if(checkoutController.isPartialPay){
                          checkoutController.changePartialPayment();
                        } else {
                          checkoutController.setPaymentMethod(-1);
                        }
                        checkoutController.updateTips(
                          Get.find<AuthController>().getDmTipIndex().isNotEmpty ? int.parse(Get.find<AuthController>().getDmTipIndex()) : 1, 
                          notify: false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildOrderTypeOption(
                      'Subscription', 
                      Icons.repeat, 
                      checkoutController.subscriptionOrder,
                      () {
                        checkoutController.setSubscription(true);
                        checkoutController.addTips(0);
                        if(checkoutController.isPartialPay){
                          checkoutController.changePartialPayment();
                        } else {
                          checkoutController.setPaymentMethod(-1);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderTypeOption(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: robotoMedium.copyWith(
                fontSize: 12,
                color: isSelected ? Colors.orange : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Details',
                style: robotoMedium.copyWith(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              
              // Delivery address
              CustomInkWellWidget(
                onTap: () => _showAddressSelectionDialog(checkoutController),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Address',
                            style: robotoMedium.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCurrentAddressText(checkoutController),
                            style: robotoRegular.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).disabledColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).disabledColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodSection() {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Method',
                    style: robotoMedium.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Icon(
                    Icons.payment,
                    color: Colors.orange,
                    size: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Payment options
              if (_isCashOnDeliveryActive ?? false)
                _buildPaymentOption(
                  'Cash on Delivery', 
                  Icons.money, 
                  checkoutController.paymentMethodIndex == 0,
                  () => checkoutController.setPaymentMethod(0),
                ),
              
              if (_isCashOnDeliveryActive ?? false) const SizedBox(height: 12),
              
              if (_isWalletActive)
                _buildPaymentOption(
                  'Wallet Payment', 
                  Icons.account_balance_wallet, 
                  checkoutController.paymentMethodIndex == 1,
                  () => checkoutController.setPaymentMethod(1),
                  walletBalance: Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0,
                ),
              
              if (_isWalletActive) const SizedBox(height: 12),
              
              if (_isDigitalPaymentActive ?? false)
                _buildPaymentOption(
                  'Digital Payment', 
                  Icons.credit_card, 
                  checkoutController.paymentMethodIndex == 2,
                  () => _showDigitalPaymentOptions(checkoutController),
                ),
              
              if (_isOfflinePaymentActive) ...[
                const SizedBox(height: 12),
                _buildPaymentOption(
                  'Offline Payment', 
                  Icons.account_balance, 
                  checkoutController.paymentMethodIndex == 3,
                  () => checkoutController.setPaymentMethod(3),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, bool isSelected, VoidCallback onTap, {double? walletBalance}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoRegular.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (walletBalance != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Balance: ${PriceConverter.convertPrice(walletBalance)}',
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.orange,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showDigitalPaymentOptions(CheckoutController checkoutController) {
    if(ResponsiveHelper.isDesktop(context)){
      Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
        isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, 
        isDigitalPaymentActive: _isDigitalPaymentActive ?? false,
        isWalletActive: _isWalletActive, 
        totalPrice: Get.find<CartController>().subTotal, 
        isOfflinePaymentActive: _isOfflinePaymentActive,
      )));
    } else {
      showModalBottomSheet(
        context: context, 
        isScrollControlled: true, 
        backgroundColor: Colors.transparent,
        builder: (con) => PaymentMethodBottomSheet(
          isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, 
          isDigitalPaymentActive: _isDigitalPaymentActive ?? false,
          isWalletActive: _isWalletActive, 
          totalPrice: Get.find<CartController>().subTotal, 
          isOfflinePaymentActive: _isOfflinePaymentActive,
        ),
      );
    }
  }

  Widget _buildCouponSection() {
    return GetBuilder<CouponController>(
      builder: (couponController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coupon Code',
                    style: robotoMedium.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextFieldWidget(
                      controller: Get.find<CheckoutController>().couponController,
                      hintText: 'Enter coupon code',
                      showLabelText: false,
                      inputType: TextInputType.text,
                      inputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: couponController.isLoading ? null : () {
                      _applyCoupon();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: couponController.isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Apply',
                          style: robotoMedium.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ],
              ),
              
              if (couponController.discount! > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Coupon applied! You saved ${PriceConverter.convertPrice(couponController.discount!)}',
                          style: robotoMedium.copyWith(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          couponController.removeCouponData(true);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdditionalNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_add,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Additional Note',
                style: robotoMedium.copyWith(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          CustomTextFieldWidget(
            controller: Get.find<CheckoutController>().noteController,
            hintText: 'Share any specific delivery details here',
            showLabelText: false,
            maxLines: 3,
            inputType: TextInputType.multiline,
            inputAction: TextInputAction.done,
            capitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary(CartController cartController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: robotoMedium.copyWith(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sub-total
          _buildSummaryRow(
            icon: Icons.shopping_cart_outlined,
            label: 'Sub-total (${cartController.cartList.length} ${cartController.cartList.length > 1 ? 'items' : 'item'})',
            amount: PriceConverter.convertPrice(cartController.itemPrice),
          ),
          
          const SizedBox(height: 12),
          
          // Delivery fee
          _buildSummaryRow(
            icon: Icons.local_shipping_outlined,
            label: 'Delivery Fee',
            amount: PriceConverter.convertPrice(0), // Will be calculated properly
          ),
          
          const SizedBox(height: 12),
          
          // Tax
          _buildSummaryRow(
            icon: Icons.receipt_outlined,
            label: 'Tax',
            amount: PriceConverter.convertPrice(0), // Will be calculated properly
          ),
          
          // Coupon discount
          GetBuilder<CouponController>(
            builder: (couponController) {
              if (couponController.discount! > 0) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      icon: Icons.local_offer_outlined,
                      label: 'Coupon Discount',
                      amount: '-${PriceConverter.convertPrice(couponController.discount!)}',
                      isDiscount: true,
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          
          const SizedBox(height: 16),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total',
                    style: robotoMedium.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              Text(
                PriceConverter.convertPrice(cartController.subTotal),
                style: robotoBold.copyWith(
                  fontSize: 18,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String amount,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: robotoMedium.copyWith(
            fontSize: 14,
            color: isDiscount ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Future<void> _applyCoupon() async {
    String couponCode = Get.find<CheckoutController>().couponController.text.trim();
    if (couponCode.isEmpty) {
      showCustomSnackBar('Please enter a coupon code');
      return;
    }
    
    CartController cartController = Get.find<CartController>();
    CouponController couponController = Get.find<CouponController>();
    
    // Calculate order amount for coupon validation
    double orderAmount = cartController.subTotal;
    double deliveryCharge = 0; // Will be calculated properly
    double total = orderAmount + deliveryCharge;
    
    await couponController.applyCoupon(
      couponCode, 
      orderAmount, 
      deliveryCharge, 
      deliveryCharge, 
      total, 
      cartController.cartList.isNotEmpty ? cartController.cartList[0].product!.restaurantId : null,
    );
  }

  Widget _buildPlaceOrderButton(CartController cartController, bool isRestaurantOpen, bool isBusinessShutdown) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isRestaurantOpen && !isBusinessShutdown) ? () {
          // Place order logic
          _placeOrder();
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: (isRestaurantOpen && !isBusinessShutdown) ? Colors.orange : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isBusinessShutdown ? 'Business Closed' : 
          isRestaurantOpen ? 'Place Order' : 'Restaurant Closed',
          style: robotoMedium.copyWith(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showClearCartDialog(CartController cartController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to clear your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cartController.clearCartOnline();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    // Check if business is shutdown
    bool isBusinessShutdown = Get.find<SplashController>().configModel?.businessShutdown ?? false;
    if (isBusinessShutdown) {
      showCustomSnackBar('business_is_shutdown'.tr);
      return;
    }
    
    // Proceed with order placement
    await _proceedWithOrder();
  }
  
  Future<void> _proceedWithOrder() async {
    
    CartController cartController = Get.find<CartController>();
    CheckoutController checkoutController = Get.find<CheckoutController>();
    CouponController couponController = Get.find<CouponController>();
    
    // Validate order before placing
    if (!_validateOrder()) {
      return;
    }
    
    // Prepare order data
    DateTime scheduleStartDate = _processScheduleStartDate();
    DateTime scheduleEndDate = _processScheduleEndDate();
    bool isAvailable = _checkAvailability(scheduleStartDate, scheduleEndDate);
    bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
    bool datePicked = _isDatePicked();
    
    if (checkoutController.isDmTipSave && checkoutController.selectedTips != AppConstants.tips.length - 1) {
      Get.find<AuthController>().saveDmTipIndex(checkoutController.selectedTips.toString());
    }
    if(!checkoutController.isDmTipSave){
      Get.find<AuthController>().saveDmTipIndex('0');
    }
    
    if(_showsWarningMessage(context, isGuestLogIn, datePicked, isAvailable)){
      return;
    }
    
    AddressModel? finalAddress = _processFinalAddress(isGuestLogIn);
    List<place_order_model.OnlineCart> carts = _generateOnlineCartList();
    List<place_order_model.SubscriptionDays> days = _generateSubscriptionDays();
    PlaceOrderBodyModel placeOrderBody = _preparePlaceOrderModel(carts, scheduleStartDate, finalAddress, isGuestLogIn, days);
    
    // Calculate totals
    double total = cartController.subTotal;
    double? maxCodOrderAmount = null; // Will be calculated properly
    
    if(checkoutController.paymentMethodIndex == 3){
      // Handle offline payment
      Get.toNamed(RouteHelper.getOfflinePaymentScreen(
        placeOrderBody: placeOrderBody, 
        zoneId: checkoutController.restaurant!.zoneId!, 
        total: total, 
        maxCodOrderAmount: maxCodOrderAmount,
        fromCart: true, 
        isCodActive: _isCashOnDeliveryActive ?? false,
        pricingView: PricingViewModel(
          subTotal: cartController.subTotal,
          subscriptionQty: 1,
          discount: couponController.discount ?? 0,
          taxIncluded: false,
          tax: 0,
          deliveryCharge: 0,
          total: total,
          taxPercent: 0,
        ),
      ));
    } else {
      // Place order directly
      await checkoutController.placeOrder(
        placeOrderBody, 
        checkoutController.restaurant!.zoneId!, 
        total, 
        maxCodOrderAmount, 
        true, 
        _isCashOnDeliveryActive ?? false
      );
    }
  }

  bool _validateOrder() {
    CartController cartController = Get.find<CartController>();
    CheckoutController checkoutController = Get.find<CheckoutController>();
    
    if (cartController.cartList.isEmpty) {
      showCustomSnackBar('Your cart is empty');
      return false;
    }
    
    if (checkoutController.paymentMethodIndex == -1) {
      if(ResponsiveHelper.isDesktop(context)){
        Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
          isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, 
          isDigitalPaymentActive: _isDigitalPaymentActive ?? false,
          isWalletActive: _isWalletActive, 
          totalPrice: cartController.subTotal, 
          isOfflinePaymentActive: _isOfflinePaymentActive,
        )));
      } else {
        showModalBottomSheet(
          context: context, 
          isScrollControlled: true, 
          backgroundColor: Colors.transparent,
          builder: (con) => PaymentMethodBottomSheet(
            isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false, 
            isDigitalPaymentActive: _isDigitalPaymentActive ?? false,
            isWalletActive: _isWalletActive, 
            totalPrice: cartController.subTotal, 
            isOfflinePaymentActive: _isOfflinePaymentActive,
          ),
        );
      }
      return false;
    }
    
    return true;
  }

  bool _isDatePicked() {
    bool datePicked = false;
    for(DateTime? time in Get.find<CheckoutController>().selectedDays) {
      if(time != null) {
        datePicked = true;
        break;
      }
    }
    return datePicked;
  }

  DateTime _processScheduleStartDate() {
    DateTime scheduleStartDate = DateTime.now();
    CheckoutController checkoutController = Get.find<CheckoutController>();
    if(checkoutController.timeSlots != null && checkoutController.timeSlots!.isNotEmpty) {
      DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : checkoutController.selectedCustomDate?? DateTime.now();
      DateTime startTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot!].startTime!;

      if(checkoutController.orderType == 'dine_in') {
        scheduleStartDate = checkoutController.orderPlaceDineInDateTime ?? DateTime.now();
      } else {
        scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute + 1);
      }
    }
    return scheduleStartDate;
  }

  DateTime _processScheduleEndDate() {
    DateTime scheduleEndDate = DateTime.now();
    CheckoutController checkoutController = Get.find<CheckoutController>();
    if(checkoutController.timeSlots != null && checkoutController.timeSlots!.isNotEmpty) {
      DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now()
          : checkoutController.selectedDateSlot == 1 ? DateTime.now().add(const Duration(days: 1)) : checkoutController.selectedCustomDate?? DateTime.now();
      DateTime endTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot!].endTime!;
      if(checkoutController.orderType == 'dine_in') {
        scheduleEndDate = checkoutController.orderPlaceDineInDateTime?.add(const Duration(minutes: 1)) ?? DateTime.now().add(const Duration(minutes: 1));
      } else {
        scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute + 1);
      }
    }
    return scheduleEndDate;
  }

  bool _checkAvailability(DateTime scheduleStartDate, DateTime scheduleEndDate) {
    bool isAvailable = true;
    CheckoutController checkoutController = Get.find<CheckoutController>();
    CartController cartController = Get.find<CartController>();
    
    if(checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
      isAvailable = false;
    } else {
      for (CartModel cart in cartController.cartList) {
        if (!DateConverter.isAvailable(
          cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
          time: checkoutController.restaurant!.scheduleOrder! ? scheduleStartDate : null,
        ) && !DateConverter.isAvailable(
          cart.product!.availableTimeStarts, cart.product!.availableTimeEnds,
          time: checkoutController.restaurant!.scheduleOrder! ? scheduleEndDate : null,
        )) {
          isAvailable = false;
          break;
        }
      }
    }
    return isAvailable;
  }

  bool _showsWarningMessage(BuildContext context, bool isGuestLogIn, bool datePicked, bool isAvailable) {
    CheckoutController checkoutController = Get.find<CheckoutController>();
    
    if(isGuestLogIn && checkoutController.guestAddress == null && checkoutController.orderType != 'take_away'&& checkoutController.orderType != 'dine_in'){
      showCustomSnackBar('please_setup_your_delivery_address_first'.tr);
      return true;
    } else if(checkoutController.orderType == 'dine_in' && checkoutController.selectedDineInDate == null){
      showCustomSnackBar('please_select_your_dine_in_date'.tr);
      return true;
    } else if(checkoutController.orderType == 'dine_in' && checkoutController.estimateDineInTime == null){
      showCustomSnackBar('please_select_your_dine_in_time'.tr);
      return true;
    } else if(((isGuestLogIn && checkoutController.orderType == 'take_away') || checkoutController.orderType == 'dine_in') && guestContactPersonNameController.text.isEmpty){
      showCustomSnackBar('please_enter_contact_person_name'.tr);
      return true;
    } else if(((isGuestLogIn && checkoutController.orderType == 'take_away') || checkoutController.orderType == 'dine_in') && guestContactPersonNumberController.text.isEmpty){
      showCustomSnackBar('please_enter_contact_person_number'.tr);
      return true;
    } else if(!(_isCashOnDeliveryActive ?? false) && !(_isDigitalPaymentActive ?? false) && !_isWalletActive) {
      showCustomSnackBar('no_payment_method_is_enabled'.tr);
      return true;
    } else if(!Get.find<SplashController>().configModel!.instantOrder! && !checkoutController.restaurant!.instantOrder! && checkoutController.restaurant!.scheduleOrder! && (checkoutController.preferableTime.isEmpty || checkoutController.preferableTime == 'Not Available')) {
      showCustomSnackBar('please_select_order_preference_time'.tr);
      return true;
    } else if(checkoutController.paymentMethodIndex == -1) {
      return true; // Already handled in _validateOrder
    } else if(checkoutController.subscriptionOrder && checkoutController.subscriptionRange == null) {
      showCustomSnackBar('select_a_date_range_for_subscription'.tr);
      return true;
    } else if(checkoutController.subscriptionOrder && !datePicked && checkoutController.subscriptionType == 'daily') {
      showCustomSnackBar('choose_time'.tr);
      return true;
    } else if(checkoutController.subscriptionOrder && !datePicked) {
      showCustomSnackBar('select_at_least_one_day_for_subscription'.tr);
      return true;
    } else if (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
      if(checkoutController.restaurant!.scheduleOrder! && !checkoutController.subscriptionOrder) {
        showCustomSnackBar('select_a_time'.tr);
      } else {
        showCustomSnackBar('restaurant_is_closed'.tr);
      }
      return true;
    } else if (!isAvailable && !checkoutController.subscriptionOrder) {
      showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
      return true;
    } else {
      return false;
    }
  }

  AddressModel? _processFinalAddress(bool isGuestLogIn) {
    CheckoutController checkoutController = Get.find<CheckoutController>();
    AddressModel? finalAddress = isGuestLogIn ? checkoutController.guestAddress : checkoutController.address[checkoutController.addressIndex];

    if(isGuestLogIn && checkoutController.orderType == 'take_away' || checkoutController.orderType == 'dine_in') {
      String number = (checkoutController.countryDialCode ?? '+1') + guestContactPersonNumberController.text;
      finalAddress = AddressModel(
        contactPersonName: guestContactPersonNameController.text, 
        contactPersonNumber: number,
        address: AddressHelper.getAddressFromSharedPref()!.address!, 
        latitude: AddressHelper.getAddressFromSharedPref()!.latitude,
        longitude: AddressHelper.getAddressFromSharedPref()!.longitude, 
        zoneId: AddressHelper.getAddressFromSharedPref()!.zoneId,
        email: guestEmailController.text,
      );
    }

    if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
      finalAddress.contactPersonNumber = Get.find<ProfileController>().userInfoModel!.phone ?? '';
    }
    return finalAddress;
  }

  List<place_order_model.OnlineCart> _generateOnlineCartList() {
    List<place_order_model.OnlineCart> carts = [];
    CartController cartController = Get.find<CartController>();
    
    for (int index = 0; index < cartController.cartList.length; index++) {
      CartModel cart = cartController.cartList[index];
      List<int?> addOnIdList = [];
      List<int?> addOnQtyList = [];
      List<place_order_model.OrderVariation> variations = [];
      List<int?> optionIds = [];
      
      for (var addOn in cart.addOnIds!) {
        addOnIdList.add(addOn.id);
        addOnQtyList.add(addOn.quantity);
      }
      
      if(cart.product!.variations != null){
        for(int i=0; i<cart.product!.variations!.length; i++) {
          if(cart.variations![i].contains(true)) {
            variations.add(place_order_model.OrderVariation(name: cart.product!.variations![i].name, values: place_order_model.OrderVariationValue(label: [])));
            for(int j=0; j<cart.product!.variations![i].variationValues!.length; j++) {
              if(cart.variations![i][j]!) {
                variations[variations.length-1].values!.label!.add(cart.product!.variations![i].variationValues![j].level);
                if(cart.product!.variations![i].variationValues![j].optionId != null) {
                  optionIds.add(cart.product!.variations![i].variationValues![j].optionId);
                }
              }
            }
          }
        }
      }
      
      carts.add(place_order_model.OnlineCart(
        cart.id, cart.product!.id, cart.isCampaign! ? cart.product!.id : null,
        cart.discountedPrice.toString(), variations,
        cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Food', 
        variationOptionIds: optionIds, 
        itemType: "AppModelsItemCampaign",
      ));
    }
    return carts;
  }

  List<place_order_model.SubscriptionDays> _generateSubscriptionDays() {
    List<place_order_model.SubscriptionDays> days = [];
    CheckoutController checkoutController = Get.find<CheckoutController>();
    
    for(int index=0; index<checkoutController.selectedDays.length; index++) {
      if(checkoutController.selectedDays[index] != null) {
        days.add(place_order_model.SubscriptionDays(
          day: checkoutController.subscriptionType == 'weekly' ? (index == 6 ? 0 : (index + 1)).toString()
              : checkoutController.subscriptionType == 'monthly' ? (index + 1).toString() : index.toString(),
          time: DateConverter.dateToTime(checkoutController.selectedDays[index]!),
        ));
      }
    }
    return days;
  }

  PlaceOrderBodyModel _preparePlaceOrderModel(List<place_order_model.OnlineCart> carts, DateTime scheduleStartDate, AddressModel? finalAddress, bool isGuestLogIn,
      List<place_order_model.SubscriptionDays> days) {
    CheckoutController checkoutController = Get.find<CheckoutController>();
    CouponController couponController = Get.find<CouponController>();
    CartController cartController = Get.find<CartController>();
    
    return PlaceOrderBodyModel(
      cart: carts, 
      couponDiscountAmount: couponController.discount, 
      distance: checkoutController.distance,
      couponDiscountTitle: couponController.discount! > 0 ? couponController.coupon!.title : null,
      scheduleAt: checkoutController.orderType == 'dine_in' ? checkoutController.orderPlaceDineInDateTime.toString()
          : !checkoutController.restaurant!.scheduleOrder! ? null : (checkoutController.selectedDateSlot == 0
          && checkoutController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleStartDate),
      orderAmount: cartController.subTotal, 
      orderNote: checkoutController.noteController.text, 
      orderType: checkoutController.orderType,
      paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
          : checkoutController.paymentMethodIndex == 1 ? 'wallet'
          : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
      couponCode: (couponController.discount! > 0 || (couponController.coupon != null
          && couponController.freeDelivery)) ? couponController.coupon!.code : null,
      restaurantId: cartController.cartList[0].product!.restaurantId,
      address: finalAddress!.address, 
      latitude: finalAddress.latitude, 
      longitude: finalAddress.longitude, 
      addressType: finalAddress.addressType,
      contactPersonName: finalAddress.contactPersonName ?? '${Get.find<ProfileController>().userInfoModel!.fName ?? ''} '
          '${Get.find<ProfileController>().userInfoModel!.lName ?? ''}',
      contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel!.phone ?? '',
      discountAmount: 0, // Will be calculated properly
      taxAmount: 0, // Will be calculated properly
      cutlery: cartController.addCutlery ? 1 : 0,
      road: isGuestLogIn ? finalAddress.road??'' : checkoutController.streetNumberController.text.trim(),
      house: isGuestLogIn ? finalAddress.house??'' : checkoutController.houseController.text.trim(),
      floor: isGuestLogIn ? finalAddress.floor??'' : checkoutController.floorController.text.trim(),
      dmTips: (checkoutController.orderType == 'take_away' || checkoutController.subscriptionOrder || checkoutController.selectedTips == 0) ? '' : checkoutController.tips.toString(),
      subscriptionOrder: checkoutController.subscriptionOrder ? '1' : '0',
      subscriptionType: checkoutController.subscriptionType, 
      subscriptionQuantity: '1', // Will be calculated properly
      subscriptionDays: days,
      subscriptionStartAt: checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(checkoutController.subscriptionRange!.start) : '',
      subscriptionEndAt: checkoutController.subscriptionOrder ? DateConverter.dateToDateAndTime(checkoutController.subscriptionRange!.end) : '',
      unavailableItemNote: cartController.notAvailableIndex != -1 ? cartController.notAvailableList[cartController.notAvailableIndex] : '',
      deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
      partialPayment: checkoutController.isPartialPay ? 1 : 0, 
      guestId: isGuestLogIn ? int.parse(Get.find<AuthController>().getGuestId()) : 0,
      isBuyNow: 0, 
      guestEmail: isGuestLogIn ? finalAddress.email : null,
      extraPackagingAmount: 0, // Will be calculated properly
    );
  }

  String _getCurrentAddressText(CheckoutController checkoutController) {
    bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
    
    if (isGuestLogIn) {
      if (checkoutController.guestAddress != null) {
        return checkoutController.guestAddress!.address ?? 'Tap to set delivery address';
      }
      return 'Tap to set delivery address';
    } else {
      // Check if address list is populated and index is valid
      if (checkoutController.address.isNotEmpty && 
          checkoutController.addressIndex >= 0 && 
          checkoutController.addressIndex < checkoutController.address.length) {
        String? addressText = checkoutController.address[checkoutController.addressIndex].address;
        if (addressText != null && addressText.isNotEmpty) {
          return addressText;
        }
      }
      
      // Fallback: Show default address from shared preferences if available
      AddressModel? defaultAddress = AddressHelper.getAddressFromSharedPref();
      if (defaultAddress != null && defaultAddress.address != null && defaultAddress.address!.isNotEmpty) {
        return defaultAddress.address!;
      }
      
      return 'Tap to set delivery address';
    }
  }

  void _showAddressSelectionDialog(CheckoutController checkoutController) {
    bool isGuestLogIn = Get.find<AuthController>().isGuestLoggedIn();
    
    if (isGuestLogIn) {
      // For guest users, navigate to add/edit address
      AddressModel? guestAddress = checkoutController.guestAddress ?? AddressHelper.getAddressFromSharedPref();
      Get.toNamed(RouteHelper.getEditAddressRoute(guestAddress, fromGuest: true))?.then((result) {
        // Handle the result when returning from edit address screen
        if (result != null && result is AddressModel) {
          checkoutController.setGuestAddress(result);
          // Calculate distance for the updated guest address
          if (checkoutController.restaurant != null && 
              result.latitude != null && 
              result.longitude != null &&
              checkoutController.restaurant!.latitude != null &&
              checkoutController.restaurant!.longitude != null) {
            checkoutController.getDistanceInKM(
              LatLng(double.parse(result.latitude!), double.parse(result.longitude!)),
              LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
            );
          }
        }
      });
    } else {
      // For logged-in users, show address selection dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: ResponsiveHelper.isDesktop(context) ? 500 : double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select Delivery Address',
                          style: robotoMedium.copyWith(
                            fontSize: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Address list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: checkoutController.address.length + 2, // +2 for "Add New" and "Use Current Location"
                      itemBuilder: (context, index) {
                        if (index == checkoutController.address.length) {
                          // Add new address option
                          return ListTile(
                            leading: Icon(
                              Icons.add_location,
                              color: Colors.orange,
                            ),
                            title: Text(
                              'Add New Address',
                              style: robotoMedium.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, checkoutController.restaurant!.zoneId));
                              if (address != null) {
                                // Insert the new address into checkout controller
                                checkoutController.insertAddresses(Get.context!, address, notify: true);
                                
                                // Set the address fields
                                checkoutController.streetNumberController.text = address.road ?? '';
                                checkoutController.houseController.text = address.house ?? '';
                                checkoutController.floorController.text = address.floor ?? '';
                                
                                // Calculate distance
                                if (address.latitude != null && 
                                    address.longitude != null &&
                                    checkoutController.restaurant!.latitude != null &&
                                    checkoutController.restaurant!.longitude != null) {
                                  checkoutController.getDistanceInKM(
                                    LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
                                    LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
                                  );
                                }
                                
                                // Set the address index to the newly added address (last index)
                                int newIndex = checkoutController.address.length - 1;
                                checkoutController.setAddressIndex(newIndex);
                                
                                // Update the address in shared preferences for future use
                                AddressHelper.saveAddressInSharedPref(address);
                              }
                            },
                          );
                        } else if (index == checkoutController.address.length + 1) {
                          // Use current location option
                          return ListTile(
                            leading: Icon(
                              Icons.my_location,
                              color: Colors.blue,
                            ),
                            title: Text(
                              'Use Current Location',
                              style: robotoMedium.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              _checkPermission(() async {
                                LocationController locationController = Get.find<LocationController>();
                                AddressModel addressModel = await locationController.getCurrentLocation(true, mapController: null, showSnackBar: true);
                                
                                if (addressModel.zoneIds!.isNotEmpty) {
                                  // Insert the current location address into checkout controller
                                  checkoutController.insertAddresses(Get.context!, addressModel, notify: true);
                                  
                                  // Set the address fields
                                  checkoutController.streetNumberController.text = addressModel.road ?? '';
                                  checkoutController.houseController.text = addressModel.house ?? '';
                                  checkoutController.floorController.text = addressModel.floor ?? '';
                                  
                                  // Calculate distance
                                  if (checkoutController.restaurant!.latitude != null &&
                                      checkoutController.restaurant!.longitude != null) {
                                    checkoutController.getDistanceInKM(
                                      LatLng(locationController.position.latitude, locationController.position.longitude),
                                      LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
                                    );
                                  }
                                  
                                  // Set the address index to the newly added address (last index)
                                  int newIndex = checkoutController.address.length - 1;
                                  checkoutController.setAddressIndex(newIndex);
                                  
                                  // Update the address in shared preferences for future use
                                  AddressHelper.saveAddressInSharedPref(addressModel);
                                }
                              });
                            },
                          );
                        } else {
                          // Existing address
                          var address = checkoutController.address[index];
                          bool isSelected = checkoutController.addressIndex == index;
                          
                          return ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: isSelected ? Colors.orange : Theme.of(context).disabledColor,
                            ),
                            title: Text(
                              address.address ?? 'Address',
                              style: robotoMedium.copyWith(
                                color: isSelected ? Colors.orange : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${address.contactPersonName ?? ''} • ${address.contactPersonNumber ?? ''}',
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            trailing: isSelected ? Icon(
                              Icons.check_circle,
                              color: Colors.orange,
                            ) : null,
                            onTap: () {
                              // Calculate distance
                              if (address.latitude != null && 
                                  address.longitude != null &&
                                  checkoutController.restaurant!.latitude != null &&
                                  checkoutController.restaurant!.longitude != null) {
                                checkoutController.getDistanceInKM(
                                  LatLng(double.parse(address.latitude!), double.parse(address.longitude!)),
                                  LatLng(double.parse(checkoutController.restaurant!.latitude!), double.parse(checkoutController.restaurant!.longitude!)),
                                );
                              }
                              
                              checkoutController.setAddressIndex(index);
                              checkoutController.streetNumberController.text = address.road ?? '';
                              checkoutController.houseController.text = address.house ?? '';
                              checkoutController.floorController.text = address.floor ?? '';
                              
                              // Update the address in shared preferences for future use
                              AddressHelper.saveAddressInSharedPref(address);
                              
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _checkPermission(VoidCallback onTap) {
    LocationController locationController = Get.find<LocationController>();
    locationController.checkPermission(onTap);
  }

}