import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedCharityEventScreen extends StatefulWidget {
  const SelectedCharityEventScreen({super.key});

  @override
  State<SelectedCharityEventScreen> createState() => _SelectedCharityEventScreenState();
}

class _SelectedCharityEventScreenState extends State<SelectedCharityEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(
        title: 'Create Charity Event',
        showBurgerMenu: false,
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
