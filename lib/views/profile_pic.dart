import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/views/show_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePic extends StatefulWidget {
  String email;
  bool isWhite;


  ProfilePic({this.email, this.isWhite});

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  File image;
  String uploadedFileURL;
  final picker = ImagePicker();
  String imageUrl;
  bool profilePicUploading;

  @override
  void initState() {
    profilePicUploading = false;
    print('Init state called');
    dataBaseMethods.getUserByUsername(Constants.myName).then((snapshot) {
      setState(() {
        imageUrl = snapshot.docs[0].data()["profilePicURL"];
        print(imageUrl);
      });
    });

    // setOnlineStatus();
    super.initState();
  }

  setOnlineStatus() async {
    Map<String, String> statusMap = {"status": "online"};
    await dataBaseMethods.setStatus(Constants.myName, statusMap);
  }

  Future pickImage(context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      var decodedImage = await decodeImageFromList(image.readAsBytesSync());
      uploadFile(context);
      print("URL added");
    }
    setState(() {});
  }

  Future uploadFile(context) async {
    setState(() {
      profilePicUploading = true;
    });
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child(Constants.myName)
        .putFile(image)
        .whenComplete(() {
      print("complete");
    });
    var downloadUrl = await snapshot.ref.getDownloadURL();
    print(downloadUrl.toString());
    await dataBaseMethods.updateProfilePicUrl(downloadUrl.toString(),
        Constants.myName);
    await dataBaseMethods.updateUrlEverywhere(downloadUrl.toString(),
        Constants.myName);
    print('File Uploaded');
    final snackBar = SnackBar(
      content: Text(
        "Profile Pic Updated Successfully!!",
        style: TextStyle(color: widget.isWhite ? Colors.white : Colors.black),
      ),
      duration: Duration(milliseconds: 900),
      backgroundColor: widget.isWhite ? Colors.black : Colors.white,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      imageUrl = downloadUrl;
      profilePicUploading = false;
    });
  }

  removeProfilePic(context) async {
    await dataBaseMethods.updateProfilePicUrl("", Constants.myName);
    await dataBaseMethods.updateUrlEverywhere("", Constants.myName);
    print("Done");
    final snackBar = SnackBar(
      content: Text("Profile Pic Removed Successfully!!"),
      duration: Duration(milliseconds: 900),
      backgroundColor: Colors.white30,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: widget.isWhite ? Colors.teal[700] : Colors.teal[900],
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: false,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 40, 30, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  await pickImage(context);
                  print("add profile pic");
                },
                child: Container(
                  height: 200,
                  child: Center(
                    child: Stack(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: imageUrl != null && imageUrl != ""
                                        ? CachedNetworkImageProvider(imageUrl)
                                        : AssetImage('assets/empty_pic.jpeg'),
                                  ),
                                  color: widget.isWhite
                                      ? Colors.teal[700]
                                      : Colors.teal[900],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                color: imageUrl == null || imageUrl == ""
                                    ? Colors.black38
                                    : Colors.transparent,
                                height: 200,
                                width: 200,
                                child: profilePicUploading
                                    ? CircularProgressIndicator()
                                    : Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (imageUrl != null && imageUrl != "") {
                      print("Removing DP");
                      profilePicUploading = true;
                      setState(() {});
                      await removeProfilePic(context);
                      profilePicUploading = false;
                      setState(() {});
                    } else {
                      final snackBar = SnackBar(
                        content: Text("No Profile Pic To Remove!!"),
                        duration: Duration(milliseconds: 500),
                        backgroundColor: Colors.white30,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Text(
                    "Remove Profile Photo",
                    style: TextStyle(
                        color: widget.isWhite
                            ? Colors.blue[700]
                            : Colors.lightBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowImage(
                                imageUrl: imageUrl,
                                appBarText: Constants.myName,
                            )));
                  },
                  child: Text(
                    "View Profile Photo",
                    style: TextStyle(
                        color: widget.isWhite
                            ? Colors.blue[700]
                            : Colors.lightBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Divider(
                thickness: 0.5,
                height: 40,
                color: widget.isWhite ? Colors.black : Colors.grey,
              ),
              Text(
                'Username',
                style: TextStyle(
                  color: widget.isWhite ? Colors.black : Colors.grey,
                  letterSpacing: 2.0,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                Constants.myName,
                style: TextStyle(
                  color: widget.isWhite ? Colors.black : Colors.white,
                  letterSpacing: 2.0,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                'Email',
                style: TextStyle(
                  color: widget.isWhite ? Colors.black : Colors.grey,
                  letterSpacing: 2.0,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                widget.email != null ? widget.email : "null",
                style: TextStyle(
                  color: widget.isWhite ? Colors.black : Colors.white,
                  letterSpacing: 2.0,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
