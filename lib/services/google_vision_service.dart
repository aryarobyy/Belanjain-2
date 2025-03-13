import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GoogleVisionService {
  static const String _visionApiUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  final String apiKey;

  GoogleVisionService() : apiKey = dotenv.env['GOOGLE_VISION_ANDROID'] ?? "";

  Future<List<VisionLabel>> detectLabels(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$_visionApiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'LABEL_DETECTION', 'maxResults': 10}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        return _parseLabels(response.body);
      } else {
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to detect labels: $e');
    }
  }

  List<VisionLabel> _parseLabels(String responseBody) {
    final response = jsonDecode(responseBody) as Map<String, dynamic>;
    final labels = response['responses'][0]['labelAnnotations'] as List<dynamic>? ?? [];

    return labels.map((label) {
      return VisionLabel(
        label: label['description'] as String,
        confidence: (label['score'] as num).toDouble(),
      );
    }).toList();
  }
}

class VisionLabel {
  final String label;
  final double confidence;

  VisionLabel({
    required this.label,
    required this.confidence,
  });
}