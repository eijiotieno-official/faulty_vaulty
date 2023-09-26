import 'package:faulty_vaulty/models/backed_file.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  final List<BackedFile> _files = [];
  List<BackedFile> get files => _files;

  Future<void> addFile({required BackedFile backedFile}) async {
    _files.add(backedFile);
    notifyListeners();
  }

  Future<void> removeFile({required BackedFile backedFile}) async {
    _files.remove(backedFile);
    notifyListeners();
  }
}
