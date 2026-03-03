import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedAidRequestScreen extends StatefulWidget {
  const SelectedAidRequestScreen({super.key});

  @override
  State<SelectedAidRequestScreen> createState() => _SelectedAidRequestScreenState();
}

class _SelectedAidRequestScreenState extends State<SelectedAidRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(
        title: "Selected Aid Request",
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
