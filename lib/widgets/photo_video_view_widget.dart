import 'package:faulty_vaulty/enum/backed_type.dart';
import 'package:faulty_vaulty/models/backed_file.dart';
import 'package:faulty_vaulty/services/file_services.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoVideoViewWidget extends StatefulWidget {
  final BackedFile backedFile;
  const PhotoVideoViewWidget({super.key, required this.backedFile});

  @override
  State<PhotoVideoViewWidget> createState() => _PhotoVideoViewWidgetState();
}

class _PhotoVideoViewWidgetState extends State<PhotoVideoViewWidget> {

  @override
  Widget build(BuildContext context) {
    return widget.backedFile.backedType == BackedType.image
        ? FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            fit: BoxFit.cover,
            image: FileImage(widget.backedFile.file),
            imageErrorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error_rounded,
                  color: Colors.redAccent,
                ),
              );
            },
          )
        : Stack(
            children: [
              FutureBuilder(
                future: FileServices.getVideoThumbnail(
                  file: widget.backedFile.file,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Positioned.fill(
                      child: FadeInImage(
                        placeholder: MemoryImage(kTransparentImage),
                        fit: BoxFit.cover,
                        image: MemoryImage(snapshot.data!),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error_rounded,
                              color: Colors.redAccent,
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
              const Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Iconsax.video5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
