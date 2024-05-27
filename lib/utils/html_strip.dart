String stripHtml(final String text) {
  // The regular expression is simplified for an HTML tag (opening or
  // closing) or an HTML escape. We might want to skip over such expressions
  // when estimating the text directionality.
  return text
      .replaceAll(RegExp(r"<[^>]*>|&[^;]+;"), " ")
      .replaceAll(RegExp(r"\[ ]"), "");
}
