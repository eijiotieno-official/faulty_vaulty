import 'package:faulty_vaulty/pages/backing_page.dart';
import 'package:faulty_vaulty/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoVideoPickerPage extends StatefulWidget {
  const PhotoVideoPickerPage({super.key});

  @override
  State<PhotoVideoPickerPage> createState() => _PhotoVideoPickerPageState();
}

class _PhotoVideoPickerPageState extends State<PhotoVideoPickerPage> {
  AssetPathEntity? currentAlbum;
  List<AssetPathEntity> albums = [];
  Future<void> fetchAlbums() async {
    List<AssetPathEntity> availableAlbums =
        await PhotoManager.getAssetPathList(type: RequestType.common);
    if (availableAlbums.isNotEmpty) {
      setState(() {
        albums.addAll(availableAlbums);
        currentAlbum = availableAlbums.first;
      });
    }
  }

  List<Asset> assets = [];
  int currentPage = 0;
  int previousPage = 0;
  void fetchAssets() async {
    previousPage = currentPage;
    List<AssetEntity> loaded = await currentAlbum!.getAssetListPaged(
      page: currentPage,
      size: 60,
    );
    List<Asset> temp = [];
    for (var a in loaded) {
      Widget widget = Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Theme.of(context).hoverColor,
            ),
          ),
          Positioned.fill(
            child: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              fit: BoxFit.cover,
              image: AssetEntityImageProvider(
                a,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
              ),
              imageErrorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error_rounded,
                    color: Colors.redAccent,
                  ),
                );
              },
            ),
          ),
          if (a.type == AssetType.video)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    child: Text(
                      formatDuration(a.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
      temp.add(Asset(
        assetEntity: a,
        widget: widget,
      ));
    }
    setState(() {
      assets.addAll(temp);
      currentPage++;
    });
  }

  @override
  void initState() {
    fetchAlbums().then(
      (_) {
        fetchAssets();
      },
    );
    super.initState();
    scrollController.addListener(
      () {
        if (scrollController.position.axisDirection == AxisDirection.down) {
          if (scrollController.position.pixels /
                  scrollController.position.maxScrollExtent >
              0.33) {
            if (previousPage != currentPage) {
              fetchAssets();
            }
          }
        }
      },
    );
  }

  ScrollController scrollController = ScrollController();

  List<Asset> selectedAssets = [];
  void selectAsset({required Asset asset}) {
    bool contains = selectedAssets
        .any((element) => element.assetEntity.id == asset.assetEntity.id);
    if (contains) {
      setState(() {
        selectedAssets.removeWhere(
            (element) => element.assetEntity.id == asset.assetEntity.id);
      });
    } else {
      setState(() {
        selectedAssets.add(asset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<AssetPathEntity>(
          value: currentAlbum,
          isDense: true,
          isExpanded: false,
          padding: const EdgeInsets.all(0),
          borderRadius: BorderRadius.circular(10),
          underline: const SizedBox.shrink(),
          onChanged: (AssetPathEntity? value) async {
            setState(() {
              currentAlbum = value;
              currentPage = 0;
              previousPage = 0;
              assets.clear();
            });
            fetchAssets();
            scrollController.animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          },
          items: albums
              .map<DropdownMenuItem<AssetPathEntity>>((AssetPathEntity album) {
            return DropdownMenuItem<AssetPathEntity>(
              value: album,
              child: Text(
                album.name == "" ? "0" : album.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
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
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  Asset asset = assets[index];
                  bool selected = selectedAssets.any((element) =>
                      element.assetEntity.id == asset.assetEntity.id);
                  return GestureDetector(
                    onTap: () {
                      selectAsset(asset: asset);
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: selected
                              ? const EdgeInsets.all(15)
                              : const EdgeInsets.all(0),
                          child: asset.widget,
                        ),
                        if (selected)
                          Positioned(
                              child: Container(
                                  color: Colors.black.withOpacity(0.3))),
                        if (selected)
                          const Center(
                            child: Icon(Icons.check_circle_rounded,
                                color: Colors.white),
                          ),
                      ],
                    ),
                  );
                },
                itemCount: assets.length,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedAssets.isEmpty
          ? const SizedBox.shrink()
          : FloatingActionButton(
              onPressed: () async {
                Get.to(BackingPage(assets: selectedAssets, files: const []));
              },
              child: const Icon(
                Icons.check_rounded,
                size: 30,
              ),
            ),
    );
  }
}

class Asset {
  AssetEntity assetEntity;
  Widget widget;

  Asset({required this.assetEntity, required this.widget});
}
