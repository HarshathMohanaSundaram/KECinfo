import 'dart:io';

import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewScreen extends StatefulWidget {
  final String imagePath;
  final ImageProviderCategory imageProviderCategory;
  ImageViewScreen({required this.imagePath, required this.imageProviderCategory,});

  @override
  _ImageViewScreenState createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: PhotoView(
              imageProvider: _getParticularImage(),
              enableRotation: true,
              initialScale: null,
              loadingBuilder: (context,event) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, obj, stackTrace) =>const Center(
                child: Text("Image Not Found",
                  style: TextStyle(
                      fontSize: 23.0,
                      color: Colors.red,
                      fontFamily: "Lobster",
                      letterSpacing:1.0
                  ),),
              ),
            ),
          ),
        )
    );
  }

  _getParticularImage() {
    switch(widget.imageProviderCategory){
      case ImageProviderCategory.FileImage:
          return FileImage(File(widget.imagePath));
      case ImageProviderCategory.ExactAssetImage:
          return ExactAssetImage(widget.imagePath);
      case ImageProviderCategory.NetworkImage:
          return NetworkImage(widget.imagePath);
    }
  }
}
