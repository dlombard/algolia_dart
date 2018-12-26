class AlgoliaException implements Exception {
  final String message;
  final int statusCode;
  AlgoliaException(this.message, this.statusCode);
  @override
  String toString() => '($statusCode): $message';
}
