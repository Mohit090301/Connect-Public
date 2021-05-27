import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ShowImage extends StatelessWidget {
  final String imageUrl;
  String appBarText = "";
  String tag;
  ShowImage({this.imageUrl, this.appBarText, this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: Text(
            appBarText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,

            ),
          ),
        ),
        body: Center(
          child:  Container(
            child: PhotoView(
              imageProvider: imageUrl!="" && imageUrl!=null ? CachedNetworkImageProvider(imageUrl) : AssetImage('assets/empty_profile.png') ,
              tightMode: true,
              minScale: 0.1,
              maxScale: 0.8,
              disableGestures: imageUrl!="" && imageUrl!=null ? false : true,
            ),
          ),
        ));
  }
}
