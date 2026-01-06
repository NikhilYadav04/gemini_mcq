import 'package:flutter/material.dart';
import 'package:mcq_gemini/provider/mcq_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/input_section.dart';
import '../widgets/mcq_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final isTablet = sw > 600;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: isTablet ? sw * 0.025 : sw * 0.05,
                color: Colors.white,
              ),
            ),
            SizedBox(width: sw * 0.02),
            Text(
              'GEMINI MCQ Generator',
              style: TextStyle(
                fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6366F1).withOpacity(0.05),
              const Color(0xFFF8F9FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<MCQProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  //* Input Section
                  const InputSection(),

                  SizedBox(height: sh * 0.02),

                  //* Error Display
                  if (provider.error != null)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: sw * 0.04),
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.03,
                        vertical: sh * 0.015,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade50,
                            Colors.red.shade100.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                        border:
                            Border.all(color: Colors.red.shade300, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red.shade700,
                            size: isTablet ? sw * 0.025 : sw * 0.055,
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: isTablet ? sw * 0.018 : sw * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: isTablet ? sw * 0.022 : sw * 0.05,
                            ),
                            onPressed: provider.clearError,
                            color: Colors.red.shade700,
                            padding: EdgeInsets.all(sw * 0.02),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                  //* Loading State
                  if (provider.isLoading)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: isTablet ? sw * 0.12 : sw * 0.18,
                                  height: isTablet ? sw * 0.12 : sw * 0.18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF6366F1)
                                            .withOpacity(0.1),
                                        const Color(0xFF8B5CF6)
                                            .withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: isTablet ? sw * 0.08 : sw * 0.12,
                                  height: isTablet ? sw * 0.08 : sw * 0.12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.auto_awesome,
                                  color: const Color(0xFF6366F1),
                                  size: isTablet ? sw * 0.035 : sw * 0.06,
                                ),
                              ],
                            ),
                            SizedBox(height: sh * 0.03),
                            Text(
                              'Generating MCQs...',
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.022 : sw * 0.042,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                            SizedBox(height: sh * 0.01),
                            Text(
                              'AI is analyzing your content',
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.018 : sw * 0.035,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  //* MCQ List
                  if (!provider.isLoading && provider.mcqs.isNotEmpty)
                    Expanded(
                      child: MCQList(mcqs: provider.mcqs),
                    ),

                  //* Empty State
                  if (!provider.isLoading &&
                      provider.mcqs.isEmpty &&
                      provider.error == null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(sw * 0.08),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6366F1).withOpacity(0.1),
                                    const Color(0xFF8B5CF6).withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.psychology_outlined,
                                size: isTablet ? sw * 0.12 : sw * 0.2,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                            SizedBox(height: sh * 0.025),
                            Text(
                              'No MCQs yet',
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                            SizedBox(height: sh * 0.012),
                            Text(
                              'Upload notes or enter text to generate',
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.018 : sw * 0.035,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
