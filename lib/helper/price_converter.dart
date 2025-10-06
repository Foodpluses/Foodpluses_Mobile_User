import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceConverter {
  static String convertPrice(double? price, {double? discount, String? discountType, bool forDM = false, bool isVariation = false}) {
    if(discount != null && discountType != null){
      if(discountType == 'amount' && !isVariation) {
        price = price! - discount;
      }else if(discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }

    int digitAfterDecimalPoint = Get.find<SplashController>().configModel!.digitAfterDecimalPoint ?? 2;

    int tempPrice = price!.floor();
    if((price - tempPrice) == 0) {
      digitAfterDecimalPoint = 0;
    }

    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = _getSafeCurrencySymbol(Get.find<SplashController>().configModel!.currencySymbol!);
    
    return '${isRightSide ? '' : '$currencySymbol '}'
        '${(toFixed(price)).toStringAsFixed(forDM ? 0 : digitAfterDecimalPoint)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        '${isRightSide ? ' $currencySymbol' : ''}';
  }

  static Widget convertAnimationPrice(double? price, {double? discount, String? discountType, bool forDM = false, TextStyle? textStyle}) {
    if(discount != null && discountType != null){
      if(discountType == 'amount') {
        price = price! - discount;
      }else if(discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = _getSafeCurrencySymbol(Get.find<SplashController>().configModel!.currencySymbol!);
    
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        value: toFixed(price!),
        textStyle: textStyle ?? robotoMedium,
        fractionDigits: forDM ? 0 : Get.find<SplashController>().configModel!.digitAfterDecimalPoint!,
        prefix: isRightSide ? '' : currencySymbol,
        suffix: isRightSide ? currencySymbol : '',
      ),
    );
  }


  static double? convertWithDiscount(double? price, double? discount, String? discountType, {bool isVariation = false}) {
    if(discountType == 'amount' && !isVariation) {
      price = price! - discount!;
    }else if(discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(double amount, double? discount, String type, int quantity) {
    double calculatedAmount = 0;
    if(type == 'amount') {
      calculatedAmount = discount! * quantity;
    }else if(type == 'percent') {
      calculatedAmount = (discount! / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(String price, String discount, String discountType) {
    String currencySymbol = _getSafeCurrencySymbol(Get.find<SplashController>().configModel!.currencySymbol!);
    return '$discount${discountType == 'percent' ? '%' : currencySymbol} OFF';
  }

  static double toFixed(double val) {
    num mod = power(10, Get.find<SplashController>().configModel!.digitAfterDecimalPoint!);
    return (((val * mod).toPrecision(Get.find<SplashController>().configModel!.digitAfterDecimalPoint!)).floor().toDouble() / mod);
  }

  static int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) {
      retval *= x;
    }
    return retval;
  }

  /// Helper function to ensure currency symbols display correctly in APK builds
  static String _getSafeCurrencySymbol(String symbol) {
    // Common currency symbol mappings for better APK compatibility
    switch (symbol.trim()) {
      case '₦':
        return '₦'; // Nigerian Naira
      case '\$':
        return '\$'; // Dollar
      case '€':
        return '€'; // Euro
      case '£':
        return '£'; // Pound
      case '₹':
        return '₹'; // Rupee
      case '¥':
        return '¥'; // Yen
      case '₽':
        return '₽'; // Ruble
      case '₩':
        return '₩'; // Won
      case '₪':
        return '₪'; // Shekel
      case '₫':
        return '₫'; // Dong
      case '₨':
        return '₨'; // Rupee (alternative)
      case '₴':
        return '₴'; // Hryvnia
      case '₵':
        return '₵'; // Cedi
      case '₸':
        return '₸'; // Tenge
      case '₼':
        return '₼'; // Manat
      case '₾':
        return '₾'; // Lari
      case '₿':
        return '₿'; // Bitcoin
      default:
        // If symbol is not recognized, try to use it as-is
        // If it still doesn't work, fallback to a simple text representation
        return symbol.isNotEmpty ? symbol : 'CUR';
    }
  }

}