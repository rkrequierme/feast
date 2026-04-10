import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedChatScreen extends StatefulWidget {
  const SelectedChatScreen({super.key});

  @override
  State<SelectedChatScreen> createState() => _SelectedChatScreenState();
}

class _SelectedChatScreenState extends State<SelectedChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Selected Chat'),
    );
  }
}
