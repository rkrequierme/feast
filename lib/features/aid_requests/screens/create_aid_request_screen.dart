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
      appBar: FeastAppBar(title: 'Create Aid Request'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: 1),
    );
  }
}
