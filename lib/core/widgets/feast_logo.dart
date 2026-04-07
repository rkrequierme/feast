import 'package:flutter/material.dart';

class FeastLogo extends StatelessWidget {
  final double height;

  // 200.0 = Default Height Value (Can Be Changed When Called)
  const FeastLogo({
    super.key, 
    this.height = 200.0, 
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/GPC_Logo.png',
      height: height,
      // errorBuilder Provides UI Fallback If Image Fails To Load
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: height * 0.25,
                color: Colors.grey,
              ),
              const Text(
                'Logo Image',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
