import 'package:flutter/material.dart';

class WomanPage extends StatefulWidget {
  const WomanPage({super.key});

  @override
  State<WomanPage> createState() => _WomanPageState();
}

class _WomanPageState extends State<WomanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joggin woman'),
      ),
    );
  }
}
