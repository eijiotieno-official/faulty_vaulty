import 'dart:async';
import 'dart:io';

import 'package:faulty_vaulty/models/backed_file.dart';
import 'package:faulty_vaulty/pages/photo_video_picker_page.dart';
import 'package:faulty_vaulty/services/file_services.dart';
import 'package:faulty_vaulty/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:path/path.dart' as p;

class BackingPage extends StatefulWidget {
  final List<Asset> assets;
  final List<File> files;
  const BackingPage({super.key, required this.assets, required this.files});

  @override
  State<BackingPage> createState() => _BackingPageState();
}

class _BackingPageState extends State<BackingPage> {
  List<Asset> assets = [];
  List<File> files = [];

  @override
  void initState() {
    assets.addAll(widget.assets);
    files.addAll(widget.files);
    super.initState();
  }

  ScrollController scrollController = ScrollController();

  removeFile({required File file}) {
    setState(() {
      files.removeWhere((element) => element == file);
    });

    if (files.isEmpty) {
      Get.back();
      Get.back();
    }
  }

  removeAsset({required Asset asset}) {
    setState(() {
      assets.removeWhere(
          (element) => element.assetEntity.id == asset.assetEntity.id);
    });
    if (assets.isEmpty) {
      Get.back();
      Get.back();
    }
  }

  bool locking = false;

  Future lock() async {
    setState(() {
      locking = true;
    });
    Future.delayed(
      Duration(
          seconds: files.isNotEmpty ? files.length + 4 : assets.length + 4),
      () {
        Fluttertoast.showToast(msg: "Successfully locked");
        if (files.isNotEmpty) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
    );
    for (var file in files) {
      await FileServices.backupFile(file: file).then(
        (_) {
          BackedFile backedFile = BackedFile(
            file: file,
            backedType: FileServices.getBackedType(file: file),
          );
          appProvider(context: context).addFile(backedFile: backedFile);
        },
      );
    }
    for (var asset in assets) {
      File? file = await asset.assetEntity.originFile;
      if (file != null) {
        await FileServices.backupFile(file: file).then(
          (_) {
            BackedFile backedFile = BackedFile(
              file: file,
              backedType: FileServices.getBackedType(file: file),
            );
            appProvider(context: context).addFile(backedFile: backedFile);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
        statusBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness:
            Theme.of(context).colorScheme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness:
            Theme.of(context).colorScheme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: files.isNotEmpty ? previewList() : previewGrid(),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (locking)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SimpleCircularProgressBar(
                            progressStrokeWidth: 10,
                            backStrokeWidth: 10,
                            mergeMode: true,
                            backColor: Theme.of(context).hoverColor,
                            progressColors: [
                              Theme.of(context).hoverColor,
                              Theme.of(context).colorScheme.primary
                            ],
                            animationDuration: files.isNotEmpty
                                ? files.length + 3
                                : assets.length + 3,
                          ),
                        ),
                      if (!locking)
                        Center(
                          child: FilledButton(
                            onPressed: () {
                              lock();
                            },
                            child: const Text(
                              "LOCK",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget previewList() => Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: scrollController,
        radius: const Radius.circular(10),
        child: ListView.builder(
          controller: scrollController,
          itemCount: files.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return FilePreviewWidget(
              locking: locking,
              file: files[index],
              function: removeFile,
            );
          },
        ),
      );

  Widget previewGrid() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: scrollController,
          radius: const Radius.circular(10),
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            slivers: [
              SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return PhotoVideoPreviewWidget(
                    locking: locking,
                    asset: assets[index],
                    function: removeAsset,
                  );
                },
                itemCount: assets.length,
              ),
            ],
          ),
        ),
      );
}

class PhotoVideoPreviewWidget extends StatefulWidget {
  final bool locking;
  final Asset asset;
  final Function function;
  const PhotoVideoPreviewWidget(
      {super.key,
      required this.asset,
      required this.function,
      required this.locking});

  @override
  State<PhotoVideoPreviewWidget> createState() =>
      _PhotoVideoPreviewWidgetState();
}

class _PhotoVideoPreviewWidgetState extends State<PhotoVideoPreviewWidget> {
  File? file;
  getFile() async {
    File? f = await widget.asset.assetEntity.originFile;
    setState(() {
      file = f;
    });
  }

  @override
  void initState() {
    getFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Theme.of(context).hoverColor)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: widget.asset.widget),
            if (file != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 5,
                  top: 5,
                ),
                child: Text(
                  p.extension(file!.path).replaceAll(".", "").toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            if (file != null)
              FutureBuilder<int>(
                future: getFileSize(file: file!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 5,
                        bottom: 5,
                      ),
                      child: Text(
                        formatBytes(snapshot.data!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
        if (widget.locking == false)
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                onPressed: () {
                  widget.function(asset: widget.asset);
                },
                icon: const Icon(
                  Icons.close_rounded,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FilePreviewWidget extends StatelessWidget {
  final bool locking;
  final File file;
  final Function function;
  const FilePreviewWidget(
      {super.key,
      required this.file,
      required this.function,
      required this.locking});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            p.basenameWithoutExtension(file.path),
          ),
          subtitle: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  p.extension(file.path).replaceAll(".", "").toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              FutureBuilder<int>(
                future: getFileSize(file: file),
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
          trailing: locking
              ? null
              : IconButton(
                  onPressed: () {
                    function(file: file);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
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
