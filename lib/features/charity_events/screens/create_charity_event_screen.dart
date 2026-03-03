import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class CreateCharityEventScreen extends StatefulWidget {
  const CreateCharityEventScreen({super.key});

  @override
  State<CreateCharityEventScreen> createState() => _CreateCharityEventScreenState();
}

class _CreateCharityEventScreenState extends State<CreateCharityEventScreen> {
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
