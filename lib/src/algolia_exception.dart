class AlgoliaNetworkException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  AlgoliaNetworkException(this.message, {this.statusCode, this.data});
  @override
  String toString() {
    String errorMessage = 'ERROR: $message ';
    if (data != null) {
      errorMessage += data['message'].toString();
    }
    return errorMessage;
  }
}
