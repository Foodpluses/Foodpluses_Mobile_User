import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/screens/order_details_screen.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderViewWidget extends StatelessWidget {
  final bool isRunning;
  final bool isSubscription;
  const OrderViewWidget({super.key, required this.isRunning, this.isSubscription = false});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<OrderController>(builder: (orderController) {
        List<OrderModel>? orderList;
        bool paginate = false;
        int pageSize = 1;
        int offset = 1;
        if(orderController.runningOrderList != null && orderController.historyOrderList != null) {
          orderList = isSubscription ? orderController.runningSubscriptionOrderList : isRunning ? orderController.runningOrderList : orderController.historyOrderList;
          paginate = isSubscription ? orderController.runningSubscriptionPaginate : isRunning ? orderController.runningPaginate : orderController.historyPaginate;
          pageSize = isSubscription ? (orderController.runningSubscriptionPageSize!/10).ceil() : isRunning ? (orderController.runningPageSize!/10).ceil() : (orderController.historyPageSize!/10).ceil();
          offset = isSubscription ? orderController.runningSubscriptionOffset : isRunning ? orderController.runningOffset : orderController.historyOffset;
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent && orderList != null && !paginate) {
            if (offset < pageSize) {
              Get.find<OrderController>().setOffset(offset + 1, isRunning, isSubscription);
              debugPrint('end of the page');
              Get.find<OrderController>().showBottomLoader(isRunning, isSubscription);
              if(isRunning) {
                Get.find<OrderController>().getRunningOrders(offset+1, limit: 10);
              } else if(isSubscription){
                Get.find<OrderController>().getRunningSubscriptionOrders(offset+1);
              }
              else {
                Get.find<OrderController>().getHistoryOrders(offset+1);
              }
            }
          }
        });

        return orderList != null ? orderList.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isRunning) {
              await orderController.getRunningOrders(1);
            }else {
              await orderController.getHistoryOrders(1);
            }
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(child: FooterViewWidget(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  children: [
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeLarge,
                        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                        mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 160 : 140,
                      ),
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemCount: orderList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {

                        return Container(
                          
                            decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(
                                  RouteHelper.getOrderDetailsRoute(orderList![index].id),
                                  arguments: OrderDetailsScreen(orderId: orderList[index].id, orderModel: orderList[index]),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Top Row - Order ID and Status
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order #${orderList?[index].id}',
                                          style: robotoBold.copyWith(
                                            fontSize: 14,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            String? status = orderList![index].orderStatus;
                                            bool isDineIn = orderList[index].orderType == 'dine_in';
                                            if(isDineIn) {
                                              status = orderList[index].orderStatus == 'processing' ? 'cooking'.tr
                                                  : orderList[index].orderStatus == 'handover' ? 'ready_to_serve'.tr
                                                  : orderList[index].orderStatus == 'pending' ? 'pending'.tr
                                                  : orderList[index].orderStatus == 'canceled' ? 'canceled'.tr
                                                  : orderList[index].orderStatus == 'confirmed' ? 'confirmed'.tr
                                                  : 'served'.tr;
                                            }
                                            
                                            Color statusColor;
                                            if (orderList[index].orderStatus == 'pending' || orderList[index].orderStatus == 'processing') {
                                              statusColor = Colors.orange;
                                            } else if (orderList[index].orderStatus == 'accepted' || orderList[index].orderStatus == 'confirmed' || orderList[index].orderStatus == 'handover') {
                                              statusColor = Colors.green;
                                            } else if (orderList[index].orderStatus == 'delivered') {
                                              statusColor = Colors.blue;
                                            } else {
                                              statusColor = Theme.of(context).primaryColor;
                                            }
                                            
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                              ),
                                              child: Text(
                                                isDineIn ? status ?? '' : orderList[index].orderStatus!.tr,
                                                style: robotoMedium.copyWith(
                                                  fontSize: 10,
                                                  color: statusColor,
                                                ),
                                              ),
                                            );
                                          }
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Restaurant Info Row
                                    Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: CustomImageWidget(
                                              image: '${orderList![index].restaurant != null ? orderList[index].restaurant!.logoFullUrl : ''}',
                                              height: 40,
                                              width: 40,
                                              fit: BoxFit.cover,
                                              isRestaurant: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                orderList[index].restaurant?.name ?? 'Restaurant',
                                                style: robotoMedium.copyWith(
                                                  fontSize: 12,
                                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                DateConverter.dateTimeStringToDateTimeToLines(orderList[index].createdAt!),
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Bottom Row - Items and Track Button
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.restaurant_menu,
                                                size: 14,
                                                color: Theme.of(context).disabledColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${orderList[index].detailsCount} ${orderList[index].detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 11,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isRunning || isSubscription)
                                          if (orderList[index].orderType == 'delivery')
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(6),
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () => Get.toNamed(RouteHelper.getOrderTrackingRoute(orderList![index].id, null)),
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.local_shipping,
                                                          size: 12,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'track_order'.tr,
                                                          style: robotoMedium.copyWith(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    paginate ? const Center(child: Padding(
                      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: CircularProgressIndicator(),
                    )) : const SizedBox(),
                  ],
                ),
              ),
            )),
          ),
        ) : SingleChildScrollView(child: FooterViewWidget(child: NoDataScreen(title: 'no_order_yet'.tr, isEmptyOrder: true))) : OrderShimmerWidget(orderController: orderController);
      }),
    );
  }
}
