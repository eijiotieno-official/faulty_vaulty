import 'dart:io';

import 'package:faulty_vaulty/enum/backed_type.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';

class FileServices {
  static Future<Directory?> get appStorageDirectory async {
    return await getExternalStorageDirectory();
  }

  static Future<File> userPasscodeFile() async {
    Directory? directory = await appStorageDirectory;
    String path = "${directory!.path}/user.txt";
    File file = File(path);
    if (await file.exists()) {
      return file;
    } else {
      await file.create(recursive: true);
      return file;
    }
  }

  static Future backupFile({required File file}) async {
    Directory? directory = await appStorageDirectory;
    String name = p.basename(file.path);
    String path = "${directory!.path}/backed/$name";
    bool exists = await File(path).exists();
    if (exists == false) {
      await File(path).create(recursive: true);
      await file.copy(path);
    }
  }

  static Future<List<FileSystemEntity>> fetchFiles() async {
    Directory? directory = await appStorageDirectory;
    Directory folder = Directory("${directory!.path}/backed");
    bool exists = await folder.exists();
    List<FileSystemEntity> files = [];
    if (exists == false) {
      await folder.create(recursive: true);
    } else {
      files = folder.listSync();
    }
    return files;
  }

  static Future<Uint8List?> getVideoThumbnail({required File file}) async {
    return await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.PNG,
      timeMs: 10,
      quality: 50,
    );
  }

  static BackedType getBackedType({required File file}) {
    final mimeType = lookupMimeType(file.path);
    final parts = mimeType!.split("/");
    return parts[0] == 'image'
        ? BackedType.image
        : parts[0] == 'video'
            ? BackedType.video
            : BackedType.file;
  }
}
