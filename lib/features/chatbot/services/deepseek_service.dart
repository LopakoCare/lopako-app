import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lopako_app_lis/config/api_keys.dart';

class DeepseekService {
  final String apiKey;
  static const String apiUrl = 'https://api.deepseek.com/v1/chat/completions';

  DeepseekService({required this.apiKey});

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating AI response: $e');
      throw e;
    }
  }
}