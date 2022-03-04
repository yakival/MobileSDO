import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/database/ItemModel.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewPage extends StatefulWidget {
  const PhotoViewPage({Key? key}) : super(key: key);

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoViewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Item;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.name!),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: PhotoView(
        imageProvider: FileImage(File(args.localpath!)),
        maxScale: PhotoViewComputedScale.covered * 3.0,
        minScale: PhotoViewComputedScale.contained * 0.8,
        initialScale: PhotoViewComputedScale.covered,
      ),
    );
  }
}
