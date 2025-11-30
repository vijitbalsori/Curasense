import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String body;
  const ResultCard({required this.title, required this.body});

  @override
  Widget build(BuildContext ctx) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 14)),
        ]),
      ),
    );
  }
}
