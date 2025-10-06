import 'package:flutter/rendering.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/dine_in/controllers/dine_in_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
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
      await Get.find<ProfileController>().getUserInfo();
      Get.find<RestaurantController>().getRecentlyViewedRestaurantList(reload, 'all', false);
      Get.find<RestaurantController>().getOrderAgainRestaurantList(reload);
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      Get.find<AddressController>().getAddressList();
      Get.find<HomeController>().getCashBackOfferList();
    }
  }


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  bool _isLogin = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();
    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if((Get.find<ProfileController>().userInfoModel?.isValidForDiscount ?? false) && Get.find<SplashController>().showReferBottomSheet) {
        Future.delayed(const Duration(milliseconds: 500), () => _showReferBottomSheet());
      }

    });

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
    _scrollController.dispose();
    super.dispose();
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
                  await Get.find<ProfileController>().getUserInfo();
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
                                  color: Colors.orange.shade600,
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
                        // Popular Restaurants moved up for better order-oriented navigation
                        _configModel?.popularRestaurant == 1 ? const PopularRestaurantsViewWidget() : const SizedBox(),
                      ]),
                    )),
                  ),
                  
                  SliverToBoxAdapter(
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const BannerViewWidget(),
                        const WhatOnYourMindViewWidget(),
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
