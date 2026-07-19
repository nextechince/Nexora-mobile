import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ARService {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableContours: true,
      enableTracking: true,
    ),
  );

  Future<List<Face>> detectFaces(Uint8List imageData) async {
    final inputImage = InputImage.fromBytes(
      bytes: imageData,
      inputImageData: InputImageData(
        size: Size(640, 480),
        imageRotation: InputImageRotation.Rotation_0,
        format: InputImageFormat.NV21,
      ),
    );
    return await _faceDetector.processImage(inputImage);
  }

  Future<Uint8List> applyFilter({
    required Uint8List imageData,
    required String filterType,
    List<Face>? faces,
  }) async {
    final image = img.decodeImage(imageData);
    if (image == null) throw Exception('Failed to decode image');

    switch (filterType) {
      case 'dog': return _applyDogFilter(image, faces);
      case 'cat': return _applyCatFilter(image, faces);
      case 'glasses': return _applyGlassesFilter(image, faces);
      case 'hat': return _applyHatFilter(image, faces);
      case 'crown': return _applyCrownFilter(image, faces);
      case 'sunflower': return _applySunflowerFilter(image, faces);
      case 'mustache': return _applyMustacheFilter(image, faces);
      default: return imageData;
    }
  }

  Uint8List _applyDogFilter(img.Image image, List<Face>? faces) => img.encodeJpg(image);
  Uint8List _applyCatFilter(img.Image image, List<Face>? faces) => img.encodeJpg(image);
  Uint8List _applyGlassesFilter(img.Image image, List<Face>? faces) => img.encodeJpg(image);
  Uint8List _applyHatFilter(img.Image image, List<Face>? faces) => img.encodeJpg(image);
  Uint8List _applyCrownFilter(img.Image image, List<Face>? faces) => img.encodeJpg(image);
  Uint8List _applySunflowerFilter(img.Image image, List<Face>? faces) => img.encodeJpg(image);
  Uint8List _applyMustacheFilter(img.Image image, List<Face>? faces) => img.encodeJpg(image);

  Future<Map<String, dynamic>> trackFace(Uint8List imageData) async {
    final faces = await detectFaces(imageData);
    if (faces.isEmpty) return {};
    final face = faces.first;
    return {
      'bounding_box': face.boundingBox,
      'head_angle': {
        'roll': face.headEulerAngleZ ?? 0,
        'yaw': face.headEulerAngleY ?? 0,
        'pitch': face.headEulerAngleX ?? 0,
      },
      'smile_probability': face.smilingProbability ?? 0,
      'left_eye_open': face.leftEyeOpenProbability ?? 0,
      'right_eye_open': face.rightEyeOpenProbability ?? 0,
    };
  }

  List<Map<String, dynamic>> getAvailableFilters() {
    return [
      {'name': 'Dog', 'icon': '🐶', 'type': 'dog', 'premium': false},
      {'name': 'Cat', 'icon': '🐱', 'type': 'cat', 'premium': false},
      {'name': 'Glasses', 'icon': '👓', 'type': 'glasses', 'premium': false},
      {'name': 'Hat', 'icon': '🧢', 'type': 'hat', 'premium': false},
      {'name': 'Crown', 'icon': '👑', 'type': 'crown', 'premium': true},
      {'name': 'Sunflower', 'icon': '🌻', 'type': 'sunflower', 'premium': true},
      {'name': 'Mustache', 'icon': '🧔', 'type': 'mustache', 'premium': false},
    ];
  }

  Future<Uint8List> processFrame(Uint8List frame, String filterType) async {
    final faces = await detectFaces(frame);
    if (faces.isEmpty) return frame;
    return applyFilter(imageData: frame, filterType: filterType, faces: faces);
  }
}