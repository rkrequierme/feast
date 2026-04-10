import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class AidRequestsScreen extends StatefulWidget {
  const AidRequestsScreen({super.key});

  @override
  State<AidRequestsScreen> createState() => _AidRequestsScreenState();
}

class _AidRequestsScreenState extends State<AidRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Aid Requests'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: 1),
    );
  }
}
