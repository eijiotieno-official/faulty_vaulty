import 'dart:io';

import 'package:faulty_vaulty/enum/backed_type.dart';
import 'package:faulty_vaulty/models/backed_file.dart';
import 'package:faulty_vaulty/pages/backing_page.dart';
import 'package:faulty_vaulty/pages/photo_video_picker_page.dart';
import 'package:faulty_vaulty/providers/app_provider.dart';
import 'package:faulty_vaulty/services/file_services.dart';
import 'package:faulty_vaulty/utils.dart';
import 'package:faulty_vaulty/widgets/file_view_widget.dart';
import 'package:faulty_vaulty/widgets/photo_video_view_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    FileServices.fetchFiles().then(
      (files) {
        for (var file in files) {
          BackedFile backedFile = BackedFile(
            file: File(file.path),
            backedType: FileServices.getBackedType(file: File(file.path)),
          );
          appProvider(context: context).addFile(backedFile: backedFile);
        }
      },
    );
    super.initState();
  }

  Future<List<File>> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowCompression: false,
      lockParentWindow: true,
    );

    return result != null ? result.paths.map((e) => File(e!)).toList() : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faulty Vaulty"),
        centerTitle: true,
        bottom: TabBar(
          controller: tabController,
          indicator: MaterialIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          tabs: const [
            Tab(text: "Gallery"),
            Tab(text: "Files"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          galleryTab(),
          fileTab(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.small(
              heroTag: "file",
              onPressed: () async {
                await pickFiles().then(
                  (results) {
                    if (results.isNotEmpty) {
                      Get.to(
                          () => BackingPage(assets: const [], files: results));
                    }
                  },
                );
              },
              child: const Icon(Iconsax.document_text5),
            ),
          ),
          FloatingActionButton(
            heroTag: "gallery",
            onPressed: () {
              Get.to(() => const PhotoVideoPickerPage());
            },
            child: const Icon(Iconsax.gallery5),
          ),
        ],
      ),
    );
  }

  Widget fileTab() => Scaffold(
        body: ListView.builder(
          itemCount: context
              .watch<AppProvider>()
              .files
              .where((element) => element.backedType == BackedType.file)
              .length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            BackedFile backedFile = context.watch<AppProvider>().files[index];
            return FileViewWidget(backedFile: backedFile);
          },
        ),
      );

  Widget galleryTab() => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: CustomScrollView(
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
                  BackedFile backedFile = context
                      .watch<AppProvider>()
                      .files
                      .where((element) => element.backedType != BackedType.file)
                      .toList()[index];
                  return GestureDetector(
                    onTap: () {
                      OpenFile.open(backedFile.file.path);
                    },
                    child: PhotoVideoViewWidget(backedFile: backedFile),
                  );
                },
                itemCount: context
                    .watch<AppProvider>()
                    .files
                    .where((element) => element.backedType != BackedType.file)
                    .length,
              ),
            ],
          ),
        ),
      );
}
