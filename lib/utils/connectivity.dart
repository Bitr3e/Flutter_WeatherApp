import 'dart:io';
import 'package:http/http.dart' as http;

class Connectivity {
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Wraps an HTTP call with a connectivity check, throwing a friendly
  /// message when the device appears offline.
  static Future<http.Response> guardedGet(
    http.Client client,
    Uri uri, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (!await hasInternet()) {
      throw Exception('No internet connection. Check your network.');
    }
    try {
      return await client.get(uri).timeout(timeout);
    } on SocketException {
      throw Exception('No internet connection. Check your network.');
    } on http.ClientException {
      throw Exception('No internet connection. Check your network.');
    }
  }
}
