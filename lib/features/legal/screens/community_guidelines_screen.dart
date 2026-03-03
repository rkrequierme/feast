import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class CommunityGuidelinesScreen extends StatefulWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  State<CommunityGuidelinesScreen> createState() => _CommunityGuidelinesScreenState();
}

class _CommunityGuidelinesScreenState extends State<CommunityGuidelinesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(
        title: 'Community Guidelines',
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
