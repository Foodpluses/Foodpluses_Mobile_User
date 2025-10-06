import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/restaurant/widgets/restaurant_food_item_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantProductViewWidget extends StatelessWidget {
  final List<Product?>? products;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;

  const RestaurantProductViewWidget({
    super.key,
    required this.products,
    this.isScrollable = false,
    this.shimmerLength = 20,
    this.padding = const EdgeInsets.all(Dimensions.paddingSizeSmall),
    this.noDataText,
  });

  @override
  Widget build(BuildContext context) {
    bool isNull = products == null;
    int length = 0;
    if (!isNull) {
      length = products!.length;
    }

    return Column(children: [
      !isNull ? length > 0 ? ListView.builder(
        key: UniqueKey(),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: length,
        padding: padding,
        itemBuilder: (context, index) {
          if (products![index] == null) return const SizedBox();
          return RestaurantFoodItemWidget(
            product: products![index]!,
            index: index,
            length: length,
          );
        },
      ) : NoDataScreen(
        isEmptyRestaurant: false,
        isEmptyWishlist: false,
        isEmptySearchFood: true,
        title: noDataText ?? 'there_is_no_food'.tr,
      ) : ListView.builder(
        key: UniqueKey(),
        physics: isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: shimmerLength,
        padding: padding,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ]);
  }
}
