import 'package:flutter/material.dart';
import 'package:mcq_gemini/models/mcq_model.dart';

class MCQList extends StatelessWidget {
  final List<MCQ> mcqs;

  const MCQList({super.key, required this.mcqs});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final isTablet = sw > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.015,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.015,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: isTablet ? sw * 0.025 : sw * 0.05,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Generated MCQs',
                    style: TextStyle(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.042,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.03,
                  vertical: sh * 0.006,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${mcqs.length}',
                  style: TextStyle(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.01,
            ),
            itemCount: mcqs.length,
            itemBuilder: (context, index) {
              return MCQCard(mcq: mcqs[index], index: index);
            },
          ),
        ),
      ],
    );
  }
}

class MCQCard extends StatefulWidget {
  final MCQ mcq;
  final int index;

  const MCQCard({super.key, required this.mcq, required this.index});

  @override
  State<MCQCard> createState() => _MCQCardState();
}

class _MCQCardState extends State<MCQCard> {
  String? _selectedAnswer;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final isTablet = sw > 600;

    return Card(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      elevation: 3,
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
              const Color(0xFF6366F1).withOpacity(0.02),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Number and Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03,
                      vertical: sh * 0.01,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(sw * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Q${widget.index + 1}',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: Text(
                      widget.mcq.question,
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.018),

              // Options
              ...widget.mcq.options.map((option) {
                final isSelected = _selectedAnswer == option;
                final isCorrect = option == widget.mcq.correctAnswer;
                final showCorrect = _showAnswer && isCorrect;
                final showWrong = _showAnswer && isSelected && !isCorrect;

                return Container(
                  margin: EdgeInsets.only(bottom: sh * 0.012),
                  decoration: BoxDecoration(
                    gradient: showCorrect
                        ? LinearGradient(
                            colors: [
                              Colors.green.shade50,
                              Colors.green.shade100.withOpacity(0.3),
                            ],
                          )
                        : showWrong
                            ? LinearGradient(
                                colors: [
                                  Colors.red.shade50,
                                  Colors.red.shade100.withOpacity(0.3),
                                ],
                              )
                            : isSelected
                                ? LinearGradient(
                                    colors: [
                                      const Color(0xFF6366F1).withOpacity(0.1),
                                      const Color(0xFF8B5CF6).withOpacity(0.05),
                                    ],
                                  )
                                : null,
                    border: Border.all(
                      color: showCorrect
                          ? Colors.green.shade600
                          : showWrong
                              ? Colors.red.shade600
                              : isSelected
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey.shade300,
                      width: showCorrect || showWrong || isSelected ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                  child: RadioListTile<String>(
                    value: option,
                    groupValue: _selectedAnswer,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: _showAnswer
                        ? null
                        : (value) {
                            setState(() {
                              _selectedAnswer = value;
                            });
                          },
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03,
                      vertical: sh * 0.005,
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        color: showCorrect || showWrong
                            ? Colors.black87
                            : const Color(0xFF374151),
                        fontWeight: showCorrect || showWrong
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    secondary: showCorrect
                        ? Icon(Icons.check_circle_rounded,
                            color: Colors.green.shade600, size: sw * 0.06)
                        : showWrong
                            ? Icon(Icons.cancel_rounded,
                                color: Colors.red.shade600, size: sw * 0.06)
                            : null,
                  ),
                );
              }),

              SizedBox(height: sh * 0.012),

              // Check Answer Button
              if (!_showAnswer && _selectedAnswer != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showAnswer = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Check Answer',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Explanation
              if (_showAnswer && widget.mcq.explanation != null)
                Container(
                  margin: EdgeInsets.only(top: sh * 0.015),
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.03,
                    vertical: sh * 0.015,
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: sh * 0.002),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          color: const Color(0xFF6366F1),
                          size: isTablet ? sw * 0.025 : sw * 0.05,
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explanation',
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                            SizedBox(height: sh * 0.008),
                            Text(
                              widget.mcq.explanation!,
                              style: TextStyle(
                                fontSize: isTablet ? sw * 0.018 : sw * 0.035,
                                color: const Color(0xFF374151),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Reset Button
              if (_showAnswer)
                Padding(
                  padding: EdgeInsets.only(top: sh * 0.01),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedAnswer = null;
                        _showAnswer = false;
                      });
                    },
                    icon: Icon(Icons.refresh_rounded,
                        size: isTablet ? sw * 0.022 : sw * 0.045,
                        color: const Color(0xFF6366F1)),
                    label: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6366F1),
                      ),
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
