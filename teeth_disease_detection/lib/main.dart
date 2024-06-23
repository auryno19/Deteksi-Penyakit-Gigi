// import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teeth_disease_detection/calculus_page.dart';
import 'package:teeth_disease_detection/caries_page.dart';
import 'package:teeth_disease_detection/object_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Penegnalan Penyakit Gigi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ObjectDetection? objectDetection;

  Uint8List? analyzeImage;
  List<String>? labelArray;

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();

    final XFile? result = await picker.pickImage(source: ImageSource.gallery);
    if (result == null) return;
    File? imageMap = File(result.path);
    imageMap = await _cropImage(imageFile: imageMap);
    final analysResult = objectDetection!.analyseImage(imageMap!.path);
    setState(() {
      labelArray = analysResult.labelArray;
      analyzeImage = analysResult.image;
    });
  }

  pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? result = await picker.pickImage(source: ImageSource.camera);

    if (result == null) return;

    File? imageMap = File(result.path);
    imageMap = await _cropImage(imageFile: imageMap);
    final analysResult = objectDetection!.analyseImage(imageMap!.path);

    setState(() {
      labelArray = analysResult.labelArray;
      analyzeImage = analysResult.image;
    });
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  @override
  void initState() {
    super.initState();
    objectDetection = ObjectDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi Pengenalan Penyakit Gigi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 500,
                        width: double.infinity,
                        decoration: analyzeImage == null
                            ? const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/upload.jpg'),
                                ),
                              )
                            : null,
                        child: analyzeImage == null
                            ? const Text('')
                            : Image.memory(
                                analyzeImage!,
                                // fit: BoxFit.fill,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  labelArray != null
                      ? (labelArray!.isEmpty)
                          ? const Text(
                              '') // or you can display a message like "No labels found"
                          : (labelArray!.contains('healthy') &&
                                  labelArray!.length == 1)
                              ? const Text('Gigi Anda Sehat')
                              : (labelArray!.contains('caries') &&
                                      labelArray!.contains('calculus'))
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CariesPage()),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                ),
                                                foregroundColor: Colors.black,
                                                backgroundColor:
                                                    Colors.red.shade50),
                                            child: const Text('Caries')),
                                        const SizedBox(width: 20),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CalculusPage()),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                        vertical: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                ),
                                                foregroundColor: Colors.black,
                                                backgroundColor:
                                                    Colors.lightBlue.shade50),
                                            child: const Text('Calculus')),
                                      ],
                                    )
                                  : (labelArray!.contains('caries'))
                                      ? ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CariesPage()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                              foregroundColor: Colors.black,
                                              backgroundColor:
                                                  Colors.red.shade50),
                                          child: const Text('Caries'))
                                      : (labelArray!.contains('calculus'))
                                          ? ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const CalculusPage()),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 30,
                                                      vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13),
                                                  ),
                                                  foregroundColor: Colors.black,
                                                  backgroundColor:
                                                      Colors.lightBlue.shade50),
                                              child: const Text('Calculus'))
                                          : const Text('')
                      : Container(),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageCamera();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Take a Photo",
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageGallery();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Pick from gallery",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
