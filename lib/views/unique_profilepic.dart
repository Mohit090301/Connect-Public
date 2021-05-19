import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UniqueProfilePic extends StatefulWidget {
  String chatRoomId;
  bool isWhite;
  String myUrl;

  UniqueProfilePic({this.isWhite, this.chatRoomId, this.myUrl});

  @override
  _UniqueProfilePicState createState() => _UniqueProfilePicState();
}

class _UniqueProfilePicState extends State<UniqueProfilePic> {
  @override
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  File image;
  String uploadedFileURL;
  final picker = ImagePicker();
  String imageUrl;
  bool profilePicUploading;
  String username;

  @override
  void initState() {
    profilePicUploading = false;
    print('Init state called');
    imageUrl = widget.myUrl;
    username = widget.chatRoomId.replaceAll("*", "").replaceAll(Constants.myName, "");
    super.initState();
  }

  setOnlineStatus() async {
    Map<String, String> statusMap = {"status": "online"};
    await dataBaseMethods.setStatus(Constants.myName, statusMap);
  }

  Future uploadFile2(context) async {
    setState(() {
      profilePicUploading = true;
    });
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child(widget.chatRoomId + Constants.myName)
        .putFile(image)
        .whenComplete(() {
      print("complete");
    });
    var downloadUrl = await snapshot.ref.getDownloadURL();
    print(downloadUrl.toString());
    await dataBaseMethods.updateUniqueProfilePic(
        widget.chatRoomId, downloadUrl.toString(), Constants.myName);
    print('File Uploaded');
    final snackBar = SnackBar(
      content: Text(
        "Unique Profile Pic Updated Successfully!!",
        style: TextStyle(
            color: widget.isWhite ? Colors.white : Colors.black
        ),
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

  Future pickImage(context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      uploadFile2(context);
      print("URL added");
    }
    setState(() {});
  }

  removeProfilePic(context) async {
    await dataBaseMethods.updateUniqueProfilePic(
        widget.chatRoomId, "", Constants.myName);
    print("Done");
    final snackBar = SnackBar(
      content: Text(
        "Unique Profile Pic Removed Successfully!!",
        style: TextStyle(
            color: widget.isWhite ? Colors.white : Colors.black
        ),
      ),
      duration: Duration(milliseconds: 900),
      backgroundColor: widget.isWhite ? Colors.black : Colors.white,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      imageUrl = "";
      profilePicUploading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: widget.isWhite ? Colors.teal[700] : Colors.teal[900],
        title: Text(
          'Unique Profile Pic',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        brightness: Brightness.dark,
        centerTitle: false,
      ),
      body: Padding(
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
                      color:
                          widget.isWhite ? Colors.blue[700] : Colors.lightBlue,
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
              'Here you can set unique profile pic. Only "$username" will see this change in your DP while the rest of the users will see your actual DP',
              style: TextStyle(
                color: widget.isWhite ? Colors.black : Colors.grey,
                letterSpacing: 2.0,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
