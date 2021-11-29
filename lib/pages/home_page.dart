import 'dart:io';
import 'dart:typed_data';

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
  Uint8List? data;
  late CameraController controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
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
            data == null ? const SizedBox.shrink() : Image.memory(data!)
          ],
        ),
      ),
    );
  }

  Widget _buildCameraScreen() {
    double widthCamera = MediaQuery.of(context).size.width;
    double heightCamera =
        MediaQuery.of(context).size.width * controller.value.aspectRatio;
    double widthCrop = widthCamera * .8;
    double heightCrop = heightCamera * .5;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: widthCamera,
                height: heightCamera,
                child: CameraPreview(controller),
              ),
              Container(
                alignment: Alignment.center,
                child: DottedBorder(
                  dashPattern: const [6, 10],
                  color: Colors.white,
                  strokeWidth: 4,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  child: SizedBox(
                    width: widthCrop,
                    height: heightCrop,
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
                final src = img.decodeImage(File(image.path).readAsBytesSync());

                //get ratio size image vs size camera
                var widthRatio = src!.width / widthCamera;
                var heightRatio = src.height / heightCamera;

                final newRect = Rect.fromLTWH(
                  (src.width - widthCrop * widthRatio) / 2,
                  (src.height - heightCrop * widthRatio) / 2,
                  widthCrop * widthRatio,
                  heightCrop * heightRatio,
                );

                final copyImage = Utils.cropImage(
                  src: src,
                  x: newRect.left.floor(),
                  y: newRect.top.floor(),
                  w: newRect.width.floor(),
                  h: newRect.height.floor(),
                );

                setState(() {
                  data = Uint8List.fromList(img.encodePng(copyImage));
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
