import 'dart:io';
import 'package:belanjain/screen/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageViewPage extends StatefulWidget {
  final String imagePath;
  const ImageViewPage({super.key, required this.imagePath});

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  bool isLoading = true;
  List<ImageLabel> labels = [];
  String error = '';
  String categoryOutput = "";

  @override
  void initState() {
    super.initState();
    processImage();

    Gemini.instance.text(
        'From these categories: All, fragrances, furniture, beauty, groceries. Return only ONE word without any other text or explanation for input: ${labels.map((label) => label.label).join(", ")}. If none match, return "invalid"'
    ).then((value) {
      if (value?.output != null) {
        setState(() {
          categoryOutput = value!.output!.trim();
        });
      }
    }).catchError((error) {
      debugPrint('Error in Gemini prompt: $error');
      setState(() {
        categoryOutput = "not available";
      });
    });
  }

  Future<void> processImage() async {
    try {
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final imageLabeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.7),
      );

      final detectedLabels = await imageLabeler.processImage(inputImage);

      setState(() {
        labels = detectedLabels;
        isLoading = false;
      });

      await imageLabeler.close();
    } catch (e) {
      setState(() {
        error = 'Error processing image: $e';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    final file = File(widget.imagePath);
    if (file.existsSync()) {
      file.deleteSync();
      debugPrint('File ${widget.imagePath} telah dihapus.');
    } else {
      debugPrint('File ${widget.imagePath} tidak ditemukan untuk dihapus.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil analisa'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(
              File(widget.imagePath),
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Objek terdeteksi:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (labels.isEmpty)
                      const Text(
                        'Tidak ada objek terdeteksi',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    labels.where((label) => label.confidence > 0.8).isNotEmpty
                        ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: labels.where((label) => label.confidence > 0.8).length,
                      itemBuilder: (context, index) {
                        final filteredLabels = labels.where((label) => label.confidence > 0.8).toList();
                        final label = filteredLabels[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(label.label),
                            subtitle: Text(
                              'Ketepatan: ${(label.confidence * 100).toStringAsFixed(1)}%',
                            ),
                          ),
                        );
                      },
                    )
                        : Text("Tidak ada objek yang terdeteksi dengan confidence > 80% $categoryOutput"),
                    Center(
                      child: IconButton(
                          onPressed: () {
                            print("Category: $categoryOutput");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen(inputCategory: categoryOutput)
                                )
                            );
                          },
                          icon: Icon(Icons.search)
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}