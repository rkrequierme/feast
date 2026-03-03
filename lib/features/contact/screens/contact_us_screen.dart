import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(
        title: 'Contact Us',
        showBurgerMenu: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: feastBlack),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
