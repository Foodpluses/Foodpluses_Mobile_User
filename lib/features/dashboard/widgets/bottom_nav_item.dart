import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BottomNavItem extends StatelessWidget {
  final IconData iconData;
  final Function? onTap;
  final bool isSelected;
  final String label;
  final Widget? badge;
  const BottomNavItem({
    super.key, 
    required this.iconData, 
    this.onTap, 
    this.isSelected = false,
    required this.label,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    iconData, 
                    color: isSelected ? const Color(0xFFCF0F14) : Colors.grey.shade700, 
                    size: 24,
                  ),
                  if (badge != null) badge!,
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: robotoMedium.copyWith(
                  color: isSelected ? const Color(0xFFCF0F14) : Colors.grey.shade700,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
