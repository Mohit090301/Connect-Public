import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/views/show_image.dart';
import 'package:image_picker/image_picker.dart';

class GroupInfo extends StatefulWidget {
  String groupName;
  List<dynamic> users;
  String groupId;
  bool isWhite;
  String groupPicUrl;
  GroupInfo({this.groupName, this.users, this.isWhite, this.groupId, this.groupPicUrl});

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  File image;
  String uploadedFileURL;
  final picker = ImagePicker();
  bool profilePicUploading;

  @override
  void initState() {
    profilePicUploading = false;
    print('Init state called');

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
    await dataBaseMethods.updateGroupPicUrl(downloadUrl, widget.groupId);
    print(downloadUrl.toString());
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
      widget.groupPicUrl = downloadUrl;
      profilePicUploading = false;
    });
  }

  removeProfilePic(context) async {
    await dataBaseMethods.updateGroupPicUrl("", widget.groupId);
    print("Done");
    setState(() {
      widget.groupPicUrl = "";
    });
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
          'Group Info',
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
          Navigator.pop(context, widget.groupPicUrl);
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
                  height: 150,
                  child: Center(
                    child: Stack(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: widget.groupPicUrl != null && widget.groupPicUrl != ""
                                        ? CachedNetworkImageProvider(widget.groupPicUrl)
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
                                color: Colors.black26,
                                height: 150,
                                width: 150,
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
                    if (widget.groupPicUrl != null && widget.groupPicUrl != "") {
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
                              imageUrl: widget.groupPicUrl,
                              appBarText: Constants.myName,
                              tag: Constants.myName,
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
                'Group Name',
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
                widget.groupName,
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
                'Members',
                style: TextStyle(
                  color: widget.isWhite ? Colors.black : Colors.grey,
                  letterSpacing: 2.0,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 50,
                  height: MediaQuery.of(context).size.height/3 - 30,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: widget.users.length,
                    itemBuilder: (context, index){
                      return UserTile(
                        username: widget.users[index],
                        isWhite: widget.isWhite,
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  String username;
  bool isWhite;
  UserTile({this.username, this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Text(
        username,
        style: TextStyle(
          color: isWhite ? Colors.black : Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}

