import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mcq_gemini/helper/clean_pdf.dart';
import 'package:mcq_gemini/provider/mcq_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class InputSection extends StatefulWidget {
  const InputSection({super.key});

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedFileName;
  String? _fileContent;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  //* extract text from pdf
  Future<String> extractTextFromPdf(String filePath) async {
    try {
      String text;
      text = await ReadPdfText.getPDFtext(filePath);
      print(text);
      return text;
    } catch (e) {
      throw Exception("Failed to extract PDF text: $e");
    }
  }

  //* Pick file and extracts text
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final extension = fileName.split('.').last.toLowerCase();

      String content = "";

      if (extension == 'txt') {
        //* Normal text file
        final file = File(filePath);
        content = await file.readAsString();
      } else if (extension == 'pdf') {
        //* PDF file
        content = await extractTextFromPdf(filePath);
      } else {
        throw Exception("Unsupported file type");
      }

      //* clean pdf content
      content = cleanPdfText(content);

      if (!mounted) return;

      setState(() {
        _selectedFileName = fileName;
        _fileContent = content;

        if (_fileContent != null && _fileContent!.isNotEmpty) {
          _textController.text = _fileContent!;
        } else {
          _textController.clear();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text('Loaded: $fileName'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error reading file: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFileName = null;
      _fileContent = null;
      _textController.clear();
    });
  }

  void _generateMCQs() {
    final provider = context.read<MCQProvider>();
    final content = _fileContent ?? _textController.text;

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Please enter text or upload a file'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    provider.generateMCQs(content);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MCQProvider>();
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final isTablet = sw > 600;

    return Card(
      margin: EdgeInsets.all(sw * 0.04),
      elevation: 4,
      shadowColor: const Color(0xFF6366F1).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFF6366F1).withOpacity(0.03),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //* Text Input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFileName != null
                        ? const Color(0xFF6366F1).withOpacity(0.3)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: isTablet ? 8 : 5,
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                    color: const Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your notes here...',
                    hintStyle: TextStyle(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: _selectedFileName != null
                        ? const Color(0xFF6366F1).withOpacity(0.05)
                        : Colors.grey.shade50,
                    contentPadding: EdgeInsets.all(sw * 0.035),
                  ),
                ),
              ),

              SizedBox(height: sh * 0.02),

              //* OR Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey.shade300,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.03,
                        vertical: sh * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: sh * 0.02),

              //* File Upload Section
              if (_selectedFileName == null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: provider.isLoading ? null : _pickFile,
                    icon: Icon(Icons.upload_file_rounded,
                        size: isTablet ? sw * 0.025 : sw * 0.05,
                        color: const Color(0xFF6366F1)),
                    label: Text(
                      'Upload File (TXT/PDF)',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                      backgroundColor:
                          const Color(0xFF6366F1).withOpacity(0.05),
                      side: BorderSide.none,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(sw * 0.03),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFF8B5CF6).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(sw * 0.025),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          color: const Color(0xFF6366F1),
                          size: isTablet ? sw * 0.03 : sw * 0.06,
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: Text(
                          _selectedFileName!,
                          style: TextStyle(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: provider.isLoading ? null : _clearFile,
                        icon: Icon(
                          Icons.close_rounded,
                          size: isTablet ? sw * 0.025 : sw * 0.05,
                        ),
                        color: const Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: sh * 0.025),

              //* Generate Button
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _generateMCQs,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? SizedBox(
                          height: isTablet ? sw * 0.025 : sw * 0.05,
                          width: isTablet ? sw * 0.025 : sw * 0.05,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.white),
                            SizedBox(width: sw * 0.02),
                            Text(
                              'Generate MCQs',
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
