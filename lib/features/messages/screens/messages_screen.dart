import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Messages'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: 3),
    );
  }
}
