import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CancellationDialogue extends StatefulWidget {
  final int? orderId;
  const CancellationDialogue({super.key, required this.orderId});

  @override
  State<CancellationDialogue> createState() => _CancellationDialogueState();
}

class _CancellationDialogueState extends State<CancellationDialogue> {
  bool _isLoadingReasons = true;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadCancelReasons();
  }

  Future<void> _loadCancelReasons() async {
    if (_hasLoadedOnce) return; // Prevent multiple calls
    
    setState(() {
      _isLoadingReasons = true;
    });
    
    await Get.find<OrderController>().getOrderCancelReasons();
    
    setState(() {
      _isLoadingReasons = false;
      _hasLoadedOnce = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          return SizedBox(
            width: 500, height: MediaQuery.of(context).size.height * 0.6,
            child: Column(children: [

              Container(
                width: 500,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                ),
                child: Column(children: [
                  Text('select_cancellation_reasons'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                ]),
              ),

              Expanded(
                child: _isLoadingReasons 
                  ? const Center(child: CircularProgressIndicator())
                  : orderController.orderCancelReasons != null && orderController.orderCancelReasons!.isNotEmpty 
                    ? ListView.builder(
                        itemCount: orderController.orderCancelReasons!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: ListTile(
                              onTap: (){
                                orderController.setOrderCancelReason(orderController.orderCancelReasons![index].reason);
                              },
                              title: Row(
                                children: [
                                  Icon(orderController.orderCancelReasons![index].reason == orderController.cancelReason ? Icons.radio_button_checked : Icons.radio_button_off, color: Theme.of(context).primaryColor, size: 18),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Flexible(child: Text(orderController.orderCancelReasons![index].reason!, style: robotoRegular, maxLines: 3, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          );
                        }
                      ) 
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 48, color: Theme.of(context).disabledColor),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              Text('no_reasons_available'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.fontSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: !orderController.isCancelLoading ? Row(children: [
                  Expanded(child: CustomButtonWidget(
                    buttonText: 'cancel'.tr, color: Theme.of(context).disabledColor, radius: 50,
                    onPressed: () => Get.back(),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomButtonWidget(
                    buttonText: 'submit'.tr,  radius: 50,
                    onPressed: (){
                      if(orderController.cancelReason != '' && orderController.cancelReason != null){

                        orderController.cancelOrder(widget.orderId, orderController.cancelReason).then((success) {
                          if(success){
                            orderController.trackOrder(widget.orderId.toString(), null, true);
                          }
                        });

                      }else{
                        if(Get.isDialogOpen!){
                          Get.back();
                        }

                        showCustomSnackBar('you_did_not_select_select_any_reason'.tr);
                      }
                    },
                  )),
                ]) : const Center(child: CircularProgressIndicator()),
              ),
            ]),
          );
        }
      ),
    );
  }
}
