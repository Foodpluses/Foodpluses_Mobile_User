import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'How do I place an order?',
      answer: 'To place an order, simply browse our restaurants, select your favorite dishes, add them to your cart, and proceed to checkout. You can choose your delivery address and payment method during checkout.',
    ),
    FaqItem(
      question: 'What payment methods do you accept?',
      answer: 'We accept various payment methods including credit/debit cards, digital wallets, cash on delivery, and bank transfers. The available payment options may vary by location.',
    ),
    FaqItem(
      question: 'How long does delivery take?',
      answer: 'Delivery times typically range from 30-60 minutes depending on your location, restaurant preparation time, and current order volume. You can track your order in real-time once it\'s confirmed.',
    ),
    FaqItem(
      question: 'Can I cancel my order?',
      answer: 'Yes, you can cancel your order if it hasn\'t been prepared yet. Orders can usually be cancelled within 5-10 minutes of placement. Once the restaurant starts preparing your food, cancellation may not be possible.',
    ),
    FaqItem(
      question: 'How do I track my order?',
      answer: 'You can track your order through the app by going to "My Orders" section. You\'ll see real-time updates including order confirmation, preparation status, and delivery tracking with estimated arrival time.',
    ),
    FaqItem(
      question: 'What if my food arrives cold or incorrect?',
      answer: 'If your food arrives cold or incorrect, please contact our customer support immediately. We\'ll work to resolve the issue with a refund, replacement, or credit for your next order.',
    ),
    FaqItem(
      question: 'How do I create an account?',
      answer: 'Creating an account is easy! Simply tap "Sign Up" on the login screen, enter your email and phone number, verify your details, and you\'re all set to start ordering.',
    ),
    FaqItem(
      question: 'Can I save my favorite restaurants?',
      answer: 'Yes! You can save your favorite restaurants by tapping the heart icon on any restaurant page. These will appear in your "Favorites" section for quick access.',
    ),
    FaqItem(
      question: 'How do I apply promo codes?',
      answer: 'During checkout, look for the "Promo Code" field and enter your code. Valid codes will automatically apply discounts to your order. Make sure to check the terms and conditions for each promo.',
    ),
    FaqItem(
      question: 'What are your delivery fees?',
      answer: 'Delivery fees vary by restaurant and distance. You\'ll see the exact delivery fee before confirming your order. Some restaurants offer free delivery on orders above a certain amount.',
    ),
    FaqItem(
      question: 'How do I contact customer support?',
      answer: 'You can contact our customer support through the app\'s "Help & Support" section, via live chat, email, or phone. Our support team is available 24/7 to assist you.',
    ),
    FaqItem(
      question: 'Can I schedule orders for later?',
      answer: 'Yes! Many restaurants offer scheduled delivery. During checkout, you can select a preferred delivery time if the restaurant supports this feature.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'FAQ'),
      backgroundColor: Theme.of(context).cardColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48,
                    color: Theme.of(context).cardColor,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Text(
                    'Frequently Asked Questions',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: Theme.of(context).cardColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(
                    'Find answers to common questions about our food delivery service',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Dimensions.paddingSizeLarge),
            
            // FAQ Items
            Text(
              'Questions & Answers',
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            
            const SizedBox(height: Dimensions.paddingSizeDefault),
            
            ..._faqItems.asMap().entries.map((entry) {
              int index = entry.key;
              FaqItem item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _faqItems.length - 1 ? 0 : Dimensions.paddingSizeDefault,
                ),
                child: FaqItemWidget(faqItem: item),
              );
            }).toList(),
            
            const SizedBox(height: Dimensions.paddingSizeOverLarge),
          ],
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });
}

class FaqItemWidget extends StatefulWidget {
  final FaqItem faqItem;

  const FaqItemWidget({
    super.key,
    required this.faqItem,
  });

  @override
  State<FaqItemWidget> createState() => _FaqItemWidgetState();
}

class _FaqItemWidgetState extends State<FaqItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question Header
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faqItem.question,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Answer Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                0,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
              ),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  ),
                  Text(
                    widget.faqItem.answer,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

