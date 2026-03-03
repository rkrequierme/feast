import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class CreateAidRequestScreen extends StatefulWidget {
  const CreateAidRequestScreen({super.key});

  @override
  State<CreateAidRequestScreen> createState() => _CreateAidRequestScreenState();
}

class _CreateAidRequestScreenState extends State<CreateAidRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(
        title: 'Create Aid Request',
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
