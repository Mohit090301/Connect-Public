import 'package:date_time_format/date_time_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

double download = 0.0;
String downloadingStr = "No Data";
class PdfViewer extends StatefulWidget {
  String pdfUrl;
  bool isWhite;

  PdfViewer({this.pdfUrl, this.isWhite});

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool downloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        backgroundColor: widget.isWhite ? Colors.teal[700] : Colors.teal[900],
        actions: [
          InkWell(
              onTap: () async {
                Dio dio = Dio();
                String fileName = "CNT";
                String todaysDate = DateTimeFormat.format(DateTime.now())
                    .toString()
                    .substring(0, 10)
                    .split('-')
                    .reversed
                    .join('-');
                print(todaysDate);
                String day = todaysDate.substring(0, 2);
                String month = todaysDate.substring(3, 5);
                String year = todaysDate.substring(8, 10);
                print(day + month + year);
                todaysDate = day + month + year;
                int timeStamp = DateTime.now().millisecondsSinceEpoch;
                print(timeStamp);
                String tStamp = timeStamp.toString().substring(10, 13);
                print(tStamp);
                fileName = fileName + todaysDate + tStamp;
                setState(() {
                  downloading = true;
                  download = 0.03;
                });
                var response = await dio.download(widget.pdfUrl,
                    "/storage/emulated/0/Download/${fileName}.pdf", onReceiveProgress: (rec, total){
                  setState(() {
                    download = (rec/total);
                    print(download);
                    downloadingStr = "Downloading PDF : " + (download).toStringAsFixed(0);
                  });
                    });
                setState(() {
                  downloading = false;
                });
                print(response.data);
                final snackBar = SnackBar(
                  content: Text(
                    "PDF downloaded Successfully!!",
                    style: TextStyle(color: Colors.white),
                  ),
                  duration: Duration(milliseconds: 900),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Icon(Icons.download_rounded)),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            key: _pdfViewerKey,
          ),
          downloading ? Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: 100,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircularProgressIndicator(value: download,),
                  SizedBox(height: 10,),
                  Text(
                      (download*100).toStringAsFixed(0) + " %",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black
                    ),
                  )
                ],
              ),
            ),
          ) : Container()
        ],
      ),
    );
  }
}
