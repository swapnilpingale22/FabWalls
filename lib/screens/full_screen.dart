import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../models/wallpapers_model.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class FullScreenWallpaper extends StatefulWidget {
  final List<Hit> hits;
  final int index;
  const FullScreenWallpaper({
    super.key,
    required this.hits,
    required this.index,
  });

  @override
  State<FullScreenWallpaper> createState() => _FullScreenWallpaperState();
}

class _FullScreenWallpaperState extends State<FullScreenWallpaper> {
  //
  //
  Future<void> downloadAndSaveImage(
      String imageUrl, int id, int imageWidth, int imageHeight) async {
    await FileDownloader.downloadFile(
      url: imageUrl,
      name: 'FabWalls_${id}_${imageWidth}x${imageHeight}_HD',
      onDownloadCompleted: (String path) {
        print('FILE DOWNLOADED TO PATH: $path');
      },
      onDownloadError: (String error) {
        print('DOWNLOAD ERROR: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black87,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: () async {
                final imageUrl = widget.hits[widget.index].largeImageUrl;
                try {
                  await downloadAndSaveImage(
                    imageUrl,
                    widget.hits[widget.index].id,
                    widget.hits[widget.index].imageWidth,
                    widget.hits[widget.index].imageHeight,
                  );
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image downloaded successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed to download image.  ${e.toString()}'),
                    ),
                  );
                  print(e.toString());
                }
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Colors.black45,
                ),
              ),
              icon: const Icon(
                Icons.download,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Hero(
          tag: 'tag_${widget.hits[widget.index].id}',
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: widget.hits[widget.index].webformatUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
