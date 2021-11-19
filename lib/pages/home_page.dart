import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile;
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
                  return _buildCameraScreen();
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            imageFile == null
                ? const SizedBox.shrink()
                : Container(
                    width: 280,
                    height: 200,
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

  Widget _buildCameraScreen() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 300,
                child: CameraPreview(controller),
              ),
              DottedBorder(
                dashPattern: const [6, 10],
                color: Colors.white,
                strokeWidth: 4,
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                child: const SizedBox(
                  width: 280,
                  height: 200,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              try {
                print('TAKE');
                await _initializeControllerFuture;
                final image = await controller.takePicture();
                setState(() {
                  imageFile = File(image.path);
                });
              } catch (e) {
                print(e);
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
