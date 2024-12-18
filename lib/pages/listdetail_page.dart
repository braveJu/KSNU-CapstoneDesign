import 'package:flutter/material.dart';

class ListDetailPage extends StatelessWidget {
  final String title;
  final String description;

  ListDetailPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color(0xFFDFF2DA),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          description,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
