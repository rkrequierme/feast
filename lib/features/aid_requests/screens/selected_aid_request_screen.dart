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
      appBar: FeastAppBar(title: 'Selected Aid Request'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: 1),
    );
  }
}
