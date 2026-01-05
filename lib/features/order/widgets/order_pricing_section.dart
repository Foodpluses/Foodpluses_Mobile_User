import 'package:dotted_border/dotted_border.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/widgets/bottom_view_widget.dart';
import 'package:stackfood_multivendor/features/order/widgets/order_product_widget.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPricingSection extends StatelessWidget {
  final double itemsPrice;
  final double addOns;
  final OrderModel order;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double tax;
  final double dmTips;
  final double deliveryCharge;
  final double total;
  final OrderController orderController;
  final int? orderId;
  final String? contactNumber;
  final double extraPackagingAmount;
  final double referrerBonusAmount;
  const OrderPricingSection({super.key, required this.itemsPrice, required this.addOns, required this.order, required this.subTotal, required this.discount,
    required this.couponDiscount, required this.tax, required this.dmTips, required this.deliveryCharge, required this.total, required this.orderController,
    this.orderId, this.contactNumber, required this.extraPackagingAmount, required this.referrerBonusAmount});

  Widget _buildSummaryRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String amount,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: robotoRegular.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: robotoMedium.copyWith(
            fontSize: 15,
            color: isDiscount ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool subscription = order.subscription != null;
    bool taxIncluded = order.taxStatus ?? false;
    bool isDineIn = order.orderType == 'dine_in';

    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
      ) : null,
      child: Column(children: [
        ResponsiveHelper.isDesktop(context) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Text('item_info'.tr, style: robotoMedium),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderController.orderDetails!.length,
            itemBuilder: (context, index) {
              return OrderProductWidget(order: order, orderDetails: orderController.orderDetails![index]);
            },
          ),
        ]) : const SizedBox(),

        // Order Summary Section - Matching checkout screen design
        Container(
          padding: const EdgeInsets.all(18),
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Order Summary',
                    style: robotoMedium.copyWith(
                      fontSize: 17,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              
              // Sub-total
              !subscription ? _buildSummaryRow(
                context: context,
                icon: Icons.shopping_cart_outlined,
                label: 'Sub-total (${orderController.orderDetails!.length} ${orderController.orderDetails!.length > 1 ? 'items' : 'item'})${taxIncluded ? ' (tax_included'.tr + ')' : ''}',
                amount: PriceConverter.convertPrice(subTotal),
              ) : const SizedBox(),
              SizedBox(height: !subscription ? 14 : 0),
              
              // Discount
              discount > 0 ? _buildSummaryRow(
                context: context,
                icon: Icons.local_offer_outlined,
                label: 'discount'.tr,
                amount: '-${PriceConverter.convertPrice(discount)}',
                isDiscount: true,
              ) : const SizedBox(),
              SizedBox(height: discount > 0 ? 14 : 0),
              
              // Additional Charge
              (order.additionalCharge != null && order.additionalCharge! > 0) ? _buildSummaryRow(
                context: context,
                icon: Icons.receipt_outlined,
                label: Get.find<SplashController>().configModel!.additionalChargeName ?? 'Service Fee',
                amount: PriceConverter.convertPrice(order.additionalCharge!),
              ) : const SizedBox(),
              SizedBox(height: (order.additionalCharge != null && order.additionalCharge! > 0) ? 14 : 0),
              
              // Coupon Discount
              couponDiscount > 0 ? _buildSummaryRow(
                context: context,
                icon: Icons.local_offer_outlined,
                label: 'coupon_discount'.tr,
                amount: '-${PriceConverter.convertPrice(couponDiscount)}',
                isDiscount: true,
              ) : const SizedBox(),
              SizedBox(height: couponDiscount > 0 ? 14 : 0),
              
              // Referral Discount
              (referrerBonusAmount > 0) ? _buildSummaryRow(
                context: context,
                icon: Icons.card_giftcard_outlined,
                label: 'referral_discount'.tr,
                amount: '-${PriceConverter.convertPrice(referrerBonusAmount)}',
                isDiscount: true,
              ) : const SizedBox(),
              SizedBox(height: referrerBonusAmount > 0 ? 14 : 0),
              
              // Tax
              !taxIncluded && tax > 0 ? _buildSummaryRow(
                context: context,
                icon: Icons.account_balance_outlined,
                label: 'vat_tax'.tr,
                amount: PriceConverter.convertPrice(tax),
              ) : const SizedBox(),
              SizedBox(height: (!taxIncluded && tax > 0) ? 14 : 0),
              
              // Delivery Man Tips
              (!subscription && !isDineIn && order.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && dmTips > 0) ? _buildSummaryRow(
                context: context,
                icon: Icons.volunteer_activism_outlined,
                label: 'delivery_man_tips'.tr,
                amount: PriceConverter.convertPrice(dmTips),
              ) : const SizedBox(),
              SizedBox(height: (!subscription && !isDineIn && order.orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1 && dmTips > 0) ? 14 : 0),
              
              // Extra Packaging
              (extraPackagingAmount > 0) ? _buildSummaryRow(
                context: context,
                icon: Icons.inventory_2_outlined,
                label: 'extra_packaging'.tr,
                amount: PriceConverter.convertPrice(extraPackagingAmount),
              ) : const SizedBox(),
              SizedBox(height: extraPackagingAmount > 0 ? 14 : 0),
              
              // Delivery Fee
              !isDineIn && order.orderType != 'take_away' ? _buildSummaryRow(
                context: context,
                icon: Icons.local_shipping_outlined,
                label: 'delivery_fee'.tr,
                amount: (deliveryCharge != null && deliveryCharge! > 0) ? PriceConverter.convertPrice(deliveryCharge!) : 'free'.tr,
              ) : const SizedBox(),
              SizedBox(height: (!isDineIn && order.orderType != 'take_away') ? 14 : 0),
              
              const SizedBox(height: 18),
              
              // Divider
              Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.grey.shade300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 18),
              
              // Total Amount
              order.paymentMethod == 'partial_payment' ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: DottedBorder(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 1,
                  strokeCap: StrokeCap.butt,
                  dashPattern: const [8, 5],
                  padding: const EdgeInsets.all(8),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(Dimensions.radiusDefault),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.orange,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'total_amount'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        PriceConverter.convertPrice(total),
                        textDirection: TextDirection.ltr,
                        style: robotoBold.copyWith(
                          fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
                          color: Colors.orange,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('paid_by_wallet'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                      Text(
                        PriceConverter.convertPrice(order.payments?[0].amount ?? 0),
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        textDirection: TextDirection.ltr,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        '${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments?[1].paymentMethod?.toString().replaceAll('_', ' ')})',
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      ),
                      Text(
                        PriceConverter.convertPrice(order.payments?[1].amount ?? 0),
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                        textDirection: TextDirection.ltr,
                      ),
                    ]),
                  ]),
                ),
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.orange,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        subscription ? 'subtotal'.tr : 'total_amount'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: 17,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    PriceConverter.convertPrice(total),
                    textDirection: TextDirection.ltr,
                    style: robotoBold.copyWith(
                      fontSize: 20,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              
              // Subscription details
              subscription ? Column(children: [
                const SizedBox(height: 18),
                Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('subscription_order_count'.tr, style: robotoMedium),
                  Text(order.subscription!.quantity.toString(), style: robotoMedium),
                ]),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.orange,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'total_amount'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: 17,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      PriceConverter.convertPrice(total * order.subscription!.quantity!),
                      textDirection: TextDirection.ltr,
                      style: robotoBold.copyWith(
                        fontSize: 20,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ]) : const SizedBox(),

            ],
          ),
        ),
        SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),

        ResponsiveHelper.isDesktop(context) ? BottomViewWidget(orderController: orderController, order: order, orderId: orderId, total: total, contactNumber: contactNumber) : const SizedBox(),

      ]),
    );
  }
}
