import 'dart:io';

import 'package:faulty_vaulty/enum/backed_type.dart';

class BackedFile {
  File file;
  BackedType backedType;

  BackedFile({required this.file, required this.backedType});
}
