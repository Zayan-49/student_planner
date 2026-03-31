import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const String _fallbackMessage =
	  "Sorry, I couldn't understand. Try again.";

  Future<String> generateResponse(String userMessage) async {
	final apiKey = dotenv.env['GEMINI_API_KEY'];
	if (apiKey == null || apiKey.isEmpty) {
	  return _fallbackMessage;
	}

	final uri = Uri.parse(
	  'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
	);

	final body = {
	  'contents': [
		{
		  'parts': [
			{
			  'text':
				  'Explain this in simple student-friendly way: $userMessage',
			},
		  ],
		},
	  ],
	};

	try {
	  final response = await http.post(
		uri,
		headers: const {'Content-Type': 'application/json'},
		body: jsonEncode(body),
	  );

	  if (response.statusCode < 200 || response.statusCode >= 300) {
		return _fallbackMessage;
	  }

	  final data = jsonDecode(response.body) as Map<String, dynamic>;
	  final candidates = data['candidates'] as List<dynamic>?;
	  if (candidates == null || candidates.isEmpty) {
		return _fallbackMessage;
	  }

	  final content = candidates.first['content'] as Map<String, dynamic>?;
	  final parts = content?['parts'] as List<dynamic>?;
	  final text = parts != null && parts.isNotEmpty
		  ? parts.first['text'] as String?
		  : null;

	  if (text == null || text.trim().isEmpty) {
		return _fallbackMessage;
	  }

	  return text.trim();
	} catch (_) {
	  return _fallbackMessage;
	}
  }
}

