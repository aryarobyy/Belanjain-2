import 'dart:io';

import 'package:belanjain/providers/image_view.dart';
import 'package:belanjain/services/labeling_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class KameraScreen extends StatefulWidget {
  const KameraScreen({super.key});

  @override
  State<KameraScreen> createState() => _KameraScreenState();
}

class _KameraScreenState extends State<KameraScreen> {
  late final ImageLabeler _imageLabeler;
  List<CameraDescription> cameras = [];
  CameraController? controller;
  Future<void>? _initializeControllerFuture;
  CustomPaint? _customPaint;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    await requestPermissions();
    await _setupCameraController();
    _initializeLabeler();
  }

  void _initializeLabeler() {
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  }

  Future<void> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isDenied || storageStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions are required to use the camera')),
      );
      return;
    }
  }

  Future<void> _setupCameraController() async {
    try {
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = controller!.initialize();
      await _initializeControllerFuture;

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      setState(() {
        _isCameraReady = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to setup camera: $e')),
      );
    }
  }

  Future<void> takePicture() async {
    try {
      if (controller == null || !controller!.value.isInitialized) {
        throw Exception('Camera not ready');
      }

      final String uuid = const Uuid().v4();
      final XFile image = await controller!.takePicture();
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String savedImagePath = '${appDir.path}/captured_image_$uuid.jpg';

      await File(image.path).copy(savedImagePath);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewPage(imagePath: savedImagePath),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  Future<void> processImage(InputImage inputImage) async {
    try {
      final labels = await _imageLabeler.processImage(inputImage);

      setState(() {
        if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
          final painter = LabelingService(labels);
          _customPaint = CustomPaint(painter: painter);
        }

        print('Labels found: ${labels.length}');
        for (final label in labels) {
          print('Label: ${label.label}, Ketepatan: ${label.confidence.toStringAsFixed(2)}');
        }
      });
    } catch (e) {
      print('Error processing image: $e');
    }
  }

  Future<void> getImageAndDetectObjects() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);

      if (imageFile == null) return;

      final inputImage = InputImage.fromFilePath(imageFile.path);
      final objectDetector = GoogleMlKit.vision.objectDetector(
        options: ObjectDetectorOptions(
          mode: DetectionMode.single,
          classifyObjects: true,
          multipleObjects: true,
        ),
      );

      final List<DetectedObject> objects = await objectDetector.processImage(inputImage);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewPage(imagePath: imageFile.path),
        ),
      );
      await objectDetector.close();

      print('Detected ${objects.length} objects');
    } catch (e) {
      print('Error detecting objects: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _isCameraReady) {
            return SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: CameraPreview(controller!),
                      ),
                    ),
                  ),
                  if (_customPaint != null) _customPaint!,
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: takePicture,
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: getImageAndDetectObjects,
                            icon: const Icon(
                              Icons.photo_library,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}