import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your live backend URL (without trailing slash)
  static String get baseUrl => 'https://ghost-signal-backend.onrender.com';

  static Future<Map<String, dynamic>> decodeMorse(String morse) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/morse/decode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': morse}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to decode morse: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> encodeMorse(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/morse/encode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to encode morse: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> crackCaesar(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/caesar/crack'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to crack caesar cipher: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> hideMessage(
    String message,
    String mode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/steganography/hide'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'mode': mode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to hide message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> extractMessage(
    String text,
    String mode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/steganography/extract'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'mode': mode,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to extract message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> getDailyChallenge() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/challenge/daily'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get daily challenge: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}