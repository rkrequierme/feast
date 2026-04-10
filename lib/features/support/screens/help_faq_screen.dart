import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class HelpFAQScreen extends StatefulWidget {
  const HelpFAQScreen({super.key});

  @override
  State<HelpFAQScreen> createState() => _HelpFAQScreenState();
}

class _HelpFAQScreenState extends State<HelpFAQScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FeastAppBar(title: 'Help & FAQ'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
    );
  }
}
