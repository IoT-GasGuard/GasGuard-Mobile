import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final VoidCallback onMenuPressed;
  final Widget? customAction;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppHeader({
    Key? key,
    this.title,
    required this.onMenuPressed,
    this.customAction,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (showBackButton) const SizedBox(width: 8),
              Image.asset(
                'assets/logo_gasguard.png',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          customAction ?? IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(
              Icons.menu,
              color: Color(0xFF4ECDC4),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}