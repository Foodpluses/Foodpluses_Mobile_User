import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliveryInstructionBottomSheet extends StatefulWidget {
  const DeliveryInstructionBottomSheet({super.key});

  @override
  State<DeliveryInstructionBottomSheet> createState() => _DeliveryInstructionBottomSheetState();
}

class _DeliveryInstructionBottomSheetState extends State<DeliveryInstructionBottomSheet> {
  int selectIndex = -1;
  final TextEditingController customTextController = TextEditingController();
  bool useCustomText = false;

  @override
  void initState() {
    super.initState();
    // Load existing selection if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CheckoutController checkoutController = Get.find<CheckoutController>();
      if (checkoutController.selectedInstruction != -1 && 
          checkoutController.selectedInstruction < AppConstants.deliveryInstructionList.length) {
        setState(() {
          selectIndex = checkoutController.selectedInstruction;
          useCustomText = false;
        });
      } else if (checkoutController.deliveryInstructionController.text.trim().isNotEmpty) {
        setState(() {
          customTextController.text = checkoutController.deliveryInstructionController.text.trim();
          useCustomText = true;
          selectIndex = -1;
        });
      }
    });
  }

  @override
  void dispose() {
    customTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(children: [
          Container(
            height: 4, width: 35,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('add_more_delivery_instruction'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            IconButton(
              onPressed: ()=> Get.back(),
              icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
            )
          ]),

          // Predefined options
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppConstants.deliveryInstructionList.length,
              itemBuilder: (context, index){
                bool isSelected = selectIndex == index && !useCustomText;
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectIndex = index;
                      useCustomText = false;
                      customTextController.clear();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.5) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Text(
                      AppConstants.deliveryInstructionList[index].tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: isSelected ? Theme.of(context).cardColor : Theme.of(context).disabledColor),
                    ),
                  ),
                );
              }),

          const SizedBox(height: Dimensions.paddingSizeSmall),
          
          // Divider
          Container(
            height: 1,
            color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
          ),
          
          const SizedBox(height: Dimensions.paddingSizeDefault),
          
          // Custom text field option
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Or enter custom instruction:',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextFieldWidget(
                controller: customTextController,
                hintText: 'Enter your custom delivery instruction...',
                showLabelText: false,
                maxLines: 3,
                inputType: TextInputType.multiline,
                inputAction: TextInputAction.done,
                capitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  setState(() {
                    if (value.trim().isNotEmpty) {
                      useCustomText = true;
                      selectIndex = -1;
                    } else {
                      useCustomText = false;
                    }
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          SafeArea(
            child: CustomButtonWidget(
              buttonText: 'apply'.tr,
              onPressed: (selectIndex == -1 && !useCustomText) || (useCustomText && customTextController.text.trim().isEmpty)
                  ? null 
                  : (){
                    CheckoutController checkoutController = Get.find<CheckoutController>();
                    if (useCustomText && customTextController.text.trim().isNotEmpty) {
                      // Save custom text
                      checkoutController.deliveryInstructionController.text = customTextController.text.trim();
                      checkoutController.setInstruction(-1); // Reset predefined selection
                    } else if (selectIndex != -1) {
                      // Save predefined option
                      checkoutController.setInstruction(selectIndex);
                      checkoutController.deliveryInstructionController.clear(); // Clear custom text
                    }
                    Get.back();
                  },
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge)
        ]),
      ),
    );
  }
}
