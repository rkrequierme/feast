import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class SelectedGroupScreen extends StatefulWidget {
  const SelectedGroupScreen({super.key});

  @override
  State<SelectedGroupScreen> createState() => _SelectedGroupScreenState();
}

class _SelectedGroupScreenState extends State<SelectedGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Selected Group'),
    );
  }
}
