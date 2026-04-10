import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class CharityEventsScreen extends StatefulWidget {
  const CharityEventsScreen({super.key});

  @override
  State<CharityEventsScreen> createState() => _CharityEventsScreenState();
}

class _CharityEventsScreenState extends State<CharityEventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Charity Events'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: 2),
    );
  }
}
