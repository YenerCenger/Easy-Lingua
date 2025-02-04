import 'package:flutter/material.dart';

class BackgroundCircles extends StatelessWidget {
  const BackgroundCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sol üstte alttaki yuvarlak
        Positioned(
          left: -100,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Color.fromRGBO(143, 225, 215, 0.44), // Turkuaz tonu
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Sağ üstte üstteki yuvarlak
        Positioned(
          top: -100,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Color.fromRGBO(143, 225, 215, 0.44), // Turkuaz tonu
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
