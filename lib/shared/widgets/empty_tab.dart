import 'package:flutter/material.dart';

class EmptyTab extends StatelessWidget {
  final String title;

  const EmptyTab({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: const TextStyle(fontSize: 18)));
  }
}
