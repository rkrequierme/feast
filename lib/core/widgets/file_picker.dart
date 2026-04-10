import 'package:flutter/material.dart';

class FeastFilePicker extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  const FeastFilePicker({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.onTap,
    this.prefixIcon = Icons.account_circle_outlined,
    this.suffixIcon = Icons.folder_open_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' $label',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withAlpha(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: Icon(prefixIcon, color: Colors.black54, size: 22),
              suffixIcon: Icon(suffixIcon, color: Colors.black54, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}