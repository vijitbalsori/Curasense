import 'package:flutter/material.dart';
// removed unused imports added earlier
import 'upload_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Med AI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[700]!, Colors.blue[600]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome to Med AI",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your intelligent medical assistant",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "What would you like to do?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Option Cards
                  _buildModernOptionCard(
                    ctx,
                    icon: Icons.science_outlined,
                    title: "Lab Report Analysis",
                    subtitle: "Upload lab PDF or image for analysis",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => UploadScreen(
                            module: "lab",
                            allowMultiple: false,
                          ),
                        ),
                      );
                    },
                  ),

                  _buildModernOptionCard(
                    ctx,
                    icon: Icons.assignment_outlined,
                    title: "Discharge Summary",
                    subtitle: "Analyze discharge summary and recent documents",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => UploadScreen(
                            module: "discharge",
                            allowMultiple: true,
                          ),
                        ),
                      );
                    },
                  ),

                  _buildModernOptionCard(
                    ctx,
                    icon: Icons.chat_bubble_outline,
                    title: "Medical Q&A",
                    subtitle: "Ask general health questions",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(builder: (_) => ChatScreen()),
                      );
                    },
                  ),

                  _buildModernOptionCard(
                    ctx,
                    icon: Icons.medication_outlined,
                    title: "Prescription Analysis",
                    subtitle: "Upload prescription image for review",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => UploadScreen(
                            module: "prescription",
                            allowMultiple: false,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "For Android emulator, use API base 10.0.2.2:8000",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _buildModernOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
}