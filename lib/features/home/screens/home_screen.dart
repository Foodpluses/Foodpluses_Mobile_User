import 'package:flutter/rendering.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_dialog_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cashback_logo_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/dine_in_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/web_home_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurant_filter_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/all_restaurants_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/discount_restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/top_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/advertisement_modal_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/best_review_item_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/enjoy_off_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/location_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/new_on_stackfood_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/order_again_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_foods_nearby_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/popular_restaurants_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/home/screens/theme1_home_screen.dart';
import 'package:stackfood_multivendor/features/home/widgets/today_trends_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/what_on_your_mind_view_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/common/widgets/customizable_space_bar_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:stackfood_multivendor/common/enums/data_source_enum.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  static Future<void> loadData(bool reload) async {
    Get.find<HomeController>().getBannerList(reload);
    Get.find<CategoryController>().getCategoryList(reload);
    Get.find<CuisineController>().getCuisineList();
    Get.find<AdvertisementController>().getAdvertisementList();
    Get.find<DineInController>().getDineInRestaurantList(1, reload);
    if(Get.find<SplashController>().configModel!.popularRestaurant == 1) {
      Get.find<RestaurantController>().getPopularRestaurantList(reload, 'all', false);
    }
    Get.find<CampaignController>().getItemCampaignList(reload);
    if(Get.find<SplashController>().configModel!.popularFood == 1) {
      Get.find<ProductController>().getPopularProductList(reload, 'all', false);
    }
    if(Get.find<SplashController>().configModel!.newRestaurant == 1) {
      Get.find<RestaurantController>().getLatestRestaurantList(reload, 'all', false);
    }
    if(Get.find<SplashController>().configModel!.mostReviewedFoods == 1) {
      Get.find<ReviewController>().getReviewedProductList(reload, 'all', false);
    }
    Get.find<RestaurantController>().getRestaurantList(1, reload);
      if(Get.find<AuthController>().isLoggedIn()) {
        // Only call getUserInfo if token exists to prevent null Bearer token
        final token = Get.find<ApiClient>().sharedPreferences.getString(AppConstants.token);
        if(token != null && token.isNotEmpty) {
          await Get.find<ProfileController>().getUserInfo();
        }
        Get.find<RestaurantController>().getRecentlyViewedRestaurantList(reload, 'all', false);
        Get.find<RestaurantController>().getOrderAgainRestaurantList(reload);
        Get.find<NotificationController>().getNotificationList(reload);
        Get.find<OrderController>().getRunningOrders(1, notify: false);
        Get.find<AddressController>().getAddressList();
        Get.find<HomeController>().getCashBackOfferList();
      }
    // Preload discounted restaurants
    Get.find<RestaurantController>().getDiscountedRestaurantList(reload, 'all', false);
  }


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {

  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  bool _isLogin = false;
  Timer? _refreshTimer;
  Timer? _locationCheckTimer;
  String? _lastAddressKey;
  bool _hasShownAdModal = false;
  bool _isRefreshing = false;
  DateTime? _lastRefreshTime;
  bool _isScreenVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _isLogin = Get.find<AuthController>().isLoggedIn();
    _lastAddressKey = _getAddressKey();
    
    // Initial data load
    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ?? false) && Get.find<SplashController>().showReferBottomSheet) {
        Future.delayed(const Duration(milliseconds: 500), () => _showReferBottomSheet());
      }
      
      // Show advertisement modal once per session
      _checkAndShowAdvertisementModal();
    });

    // Set up auto-refresh timer (every 30 seconds) - but with debouncing
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _isRefreshing || !_isScreenVisible) {
        return;
      }
      
      // Check if we're still on home screen before refreshing
      if (!_isOnHomeScreen()) {
        // Not on home screen, cancel timer
        timer.cancel();
        return;
      }
      
      _refreshHomeData();
    });

    // Listen for location changes
    _listenForLocationChanges();

    _scrollController.addListener(() {
      if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), ()=> Get.find<HomeController>().changeFavVisibility());
        }
      }else {
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), ()=> Get.find<HomeController>().changeFavVisibility());
        }
      }
    });

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _locationCheckTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isScreenVisible = state == AppLifecycleState.resumed;
    
    // Pause timers when app goes to background or screen is not visible
    if (state != AppLifecycleState.resumed) {
      _refreshTimer?.cancel();
      _locationCheckTimer?.cancel();
    } else {
      // Resume timers when app comes back to foreground - but only if on home screen
      if (_isOnHomeScreen()) {
        _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
          if (!mounted || _isRefreshing || !_isScreenVisible) {
            return;
          }
          if (!_isOnHomeScreen()) {
            timer.cancel();
            return;
          }
          _refreshHomeData();
        });
        _listenForLocationChanges();
      }
    }
  }
  
  // Removed didChangeDependencies - it was causing navigation issues on Samsung devices
  // Route checking is now handled in didChangeAppLifecycleState and timer callbacks
  
  /// Helper method to safely check if we're on the home screen
  bool _isOnHomeScreen() {
    try {
      final currentRoute = Get.currentRoute.split('?').first;
      return currentRoute == RouteHelper.initial || currentRoute == '/';
    } catch (e) {
      // If route checking fails, assume we're not on home screen to be safe
      return false;
    }
  }

  String? _getAddressKey() {
    final address = AddressHelper.getAddressFromSharedPref();
    if (address != null) {
      return '${address.latitude}_${address.longitude}_${address.zoneIds?.join(",")}';
    }
    return null;
  }

  void _listenForLocationChanges() {
    // Cancel existing timer if any
    _locationCheckTimer?.cancel();
    
    // Check for address changes periodically (less frequently to reduce API calls)
    _locationCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_isScreenVisible) {
        timer.cancel();
        return;
      }
      
      // Only check if we're on the home screen route
      if (!_isOnHomeScreen()) {
        timer.cancel();
        return;
      }
      
      final currentAddressKey = _getAddressKey();
      if (currentAddressKey != null && currentAddressKey != _lastAddressKey && _lastAddressKey != null) {
        _lastAddressKey = currentAddressKey;
        // Location changed - trigger full refresh (only if we had a previous location)
        _fullRefresh();
      } else if (currentAddressKey != null && _lastAddressKey == null) {
        // First time setting the address key
        _lastAddressKey = currentAddressKey;
      }
    });
  }

  void _refreshHomeData() {
    // Don't refresh if screen is not visible or not on home screen
    if (!_isScreenVisible) {
      return;
    }
    
    // Check if we're actually on the home screen route
    if (!_isOnHomeScreen()) {
      return;
    }
    
    // Prevent multiple simultaneous refresh calls
    if (_isRefreshing) {
      return;
    }
    
    // Prevent refresh if last refresh was less than 25 seconds ago (debounce)
    if (_lastRefreshTime != null && 
        DateTime.now().difference(_lastRefreshTime!).inSeconds < 25) {
      return;
    }
    
    _isRefreshing = true;
    _lastRefreshTime = DateTime.now();
    
    // Background refresh - fetch new data without clearing existing data (no shimmer)
    // Use reload: false to prevent clearing data, fromRecall: true to force fetch, and client source to skip cache
    try {
      Get.find<HomeController>().getBannerList(false, dataSource: DataSourceEnum.client, fromRecall: true);
      Get.find<CategoryController>().getCategoryList(false);
      Get.find<CuisineController>().getCuisineList();
      Get.find<AdvertisementController>().getAdvertisementList();
      Get.find<DineInController>().getDineInRestaurantList(1, false);
      if(Get.find<SplashController>().configModel!.popularRestaurant == 1) {
        Get.find<RestaurantController>().getPopularRestaurantList(false, 'all', false, dataSource: DataSourceEnum.client, fromRecall: true);
      }
      Get.find<CampaignController>().getItemCampaignList(false);
      if(Get.find<SplashController>().configModel!.popularFood == 1) {
        Get.find<ProductController>().getPopularProductList(false, 'all', false, dataSource: DataSourceEnum.client, fromRecall: true);
      }
      if(Get.find<SplashController>().configModel!.newRestaurant == 1) {
        Get.find<RestaurantController>().getLatestRestaurantList(false, 'all', false, dataSource: DataSourceEnum.client, fromRecall: true);
      }
      if(Get.find<SplashController>().configModel!.mostReviewedFoods == 1) {
        Get.find<ReviewController>().getReviewedProductList(false, 'all', false, dataSource: DataSourceEnum.client, fromRecall: true);
      }
      // For getRestaurantList, fetch directly from client without clearing (reload: false)
      Get.find<RestaurantController>().getRestaurantList(1, false, source: DataSourceEnum.client);
      Get.find<RestaurantController>().getDiscountedRestaurantList(false, 'all', false, dataSource: DataSourceEnum.client, fromRecall: true);
      
      if(Get.find<AuthController>().isLoggedIn()) {
        // Only call getUserInfo if token exists to prevent null Bearer token
        final token = Get.find<ApiClient>().sharedPreferences.getString(AppConstants.token);
        if(token != null && token.isNotEmpty) {
          Get.find<ProfileController>().getUserInfo();
        }
        Get.find<RestaurantController>().getRecentlyViewedRestaurantList(false, 'all', false, dataSource: DataSourceEnum.client, fromRecall: true);
        Get.find<RestaurantController>().getOrderAgainRestaurantList(false);
        Get.find<NotificationController>().getNotificationList(false);
        Get.find<OrderController>().getRunningOrders(1, notify: false);
        Get.find<AddressController>().getAddressList();
        Get.find<HomeController>().getCashBackOfferList();
      }
    } finally {
      // Reset flag after a delay to allow API calls to complete
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _isRefreshing = false;
        }
      });
    }
  }

  void _fullRefresh() {
    // Only refresh if we're on the home screen
    if (!_isOnHomeScreen()) {
      return;
    }
    
    // Full refresh when location changes - reload everything
    HomeScreen.loadData(true);
  }

  void _checkAndShowAdvertisementModal() {
    // Only show once per app session
    if (_hasShownAdModal) return;
    
    final advertisementController = Get.find<AdvertisementController>();
    if (advertisementController.advertisementList != null && 
        advertisementController.advertisementList!.isNotEmpty) {
      // Get the first valid advertisement
      final advertisement = advertisementController.advertisementList!.first;
      
      // Show modal after a short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_hasShownAdModal) {
          _hasShownAdModal = true;
          _showAdvertisementModal(advertisement);
        }
      });
    }
  }

  void _showAdvertisementModal(AdvertisementModel advertisement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => AdvertisementModalWidget(
        advertisement: advertisement,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context) ? Get.dialog(Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: const ReferBottomSheetWidget(),
    ),
      useSafeArea: false,
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false)) : showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }


  @override
  Widget build(BuildContext context) {

    double scrollPoint = 0.0;

    return GetBuilder<HomeController>(builder: (homeController) {
      return GetBuilder<LocalizationController>(builder: (localizationController) {
        return Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
          backgroundColor: Colors.white,
          body: SafeArea(
            top: (Get.find<SplashController>().configModel!.theme == 2),
            child: RefreshIndicator(
              onRefresh: () async {
                await Get.find<HomeController>().getBannerList(true);
                await Get.find<CategoryController>().getCategoryList(true);
                await Get.find<CuisineController>().getCuisineList();
                Get.find<AdvertisementController>().getAdvertisementList();
                await Get.find<RestaurantController>().getPopularRestaurantList(true, 'all', false);
                await Get.find<CampaignController>().getItemCampaignList(true);
                await Get.find<ProductController>().getPopularProductList(true, 'all', false);
                await Get.find<RestaurantController>().getLatestRestaurantList(true, 'all', false);
                await Get.find<ReviewController>().getReviewedProductList(true, 'all', false);
                await Get.find<RestaurantController>().getRestaurantList(1, true);
                if(Get.find<AuthController>().isLoggedIn()) {
                  // Only call getUserInfo if token exists to prevent null Bearer token
                  final token = Get.find<ApiClient>().sharedPreferences.getString(AppConstants.token);
                  if(token != null && token.isNotEmpty) {
                    await Get.find<ProfileController>().getUserInfo();
                  }
                  await Get.find<NotificationController>().getNotificationList(true);
                  await Get.find<RestaurantController>().getRecentlyViewedRestaurantList(true, 'all', false);
                  await Get.find<RestaurantController>().getOrderAgainRestaurantList(true);

                }
              },
              child: ResponsiveHelper.isDesktop(context) ? WebHomeScreen(
                scrollController: _scrollController,
              ) : (Get.find<SplashController>().configModel!.theme == 2) ? Theme1HomeScreen(
                scrollController: _scrollController,
              ) : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

                  /// App Bar - Compact & Modern
                  SliverAppBar(
                    pinned: true, 
                    toolbarHeight: 60, 
                    expandedHeight: 60,
                    floating: false, 
                    elevation: 0,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.zero,
                      centerTitle: true,
                      expandedTitleScale: 1,
                      title: Container(
                        width: Dimensions.webMaxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            // Compact Search Bar (for location)
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.green.shade600,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          AddressHelper.getAddressFromSharedPref()!.address!,
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey.shade700,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.grey.shade500,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Filter Button (for restaurant search)
                            InkWell(
                              onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6BBD07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Search',
                                      style: robotoMedium.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Notification Icon
                            InkWell(
                              onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                              borderRadius: BorderRadius.circular(8),
                              child: GetBuilder<NotificationController>(builder: (notificationController) {
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Stack(
                                    children: [
                                      Icon(
                                        Icons.notifications_outlined, 
                                        size: 18, 
                                        color: Colors.grey.shade600,
                                      ),
                                      if (notificationController.hasNotification)
                                        Positioned(
                                          top: -2, 
                                          right: -2, 
                                          child: Container(
                                            height: 8, 
                                            width: 8, 
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade500, 
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: const [SizedBox()],
                  ),

                  // Break down the content into multiple SliverToBoxAdapter widgets to prevent overflow
                  SliverToBoxAdapter(
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const BadWeatherWidget(),
                        // Top Banner - Auto-slide banner at the top
                        const TopBannerViewWidget(),
                        // What's on your mind section - moved under banner, cleaner design
                        const WhatOnYourMindViewWidget(),
                        // Popular Restaurants - cleaner, smaller cards
                        _configModel?.popularRestaurant == 1 ? const PopularRestaurantsViewWidget() : const SizedBox(),
                        // Enhanced divider / promo strip
                        // const SizedBox(height: 4),
                        // Container(
                        //   height: 56,
                        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        //   margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(12),
                        //     gradient: LinearGradient(
                        //       colors: [const Color(0xFFFF0000).withOpacity(0.1), Colors.white],
                        //       begin: Alignment.topLeft,
                        //       end: Alignment.bottomRight,
                        //     ),
                        //     border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.2)),
                        //   ),
                        //   child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        //     // Badge
                        //     Container(
                        //       height: 28, width: 28,
                        //       decoration: BoxDecoration(
                        //         shape: BoxShape.circle,
                        //         gradient: LinearGradient(colors: [const Color(0xFFFF0000), const Color(0xFFFF3333)]),
                        //         boxShadow: [BoxShadow(color: const Color(0xFFFF0000).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))],
                        //       ),
                        //       child: const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                        //     ),
                        //     const SizedBox(width: 10),
                        //     // Title + tags
                        //     Expanded(
                        //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                        //         Text('Handpicked deals near you', maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(fontSize: 10, height: 1.0, color: const Color(0xFFFF0000))),
                        //         const SizedBox(height: 3),
                        //         SizedBox(
                        //           height: 20,
                        //           child: SingleChildScrollView(
                        //             scrollDirection: Axis.horizontal,
                        //             physics: const BouncingScrollPhysics(),
                        //             child: Row(children: [
                        //               _DealChip(label: 'Limited-time', icon: Icons.timer, color: Colors.orange.shade700),
                        //               _DealChip(label: 'Free delivery', icon: Icons.local_shipping, color: Colors.green.shade700),
                        //               _DealChip(label: 'Under ₦1000', icon: Icons.payments, color: Colors.indigo.shade700),
                        //               _DealChip(label: 'Buy 1 Get 1', icon: Icons.redeem, color: Colors.purple.shade700),
                        //               _DealChip(label: '10km radius', icon: Icons.radar, color: Colors.teal.shade700),
                        //             ]),
                        //           ),
                        //         ),
                        //       ]),
                        //     ),
                        //     const SizedBox(width: 8),
                        //     // CTA
                        //     Align(
                        //       alignment: Alignment.centerRight,
                        //       child: FittedBox(
                        //         child: InkWell(
                        //           onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute('discounted')),
                        //           borderRadius: BorderRadius.circular(8),
                        //           child: Container(
                        //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        //             decoration: BoxDecoration(
                        //               color: const Color(0xFFFF0000),
                        //               borderRadius: BorderRadius.circular(8),
                        //               boxShadow: [BoxShadow(color: const Color(0xFFFF0000).withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
                        //             ),
                        //             child: Text('View all', style: robotoMedium.copyWith(fontSize: 11, color: Colors.white)),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ]),
                        // ),
                        // Discounts section
                        const DiscountRestaurantsViewWidget(),
                      ]),
                    )),
                  ),
                  
                  SliverToBoxAdapter(
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Original banner slider (keeping it as requested)
                        const BannerViewWidget(),
                        _isLogin ? const OrderAgainViewWidget() : const SizedBox(),
                        const TodayTrendsViewWidget(),
                        // All Restaurants section moved back to original position
                        const AllRestaurantFilterWidget(),
                        AllRestaurantsWidget(scrollController: _scrollController),
                      ]),
                    )),
                  ),
                  
                  // SliverToBoxAdapter(
                  //   child: Center(child: SizedBox(
                  //     width: Dimensions.webMaxWidth,
                  //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //       const LocationBannerViewWidget(),
                  //       const HighlightWidgetView(),
                  //       _configModel!.mostReviewedFoods == 1 ?  const BestReviewItemViewWidget(isPopular: false) : const SizedBox(),
                  //       _configModel.dineInOrderOption! ? DineInWidget() : const SizedBox(),
                  //     ]),
                  //   )),
                  // ),
                  
                  // SliverToBoxAdapter(
                  //   child: Center(child: SizedBox(
                  //     width: Dimensions.webMaxWidth,
                  //     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //       const CuisineViewWidget(),
                  //       const ReferBannerViewWidget(),
                  //       _isLogin ? const PopularRestaurantsViewWidget(isRecentlyViewed: true) : const SizedBox(),
                  //       _configModel.popularFood == 1 ? const PopularFoodNearbyViewWidget() : const SizedBox(),
                  //       _configModel.newRestaurant == 1 ? const NewOnStackFoodViewWidget(isLatest: true) : const SizedBox(),
                  //       const PromotionalBannerViewWidget(),
                  //     ]),
                  //   )),
                  // ),

                  // SliverToBoxAdapter(child: Center(child: FooterViewWidget(
                  //   child: Container(),
                  // ))),

                ],
              ),
            ),
          ),

          floatingActionButton: AuthHelper.isLoggedIn() && homeController.cashBackOfferList != null && homeController.cashBackOfferList!.isNotEmpty ?
          homeController.showFavButton ? Padding(

            padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 50 : 0, right: ResponsiveHelper.isDesktop(context) ? 20 : 0),
            child: InkWell(
              onTap: () => Get.dialog(const CashBackDialogWidget()),
              child: const CashBackLogoWidget(),
            ),
          ) : null : null,

        );
      });
    });
  }
}

class _DealChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _DealChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: robotoMedium.copyWith(fontSize: 10, height: 1.0, color: color), maxLines: 1, overflow: TextOverflow.clip),
      ]),
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}
