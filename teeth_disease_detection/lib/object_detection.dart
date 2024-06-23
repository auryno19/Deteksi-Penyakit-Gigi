import 'dart:developer';
import 'dart:typed_data';
// import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Detection {
  int x1;
  int y1;
  int x2;
  int y2;
  double score;
  String label;

  Detection(
      {required this.x1,
      required this.y1,
      required this.x2,
      required this.y2,
      required this.score,
      required this.label});
}

class ImageAnalysisResult {
  final Uint8List image;
  final List<String> labelArray;

  ImageAnalysisResult({required this.image, required this.labelArray});
}

class ObjectDetection {
  static const String _modelPath1 = 'assets/caries.tflite';
  static const String _labelPath1 = 'assets/caries.txt';

  static const String _modelPath2 = 'assets/calculus.tflite';
  static const String _labelPath2 = 'assets/calculus.txt';

  Interpreter? _interpreter1;
  Interpreter? _interpreter2;
  List<String>? _labels1;
  List<String>? _labels2;

  ObjectDetection() {
    _loadModel1();
    _loadLabels1();
    _loadModel2();
    _loadLabels2();
    log('Done.');
  }

  Future<void> _loadModel1() async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();

    interpreterOptions.addDelegate(XNNPackDelegate());

    log('Loading interpreter...');
    _interpreter1 =
        await Interpreter.fromAsset(_modelPath1, options: interpreterOptions);
  }

  Future<void> _loadModel2() async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();

    interpreterOptions.addDelegate(XNNPackDelegate());

    log('Loading interpreter...');
    _interpreter2 =
        await Interpreter.fromAsset(_modelPath2, options: interpreterOptions);
  }

  Future<void> _loadLabels1() async {
    log('Loading labels...');
    final labelsRaw = await rootBundle.loadString(_labelPath1);
    _labels1 = labelsRaw.split('\n');
  }

  Future<void> _loadLabels2() async {
    log('Loading labels...');
    final labelsRaw = await rootBundle.loadString(_labelPath2);
    _labels2 = labelsRaw.split('\n');
  }

  ImageAnalysisResult analyseImage(String imagePath) {
    log('Analysing image...');
    // Reading image bytes from file
    final imageData = File(imagePath).readAsBytesSync();

    // Decoding image
    final image = img.decodeImage(imageData);

    // Resizing image for model, [320, 320]
    // If you use SSD_Mobile_Net_V2 FPN Lite 320 x 320 , please change both the width and height to 320
    final imageInput = img.copyResize(
      image!,
      width: 320,
      height: 320,
    );

    // Creating matrix representation, [320, 320, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    final output1 = _runInference1(imageMatrix);
    final output2 = _runInference2(imageMatrix);

    log('output1');
    log(output1.toString());
    log('output2');
    log(output2.toString());
    // Process Tensors from the output1
    final scoresTensor1 = output1[0].first as List<double>;
    final boxesTensor1 = output1[1].first as List<List<double>>;
    final classesTensor1 = output1[3].first as List<double>;

    // Process Tensors from the output2
    final scoresTensor2 = output2[0].first as List<double>;
    final boxesTensor2 = output2[1].first as List<List<double>>;
    final classesTensor2 = output2[3].first as List<double>;


    log('Processing outputs...');

    // Convert class indices to int
    final classes1 = classesTensor1.map((value) => value.toInt()).toList();
    final classes2 = classesTensor2.map((value) => value.toInt()).toList();

    // Number of detections
    final numberOfDetections1 = output1[2].first as double;
    final numberOfDetections2 = output2[2].first as double;

    // Get classifcation with label
    final List<String> classification1 = [];
    final List<String> classification2 = [];
    for (int i = 0; i < numberOfDetections1; i++) {
      classification1.add(_labels1![classes1[i]]);
    }
    for (int i = 0; i < numberOfDetections2; i++) {
      classification2.add(_labels2![classes2[i]]);
    }

    List<Detection> detections1 = [];
    List<Detection> detections2 = [];

    log('Outlining objects...');
    final iW = image.width;
    final iH = image.height;
    Set<String> uniqueLabels = {};
    

    for (var i = 0; i < scoresTensor1.length; i++) {
      if (scoresTensor1[i] > 0.5) {
        final x1 = (boxesTensor1[i][1] * iW).toInt();
        final y1 = (boxesTensor1[i][0] * iH).toInt();
        final x2 = (boxesTensor1[i][3] * iW).toInt();
        final y2 = (boxesTensor1[i][2] * iH).toInt();
        detections1.add(Detection(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          score: scoresTensor1[i],
          label: classification1[i],
        ));
      }
    }

    for (var i = 0; i < scoresTensor2.length; i++) {
      if (scoresTensor2[i] > 0.5) {
        final x1 = (boxesTensor2[i][1] * iW).toInt();
        final y1 = (boxesTensor2[i][0] * iH).toInt();
        final x2 = (boxesTensor2[i][3] * iW).toInt();
        final y2 = (boxesTensor2[i][2] * iH).toInt();
        detections2.add(Detection(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          score: scoresTensor2[i],
          label: classification2[i],
        ));
      }
    }

    // Buat array baru untuk menggabungkan hasil deteksi kedua model
    List<Detection> allDetections = [...detections1, ...detections2];

    // Urutkan berdasarkan koordinat dari pojok kiri atas ke pojok kanan bawah
    allDetections.sort((a, b) {
      if (a.y1 < b.y1) return -1;
      if (a.y1 > b.y1) return 1;
      if (a.x1 < b.x1) return -1;
      if (a.x1 > b.x1) return 1;
      return 0;
    });

    //  menghilangkan bounding box yang bertumpuk
    List<Detection> nonMaxSuppressedDetections =
        _nonMaxSuppression(allDetections);

// Gambar bounding box yang tidak bertumpuk
    for (var detection in nonMaxSuppressedDetections) {
      img.ColorRgb8 color;
      if (detection.label == 'caries') {
        color = img.ColorRgb8(255, 0, 0); // Red
      } else if (detection.label == 'calculus') {
        color = img.ColorRgb8(0, 0, 255); // Blue
      } else if (detection.label == 'healthy') {
        color = img.ColorRgb8(0, 255, 0); // Green
      } else {
        color = img.ColorRgb8(0, 0, 0); // Black (default)
      }
      img.drawRect(
        image,
        x1: detection.x1,
        y1: detection.y1,
        x2: detection.x2,
        y2: detection.y2,
        color: color,
        thickness: 3,
      );
      img.drawString(
        image,
        '${detection.label} ${(detection.score * 100).toStringAsFixed(0)}%',
        font: img.arial24,
        x: detection.x1 + 7,
        y: detection.y1 + 7,
        color: color,
      );
    uniqueLabels.add(detection.label);
    }
    log('Done.');
    List<String> labelArray = uniqueLabels.toList();
    final Uint8List imageResult = img.encodeJpg(image);
    return ImageAnalysisResult(image: imageResult, labelArray: labelArray);
  }

  List<List<Object>> _runInference1(
    List<List<List<num>>> imageMatrix,
  ) {
    log('Running inference...');

    num inputMean = 127.5;
    num inputStd = 127.5;

    // Convert imageMatrix to Float32List
    final floatImageMatrix = imageMatrix
        .map((plane) => plane
            .map((row) =>
                Float32List.fromList(row.map((e) => e.toDouble()).toList()))
            .toList())
        .toList();

    // Normalize the input data
    final normalizedImageMatrix = floatImageMatrix
        .map((plane) => plane
            .map((row) =>
                row.map((pixel) => (pixel - inputMean) / inputStd).toList())
            .toList())
        .toList();

    // Set input tensor [1, 320, 320, 3]
    final input = [normalizedImageMatrix];

    // final input = [imageMatrix];

    // log('imag_inpput: $input');
    final output = {
      0: [List<num>.filled(10, 0)],
      1: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      2: [0.0],
      3: [List<num>.filled(10, 0)],
    };

    _interpreter1!.runForMultipleInputs([input], output);
    return output.values.toList();
  }

  List<List<Object>> _runInference2(
    List<List<List<num>>> imageMatrix,
  ) {
    log('Running inference...');

    num inputMean = 127.5;
    num inputStd = 127.5;

    // Set input tensor [1, 320, 320, 3]

    // Convert imageMatrix to Float32List
    final floatImageMatrix = imageMatrix
        .map((plane) => plane
            .map((row) =>
                Float32List.fromList(row.map((e) => e.toDouble()).toList()))
            .toList())
        .toList();

    // Normalize the input data
    final normalizedImageMatrix = floatImageMatrix
        .map((plane) => plane
            .map((row) =>
                row.map((pixel) => (pixel - inputMean) / inputStd).toList())
            .toList())
        .toList();

    // Set input tensor [1, 320, 320, 3]
    final input = [normalizedImageMatrix];

    // final input = [imageMatrix];

    // log('imag_inpput: $input');

    final output = {
      0: [List<num>.filled(10, 0)],
      1: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      2: [0.0],
      3: [List<num>.filled(10, 0)],
    };

    _interpreter2!.runForMultipleInputs([input], output);
    return output.values.toList();
  }

  List<Detection> _nonMaxSuppression(List<Detection> detections) {
    detections.sort((a, b) => b.score.compareTo(a.score));

    List<Detection> nonMaxSuppressedDetections = [];

    for (Detection detection in detections) {
      bool isOverlapped = false;
      for (Detection otherDetection in nonMaxSuppressedDetections) {
        if (_isOverlapped(detection, otherDetection)) {
          isOverlapped = true;
          break;
        }
      }

      if (!isOverlapped) {
        nonMaxSuppressedDetections.add(detection);
      }
    }

    return nonMaxSuppressedDetections;
  }

  bool _isOverlapped(Detection a, Detection b) {
    final x1 = a.x1;
    final y1 = a.y1;
    final x2 = a.x2;
    final y2 = a.y2;
    final x3 = b.x1;
    final y3 = b.y1;
    final x4 = b.x2;
    final y4 = b.y2;

    return (x1 < x4 && x3 < x2 && y1 < y4 && y3 < y2);
  }
}
