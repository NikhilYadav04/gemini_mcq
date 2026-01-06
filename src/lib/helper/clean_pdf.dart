String cleanPdfText(String text) {
  return text
      //* Remove weird unicode chars
      .replaceAll(RegExp(r'[�•©™]'), '')

      //* Fix hyphenated line breaks
      .replaceAll(RegExp(r'-\n'), '')

      // *Replace newlines with space
      .replaceAll(RegExp(r'\n+'), ' ')

      //* Remove multiple spaces
      .replaceAll(RegExp(r'\s{2,}'), ' ')

      //* Remove page numbers like "Page 1" or "1 / 10"
      .replaceAll(RegExp(r'Page\s+\d+(\s+of\s+\d+)?', caseSensitive: false), '')
      .replaceAll(RegExp(r'\b\d+\s*/\s*\d+\b'), '')
      .trim();
}
