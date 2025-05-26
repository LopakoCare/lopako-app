import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepseekService {
  final String apiKey;
  final http.Client _client; // Cliente persistente para keep-alive

  // Opcional: permite ajustar maxTokens al instanciar
  final int maxTokens;
  final double temperature;

  DeepseekService({
    required this.apiKey,
    this.maxTokens = 500,        // Reduce tokens para acelerar
    this.temperature = 0.7,
  }) : _client = http.Client();

  /// Genera una respuesta para [prompt], reusando la conexión HTTP.
  Future<String> generateResponse(String prompt) async {
    final uri = Uri.parse('https://api.deepseek.com/v1/chat/completions');

    // Construyo el cuerpo solo con lo imprescindible
    final payload = {
      'model': 'deepseek-chat',   // el más rápido sin CoT
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': maxTokens,
      'temperature': temperature,
    };

    try {
      final resp = await _client
          .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 10)); // fallo rápido si hay latencia

      if (resp.statusCode != 200) {
        throw Exception(
          'Error ${resp.statusCode}: ${resp.reasonPhrase}',
        );
      }

      // JSON decoding ligero
      final Map<String, dynamic> data = jsonDecode(resp.body);
      return data['choices'][0]['message']['content'] as String;
    } catch (e) {
      // Loguea internamente y propaga
      print('DeepseekService error: $e');
      rethrow;
    }
  }

  /// Cierra el cliente cuando ya no se vaya a usar.
  void dispose() {
    _client.close();
  }
}