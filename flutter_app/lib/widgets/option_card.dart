import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const OptionCard({super.key, required this.title, required this.onTap, this.subtitle = ""});

  @override
  Widget build(BuildContext ctx) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.folder_open, color: Colors.indigo),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
