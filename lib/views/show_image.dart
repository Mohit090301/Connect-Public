import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

double download = 0;
String downloadingStr = "No Data";
class ShowImage extends StatefulWidget {
  final String imageUrl;
  String appBarText = "";
  String tag;
  ShowImage({this.imageUrl, this.appBarText, this.tag});

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  bool downloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: Text(
            widget.appBarText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,

            ),
          ),
          actions: [
            downloading ? SizedBox(
                    height: 20,
                    width: 40,
                    child: Center(child: CircularProgressIndicator(value: download,))) :InkWell(
                onTap: () async {
                  Dio dio = Dio();
                  String fileName = "CNT_";
                  String todaysDate = DateTimeFormat.format(DateTime.now())
                      .toString()
                      .substring(0, 10)
                      .split('-')
                      .reversed
                      .join('-');
                  print(todaysDate);
                  String day = todaysDate.substring(0, 2);
                  String month = todaysDate.substring(3, 5);
                  String year = todaysDate.substring(6, 10);
                  print(day + month + year);
                  todaysDate = year + month + day;
                  int timeStamp = DateTime.now().millisecondsSinceEpoch;
                  print(timeStamp);
                  String tStamp = timeStamp.toString().substring(10, 13);
                  print(tStamp);
                  fileName = fileName + todaysDate + "_" + tStamp;
                  setState(() {
                    downloading = true;
                    download = 0.03;
                  });
                  var response = await dio.download(widget.imageUrl,
                      "/storage/emulated/0/Download/${fileName}.jpg", onReceiveProgress: (rec, total){
                        setState(() {
                          download = (rec/total);
                        });
                      });
                  setState(() {
                    downloading = false;
                  });
                  print(response.data);
                  final snackBar = SnackBar(
                    content: Text(
                      "Image downloaded Successfully!!",
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: Duration(milliseconds: 900),
                    backgroundColor: Colors.black,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Icon(Icons.download_rounded, size: 30,)),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child:  Container(
                child: PhotoView(
                  imageProvider: widget.imageUrl!="" && widget.imageUrl!=null ? CachedNetworkImageProvider(widget.imageUrl) : AssetImage('assets/empty_profile.png') ,
                  tightMode: true,
                  minScale: 0.1,
                  maxScale: 0.8,
                  disableGestures: widget.imageUrl!="" && widget.imageUrl!=null ? false : true,
                ),
              ),
            ),
          ],
        ));
  }
}
