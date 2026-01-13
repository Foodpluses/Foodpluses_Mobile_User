import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/coupon/controllers/coupon_controller.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_info_section_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_screen_shimmer_widget.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/bottom_cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_product_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/veg_filter_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_menu_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  final String slug;
  final bool fromDineIn;
  const RestaurantScreen({super.key, required this.restaurant, this.slug = '', this.fromDineIn = false});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _initDataCall();
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  Future<void> _initDataCall() async {
    if(Get.find<RestaurantController>().isSearching) {
      Get.find<RestaurantController>().changeSearchStatus(isUpdate: false);
    }
    await Get.find<RestaurantController>().getRestaurantDetails(Restaurant(id: widget.restaurant!.id), slug: widget.slug);
    if(Get.find<CategoryController>().categoryList == null) {
      Get.find<CategoryController>().getCategoryList(true);
    }
    Get.find<CouponController>().getRestaurantCouponList(restaurantId: widget.restaurant!.id ?? Get.find<RestaurantController>().restaurant!.id!);
    Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurant!.id ?? Get.find<RestaurantController>().restaurant!.id!, false);
    Get.find<RestaurantController>().getRestaurantProductList(widget.restaurant!.id ?? Get.find<RestaurantController>().restaurant!.id!, 1, 'all', false);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      appBar: isDesktop ? WebMenuBar(fromDineIn: widget.fromDineIn) : null,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<RestaurantController>(builder: (restController) {
        return GetBuilder<CouponController>(builder: (couponController) {
          return GetBuilder<CategoryController>(builder: (categoryController) {
            Restaurant? restaurant;
            if (restController.restaurant != null && restController.restaurant!.name != null &&
                categoryController.categoryList != null) {
              restaurant = restController.restaurant;
            }
            restController.setCategoryList();
            bool hasCoupon = (couponController.couponList!= null && couponController.couponList!.isNotEmpty);

            return (restController.restaurant != null && restController.restaurant!.name != null && categoryController.categoryList != null) ? CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              slivers: [

                // Simple header without animation - matching screenshot style
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 50,
                  expandedHeight: 50,
                  floating: false,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  leading: !isDesktop ? IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
                    onPressed: () => Get.back(),
                    padding: const EdgeInsets.all(8),
                  ) : const SizedBox(),
                  title: Text(
                    restaurant!.name!,
                    style: robotoMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: false,
                  actions: [
                    // Share, Favorite, Search icons - compact
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.grey.shade600, size: 20),
                          onPressed: () {},
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite_border, color: Colors.grey.shade600, size: 20),
                          onPressed: () {},
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                          onPressed: () {},
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ],
                ),

                // Rating and hours section
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant!.avgRating!.toStringAsFixed(1)} (${restaurant!.ratingCount})',
                            style: robotoMedium.copyWith(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Open until 11:00 pm',
                            style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Restaurant details section with icons - matching screenshot
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Preparation time
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.access_time, size: 20, color: const Color(0xFFCF0F14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '18 - 28 min',
                                    style: robotoMedium.copyWith(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Prep time',
                                    style: robotoRegular.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delivery fee
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.local_shipping, size: 20, color: const Color(0xFF6BBD07)),
                                  const SizedBox(height: 4),
                                  Text(
                                    PriceConverter.convertPrice(Get.find<RestaurantController>().calculateDeliveryFee(restaurant!)),
                                    style: robotoMedium.copyWith(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Delivery fee',
                                    style: robotoRegular.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Available delivery type
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.flash_on, size: 20, color: const Color(0xFFCF0F14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Instant',
                                    style: robotoMedium.copyWith(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Delivery',
                                    style: robotoRegular.copyWith(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category filter bar - matching screenshot style
                (restController.categoryList!.isNotEmpty) ? SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 28,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: restController.categoryList!.length,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => restController.setCategoryIndex(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: index == restController.categoryIndex ? const Color(0xFFCF0F14) : Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    restController.categoryList![index].name!,
                                    style: index == restController.categoryIndex 
                                        ? robotoMedium.copyWith(
                                            fontSize: 12, 
                                            color: Colors.white,
                                          ) 
                                        : robotoRegular.copyWith(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ) : const SliverToBoxAdapter(child: SizedBox()),

                // Food items section - matching screenshot style
                SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      width: Dimensions.webMaxWidth,
                      color: Colors.white,
                      child: PaginatedListViewWidget(
                        scrollController: scrollController,
                        onPaginate: (int? offset) {
                          if (restController.isSearching) {
                            restController.getRestaurantSearchProductList(
                              restController.searchText, Get.find<RestaurantController>().restaurant!.id.toString(), offset!, restController.type,
                            );
                          } else {
                            restController.getRestaurantProductList(Get.find<RestaurantController>().restaurant!.id, offset!, restController.type, false);
                          }
                        },
                        totalSize: restController.isSearching ? restController.restaurantSearchProductModel?.totalSize : restController.restaurantProducts != null ? restController.foodPageSize : null,
                        offset: restController.isSearching ? restController.restaurantSearchProductModel?.offset : restController.restaurantProducts != null ? restController.foodPageOffset : null,
                        productView: RestaurantProductViewWidget(
                          products: restController.isSearching ? restController.restaurantSearchProductModel?.products : restController.categoryList!.isNotEmpty ? restController.restaurantProducts : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ) : const RestaurantScreenShimmerWidget();
          });
        });
      }),

      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !isDesktop ? BottomCartWidget(restaurantId: cartController.cartList[0].product!.restaurantId!, fromDineIn: widget.fromDineIn) : const SizedBox();
        })
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

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

// class CategoryProduct {
//   CategoryModel category;
//   List<Product> products;
//   CategoryProduct(this.category, this.products);
// }
