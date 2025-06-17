import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/table_model.dart';
import '../providers/sql_provider.dart';

/// Servicio para interactuar con la API de OpenAI y generar SQL
class OpenAIService {
  final String apiKey;

  OpenAIService({required this.apiKey});

  Future<void> generateAndStoreSQL({
    required List<TableModel> tables,
    required SqlProvider sqlProvider,
  }) async {
    // Generar el prompt personalizado basado en las tablas guardadas
    final prompt = "Eres un generador de SQL avanzado. Mejora el siguiente esquema y genera únicamente el código SQL optimizado, sin explicaciones:\n\n" +
        tables.map((table) {
          final columns = table.columns.map((col) => "  - ${col.name} (${col.type})").join("\n");
          return "Tabla: ${table.tableName}\n$columns";
        }).join("\n\n");

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'Eres un generador de SQL avanzado.'},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 500,
        'temperature': 0.2,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        final sql = responseData['choices'][0]['message']['content'] as String;
        sqlProvider.setSqlCode(sql.trim());
      } catch (e) {
        sqlProvider.setSqlCode('Error al procesar la respuesta de OpenAI: $e');
      }
    } else {
      sqlProvider.setSqlCode('Error al generar SQL: ${response.statusCode} - ${response.body}');
    }
  }
}
