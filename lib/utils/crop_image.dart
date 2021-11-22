import 'dart:io';

import 'package:image_cropper/image_cropper.dart';

class Utils {
  static Future<File?> cropImage(String path) async {
    File? cropFile = await ImageCropper.cropImage(
      sourcePath: path,
      aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
      androidUiSettings: const AndroidUiSettings(
        lockAspectRatio: true,
        initAspectRatio: CropAspectRatioPreset.ratio5x3,
      ),
    );
    return cropFile;
  }
}
