class NotFoundException implements Exception {
  final String message;

  NotFoundException({required this.message});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class SocketException implements Exception {
  final String message;
  SocketException(this.message);

  @override
  String toString() => message;
}
