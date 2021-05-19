import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/database.dart';

class ChangeBackgroundImage extends StatefulWidget {
  bool value;
  String image1, image2, image3, image4;

  ChangeBackgroundImage(
      {this.value, this.image1, this.image2, this.image3, this.image4});

  @override
  _ChangeBackgroundImageState createState() => _ChangeBackgroundImageState();
}

class _ChangeBackgroundImageState extends State<ChangeBackgroundImage> {
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  List<bool> loading = [false, false, false, false];
  String blackUrl = "";
  String whiteUrl = "";

  updateBackgroundImage(String image, context, loadingNum) async {
    if(widget.value)
      whiteUrl = image;
    else
      blackUrl = image;
    setState(() {
      loading[loadingNum] = true;
    });
    await dataBaseMethods.updateBackgroundImage(image, widget.value);
    setState(() {
      loading[loadingNum] = false;
    });
    final snackBar = SnackBar(
      content: Text(
        widget.value ? "Wallpaper changed for white theme!!" : "Wallpaper changed for black theme!!",
        style: TextStyle(color: widget.value ? Colors.white : Colors.black),
      ),
      duration: Duration(milliseconds: 1200),
      backgroundColor: !widget.value ? Colors.white : Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print(width);
    print(height);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: widget.value ? Colors.teal[700] : Colors.teal[900],
            title: Text(
              'Wallpapers',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            brightness: Brightness.dark,
            centerTitle: false,
          ),
          body: WillPopScope(
            onWillPop: () async{
              Navigator.pop(context, [whiteUrl, blackUrl]);
              return false;
            },
            child: Container(
              color: !widget.value ? Colors.black12 : Colors.white70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 2 - 15,
                    width: width - 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            updateBackgroundImage(widget.image1, context, 0);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/${widget.image1}')),
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    color:
                                    loading[0] ? Colors.black45 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                              Center(
                                child:
                                    loading[0] ? CircularProgressIndicator() : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            updateBackgroundImage(widget.image2, context, 1);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/${widget.image2}')),
                                    borderRadius: BorderRadius.circular(20)),
                                // padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    color:
                                    loading[1] ? Colors.black45 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                              Center(
                                child:
                                loading[1] ? CircularProgressIndicator() : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    //height: MediaQuery.of(context).size.height/2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            updateBackgroundImage(widget.image3, context, 2);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/${widget.image3}')),
                                    borderRadius: BorderRadius.circular(20)),
                                // padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    color:
                                    loading[2] ? Colors.black45 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                              Center(
                                child:
                                loading[2] ? CircularProgressIndicator() : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            updateBackgroundImage(widget.image4, context, 3);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage('assets/${widget.image4}')),
                                    borderRadius: BorderRadius.circular(20)),
                                //padding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              Container(
                                height: height / 2 - 130,
                                width: width / 2 - 30,
                                decoration: BoxDecoration(
                                    color:
                                    loading[3] ? Colors.black45 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                              Center(
                                child:
                                loading[3] ? CircularProgressIndicator() : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
