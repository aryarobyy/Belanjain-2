import 'dart:io';
import 'dart:convert';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class ImagesService {
  final ImagePicker _picker = ImagePicker();
  late final Cloudinary cloudinary;

  ImagesService() {
    if (dotenv.env['CLOUDINARY_CLOUD_NAME'] == null ||
        dotenv.env['CLOUDINARY_API_SECRET'] == null ||
        dotenv.env['CLOUDINARY_API_KEY'] == null) {
      throw Exception('Cloudinary environment variables not set');
    }
  }

  Future uploadImage() async {
    try {
      XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedImage == null) {
        return;
      }

      File imageFile = File(pickedImage.path);
      if (!await imageFile.exists()) {
        return;
      }

      final String uuid       = const Uuid().v4();
      final String cloudName  = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
      final String apiKey     = dotenv.env['CLOUDINARY_API_KEY']!;
      final String apiSecret  = dotenv.env['CLOUDINARY_API_SECRET']!;
      final int    timestamp  = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String folder     = 'belanjain';

      // final signatureString = "public_id=$uuid&timestamp=$timestamp$apiSecret";
      // final signature = sha1.convert(utf8.encode(signatureString)).toString();

      final signature = generateSignature(
        publicId: uuid,
        timestamp: timestamp,
        folder: folder,
        apiSecret: apiSecret,
      );

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
      var request = http.MultipartRequest('POST', uri)
        ..fields['public_id'] = uuid
        ..fields['timestamp'] = timestamp.toString()
        ..fields['api_key'] = apiKey
        ..fields['signature'] = signature
        ..fields['folder']    = folder
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            filename: '$uuid.jpg',
          ),
        );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);
        final imageUrl = jsonResponse['secure_url'] as String;
        print("Uploaded Image URL: $imageUrl");
        return imageUrl;
      } else {
        print("Cloudinary upload error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final String publicId = pathSegments.last.split('.').first;

      final String cloudName  = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
      final String apiKey     = dotenv.env['CLOUDINARY_API_KEY']!;
      final String apiSecret  = dotenv.env['CLOUDINARY_API_SECRET']!;
      final String folder     = 'belanjain';

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = generateSignature(
        publicId: publicId,
        timestamp: timestamp,
        folder: folder,
        apiSecret: apiSecret,
      );

      final deleteUri =
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

      final response = await http.post(
        deleteUri,
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        print("Delete success");
        return true;
      } else {
        print("Cloudinary delete error: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  String generateSignature({
    required String publicId,
    required int timestamp,
    required String folder,
    required String apiSecret,
  }) {
    final params = {
      'folder': folder,
      'public_id': publicId,
      'timestamp': timestamp.toString(),
    };

    final sortedKeys = params.keys.toList()..sort();

    final buffer = StringBuffer();
    for (var i = 0; i < sortedKeys.length; i++) {
      final k = sortedKeys[i];
      buffer.write('$k=${params[k]}');
      if (i < sortedKeys.length - 1) buffer.write('&');
    }
    buffer.write(apiSecret);

    final signature = sha1.convert(utf8.encode(buffer.toString())).toString();
    return signature;
  }

}