class ValidatorException implements Exception {
  final String message;

  const ValidatorException(this.message);

  String toString() => this.message;
}
