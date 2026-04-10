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
      appBar: FeastAppBar(title: 'Selected Charity Event'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: 2),
    );
  }
}
