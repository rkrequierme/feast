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
      appBar: FeastAppBar(title: 'Create Charity Event'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: 2),
    );
  }
}
