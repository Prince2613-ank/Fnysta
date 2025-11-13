class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);

  @override
  String toString() => message ?? 'A server error occurred.';
}

class CacheException implements Exception {}
