import 'dart:io';

import 'package:faulty_vaulty/models/backed_file.dart';
import 'package:faulty_vaulty/utils.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class FileViewWidget extends StatefulWidget {
  final BackedFile backedFile;
  const FileViewWidget({super.key, required this.backedFile});

  @override
  State<FileViewWidget> createState() => _FileViewWidgetState();
}

class _FileViewWidgetState extends State<FileViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            OpenFile.open(widget.backedFile.file.path);
          },
          title: Text(
            p.basenameWithoutExtension(widget.backedFile.file.path),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  p
                      .extension(widget.backedFile.file.path)
                      .replaceAll(".", "")
                      .toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: getFileSize(file: File(widget.backedFile.file.path)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      formatBytes(snapshot.data!),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: Theme.of(context).hoverColor,
        ),
      ],
    );
  }
}
