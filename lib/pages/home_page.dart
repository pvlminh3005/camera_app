import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/utils/crop_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

late List<CameraDescription> cameras;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
  late var data;
  late CameraController controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _buildCameraScreen(context);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            imageFile == null
                ? const SizedBox.shrink()
                : AspectRatio(
                    aspectRatio: 5 / 3,
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraScreen(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size.width,
                height: size.width * .8 * controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: DottedBorder(
                  dashPattern: const [6, 10],
                  color: Colors.white,
                  strokeWidth: 4,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  child: const AspectRatio(
                    aspectRatio: 5 / 3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              try {
                await _initializeControllerFuture;
                final image = await controller.takePicture();
                // File? cropImage = await Utils.cropImage(image.path);
                setState(() {
                  imageFile = File(image.path);
                });
              } catch (e) {
                throw Exception();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
