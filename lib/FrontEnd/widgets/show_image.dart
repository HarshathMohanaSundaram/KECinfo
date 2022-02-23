import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  final String imageUrl;
  ShowImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height:size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
