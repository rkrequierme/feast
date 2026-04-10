import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeastAppBar(title: 'Contact Us'),
      drawer: const FeastDrawer(username: 'Juan De La Cruz'),
      bottomNavigationBar: FeastBottomNav(currentIndex: -1),
    );
  }
}
