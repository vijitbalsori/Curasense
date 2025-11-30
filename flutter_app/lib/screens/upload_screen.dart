import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

final TextEditingController _questionController = TextEditingController();

class UploadScreen extends StatefulWidget {
  final String module;
  final bool allowMultiple;
  const UploadScreen({super.key, required this.module, this.allowMultiple = false});

  @override
  State createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool loading = false;
  String out = "";
  List<File> files = [];

  String get _moduleTitle {
    switch (widget.module) {
      case "lab":
        return "Lab Report Analysis";
      case "discharge":
        return "Discharge Summary";
      case "prescription":
        return "Prescription Analysis";
      default:
        return widget.module.toUpperCase();
    }
  }

  IconData get _moduleIcon {
    switch (widget.module) {
      case "lab":
        return Icons.science_outlined;
      case "discharge":
        return Icons.assignment_outlined;
      case "prescription":
        return Icons.medication_outlined;
      default:
        return Icons.upload_file;
    }
  }

  Color get _moduleColor {
    switch (widget.module) {
      case "lab":
        return Colors.purple;
      case "discharge":
        return Colors.teal;
      case "prescription":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? res;
    if (widget.allowMultiple) {
      res = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any);
    } else {
      res = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.any);
    }
    if (res == null) return;
    files = res.paths.map((p) => File(p!)).toList();
    setState(() {});
  }

  Future<void> upload() async {
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select at least one file"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      loading = true;
      out = "";
    });
    final api = Provider.of<ApiService>(context, listen: false);
    final question = _questionController.text.trim();

    final res = await api.uploadFile(
      module: widget.module,
      patientId: "P1",
      files: files,
      question: question,
    );

    if (res['ok'] == true) {
      setState(() {
        out = res['body'];
      });
    } else {
      setState(() {
        out = "Error: ${res['error'] ?? res['body'] ?? res['statusCode']}";
      });
    }
    setState(() {
      loading = false;
    });
  }

  void removeFile(int index) {
    setState(() {
      files.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _moduleTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: _moduleColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_moduleColor, _moduleColor.withOpacity(0.8)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _moduleIcon,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Text(
                //   widget.allowMultiple ? "Upload multiple files" : "Upload a file",
                //   style: const TextStyle(
                //     fontSize: 16,
                //     color: Colors.white,
                //   ),
                // ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upload Button
                  _buildUploadButton(),
                  const SizedBox(height: 20),

                  // Files Section
                  if (files.isNotEmpty) ...[
                    _buildSectionTitle("Selected Files (${files.length})"),
                    const SizedBox(height: 12),
                    ...files.asMap().entries.map((entry) => _buildFileCard(entry.key, entry.value)),
                    const SizedBox(height: 24),
                    // Query Text Field
                    TextField(
                      controller: _questionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Enter your question (optional)",
                        hintText: widget.module == "lab"
                            ? "e.g., Explain abnormalities in the report"
                            : widget.module == "prescription"
                                ? "e.g., What medicines are prescribed?"
                                : "e.g., Summarize these documents",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                  ],

                  // Analyze Button
                  if (files.isNotEmpty) ...[
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: loading ? null : upload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _moduleColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.analytics_outlined),
                                  SizedBox(width: 8),
                                  Text(
                                    "Analyze Documents",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Results Section
                  if (out.isNotEmpty) ...[
                    _buildSectionTitle("Analysis Results"),
                    const SizedBox(height: 12),
                    _buildResultCard(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _moduleColor.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: pickFiles,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _moduleColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: _moduleColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Tap to select files",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _moduleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.allowMultiple
                      ? "You can select multiple files"
                      : "PDF, images, and other documents",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFileCard(int index, File file) {
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _moduleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getFileIcon(fileExtension),
            color: _moduleColor,
            size: 24,
          ),
        ),
        title: Text(
          fileName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          fileExtension,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          color: Colors.grey[600],
          onPressed: () => removeFile(index),
          tooltip: "Remove file",
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isError = out.startsWith("Error:");
    final isWarning = out.contains("wrong PDF") ||
                    out.contains("quality of the PDF is too low") ||
                    out.contains("extract text");
    Color bg;
    Color border;
    Color text;
    IconData icon;
    if (isError) {
      bg = Colors.red[50]!;
      border = Colors.red[200]!;
      text = Colors.red[900]!;
      icon = Icons.error_outline;
    } else if (isWarning) {
      bg = Colors.orange[50]!;
      border = Colors.orange[200]!;
      text = Colors.orange[900]!;
      icon = Icons.warning_amber_rounded;
    } else {
      bg = Colors.green[50]!;
      border = Colors.green[200]!;
      text = Colors.green[900]!;
      icon = Icons.check_circle_outline;
    }
    String formatted = out.replaceAll(r'\n', '\n');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: text, size: 24),
              const SizedBox(width: 8),
               Text(
                isError
                    ? "Analysis Failed"
                    : isWarning
                        ? "Warning"
                        : "Analysis Complete",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            formatted,
            style: TextStyle(
              fontSize: 14,
              color: text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}