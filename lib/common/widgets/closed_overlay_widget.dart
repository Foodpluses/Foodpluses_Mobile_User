import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ClosedOverlayWidget extends StatelessWidget {
  final Widget child;
  final bool isClosed;
  final String? closedText;

  const ClosedOverlayWidget({
    Key? key,
    required this.child,
    required this.isClosed,
    this.closedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isClosed)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      closedText ?? 'closed',
                      style: robotoMedium.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
