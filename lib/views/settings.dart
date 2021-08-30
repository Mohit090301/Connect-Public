import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/authenticate.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/services/auth.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/views/change_background_image.dart';

class settings extends StatefulWidget {
  bool value;
  bool isSoundEnabled;
  settings({this.value, this.isSoundEnabled});

  @override
  _settingsState createState() => _settingsState();
}

class _settingsState extends State<settings> {
  bool value = false;
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  AuthMethods authMethods = new AuthMethods();
  bool tap = false;
  String blackUrl = "";
  String whiteUrl = "";
  bool isSoundEnabled = true;

  void setTheme(bool value) async {
    print(value);
    await dataBaseMethods.updateUserTheme(Constants.myName, value);
    print("Theme changed successfully");
    final snackBar = SnackBar(
      content: Text(
        "Theme Changed Successfully!!",
        style: TextStyle(color: value ? Colors.white : Colors.black),
      ),
      duration: Duration(milliseconds: 900),
      backgroundColor: !value ? Colors.white : Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    print(widget.value);
    // TODO: implement initState
    setState(() {
      value = widget.value;
      isSoundEnabled = widget.isSoundEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 30;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: value ? Colors.teal[700] : Colors.teal[900],
        title: Text(
          'Settings',
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
          Navigator.pop(context, [value, whiteUrl, blackUrl, isSoundEnabled]);
          return false;
        },
        child: Container(
          color: value ? Colors.white : Colors.black45,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 0.75 * width,
                    child: Text(
                      "Light Theme",
                      style: TextStyle(
                        color: value ? Colors.black : Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    width: 0.25 * width,
                    child: Switch(
                      value: value,
                      onChanged: (value) {
                        setState(() {
                          setTheme(value);
                          this.value = value;
                        });
                      },
                      inactiveTrackColor: Colors.grey,
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 0.75 * width,
                      child: Text(
                        "Enable Msg Sent Sound ",
                        style: TextStyle(
                          color: value ? Colors.black : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 0.25 * width,
                      child: Switch(
                        value: isSoundEnabled,
                        onChanged: (isSoundEnabled) {
                          print("SOund");
                          setState((){
                            final snackBar = SnackBar(
                              content: Text(
                                isSoundEnabled ? "Sound Enabled Successfully!" : "Sound Disabled Successfully!",
                                style: TextStyle(color: value ? Colors.white : Colors.black),
                              ),
                              duration: Duration(milliseconds: 900),
                              backgroundColor: !value ? Colors.white : Colors.black,
                            );
                            this.isSoundEnabled = isSoundEnabled;
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          });
                        },
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              Container(
                color: tap ? Colors.grey : Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          tap = true;
                        });
                        if (!value) {
                          //For changing black theme BG image
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeBackgroundImage(
                                        value: value,
                                        image1: "night.jpeg",
                                        image2: "night2.jpg",
                                        image3: "night3.jpg",
                                        image4: "night4.jpg",
                                      ))).then((value) {
                                        blackUrl = value[1];
                            setState(() {
                              tap = false;
                            });
                          });
                        } else {
                          //For changing white theme BG image
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeBackgroundImage(
                                        value: value,
                                        image1: "day5.jpg",
                                        image2: "day2.jpg",
                                        image3: "day3.jpg",
                                        image4: "day4.jpg",
                                      ))).then((value) {
                                        whiteUrl = value[0];
                            setState(() {
                              tap = false;
                            });
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          value ? "Change Wallpaper for Light Theme" : "Change Wallpaper for Dark Theme",
                          style: TextStyle(
                            color: value ? Colors.black : Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    width: 0.75 * width,
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                        color: value ? Colors.black : Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    width: 0.25 * width,
                    child: GestureDetector(
                      onTap: () {
                        authMethods.signOut();
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Authenticate()));
                      },
                      child: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.exit_to_app,
                            color: value ? Colors.black : Colors.white,
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
