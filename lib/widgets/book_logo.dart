import 'package:flutter/material.dart';

class BookLogo extends StatelessWidget {
  final double size;
  
  const BookLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Book base
          Container(
            width: size * 0.8,
            height: size * 0.9,
            decoration: BoxDecoration(
              color: const Color(0xFFF9C73D),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
          ),
          // Book pages
          Positioned(
            right: size * 0.15,
            child: Container(
              width: size * 0.7,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
            ),
          ),
          // Book spine lines
          Positioned(
            left: size * 0.12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size * 0.15,
                  height: 2,
                  color: const Color(0xFF0D1232),
                ),
                const SizedBox(height: 4),
                Container(
                  width: size * 0.1,
                  height: 2,
                  color: const Color(0xFF0D1232),
                ),
                const SizedBox(height: 4),
                Container(
                  width: size * 0.12,
                  height: 2,
                  color: const Color(0xFF0D1232),
                ),
              ],
            ),
          ),
          // Heart icon for cuteness
          Positioned(
            top: size * 0.15,
            right: size * 0.25,
            child: Icon(
              Icons.favorite,
              color: const Color(0xFFF9C73D),
              size: size * 0.15,
            ),
          ),
        ],
      ),
    );
  }
}