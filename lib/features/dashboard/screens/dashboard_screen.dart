import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:stackfood_multivendor/features/cart/screens/cart_screen.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/registration_success_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/menu/screens/menu_screen.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/screens/order_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/bottom_nav_item.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/running_order_view_widget.dart';
import 'package:stackfood_multivendor/features/favourite/screens/favourite_screen.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dialog_widget.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen({super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();

    _showRegistrationSuccessBottomSheet();

    if(_isLogin){
      if(Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && Get.find<LoyaltyController>().getEarningPint().isNotEmpty && !ResponsiveHelper.isDesktop(Get.context)){
        Future.delayed(const Duration(seconds: 1), () => showAnimatedDialog(Get.context!, const CongratulationDialogue()));
      }
      _suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, notify: false);
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const FavouriteScreen(), // This will be replaced with Search functionality
      const CartScreen(fromNav: true),
      const OrderScreen(),
      const MenuScreen()
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });

  }

  _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet = Get.find<DashboardController>().getRegistrationSuccessfulSharedPref();
    if(canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context) ? Get.dialog(const Dialog(child: RegistrationSuccessBottomSheet())).then((value) {
          Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(false);
          setState(() {});
        }) : showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const RegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(false);
          setState(() {});
        });
      });
    }
  }

  Future<void> _suggestAddressBottomSheet() async {
    active = await Get.find<DashboardController>().checkLocationActive();
    if(widget.fromSplash && Get.find<DashboardController>().showLocationSuggestion && active){
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheet(),
        ).then((value) {
          Get.find<DashboardController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        debugPrint('$_canExit');
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if(_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          if(!ResponsiveHelper.isDesktop(context)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
          }
          _canExit = true;

          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,


        bottomNavigationBar: ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Home
                      BottomNavItem(
                        iconData: Icons.home_rounded,
                        label: 'Home',
                        isSelected: _pageIndex == 0,
                        onTap: () => _setPage(0),
                      ),
                      
                      // Search
                      BottomNavItem(
                        iconData: Icons.search_rounded,
                        label: 'Search',
                        isSelected: _pageIndex == 1,
                        onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                      ),
                      
                      // Orders with notification badge
                      GetBuilder<OrderController>(builder: (orderController) {
                        Widget? badge;
                        if (_isLogin && orderController.runningOrderList != null && orderController.runningOrderList!.isNotEmpty) {
                          int orderCount = orderController.runningOrderList!.length;
                          badge = Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 16),
                              height: 18,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  orderCount > 9 ? '9+' : orderCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return BottomNavItem(
                          iconData: Icons.receipt_long_rounded,
                          label: 'Orders',
                          isSelected: _pageIndex == 3,
                          onTap: () => _setPage(3),
                          badge: badge,
                        );
                      }),
                      
                      // Support (Live Chat)
                      BottomNavItem(
                        iconData: Icons.chat_bubble_outline_rounded,
                        label: 'Support',
                        isSelected: false, // Support doesn't have a page index since it navigates away
                        onTap: () => Get.toNamed(RouteHelper.getConversationRoute()),
                      ),
                      
                      // Profile (Menu)
                      GetBuilder<ProfileController>(builder: (profileController) {
                        return BottomNavItem(
                          iconData: Icons.account_circle_rounded,
                          label: 'Profile',
                          isSelected: _pageIndex == 4,
                          onTap: () => _setPage(4),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
        body: GetBuilder<OrderController>(
          builder: (orderController) {
            return PageView.builder(
              controller: _pageController,
              itemCount: _screens.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _screens[index];
              },
            );
          }
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
