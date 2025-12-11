import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ActivityPageIndicator extends StatelessWidget {
  final PageController controller;
  final int pageCount;

  const ActivityPageIndicator({
    super.key,
    required this.controller,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: pageCount,
      effect: const WormEffect(
        dotHeight: 10,
        dotWidth: 10,
        spacing: 8,
        dotColor: Color(0xFFBDBDBD), // Gris
        activeDotColor: Color(0xFF0D6EFD), // Azul como tu imagen
      ),
    );
  }
}
