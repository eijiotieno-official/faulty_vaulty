import 'dart:io';

import 'package:faulty_vaulty/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


String formatDuration(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = seconds % 60;

  String formattedDuration = '';

  if (hours > 0) {
    formattedDuration += '${hours.toString().padLeft(2, '0')}:';
  }

  formattedDuration += '${minutes.toString().padLeft(2, '0')}:';
  formattedDuration += remainingSeconds.toString().padLeft(2, '0');

  return formattedDuration;
}

Future<int> getFileSize({required File file}) async => await file.length();

String formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes bytes';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(2)} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

AppProvider appProvider({required BuildContext context}) =>
    Provider.of<AppProvider>(context, listen: false);
