import 'dart:io';

import 'package:image/image.dart';
import 'package:image/image.dart' as img;

class Utils {
  // static Future<File?> cropImage(String path) async {
  //   File? cropFile = await ImageCropper.cropImage(
  //     sourcePath: path,
  //     aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
  //     androidUiSettings: const AndroidUiSettings(
  //       lockAspectRatio: true,
  //       initAspectRatio: CropAspectRatioPreset.ratio5x3,
  //     ),
  //   );
  //   return cropFile;
  // }

  static Image cropImage(
      {required Image src,
      required int x,
      required int y,
      required int w,
      required int h}) {
    return img.copyCrop(src, x, y, w + 5, h);
  }
}
