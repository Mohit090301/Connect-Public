import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/views/group_info.dart';
import 'package:flutter_chat_app/views/show_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String whitebg;
  final String blackbg;
  final String groupName;
  String groupPicUrl;
  final bool isWhite;
  final List<dynamic> receivedBy;

  GroupChatScreen(
      {this.groupId,
      this.groupName,
      this.isWhite,
      this.blackbg,
      this.whitebg,
      this.groupPicUrl,
      this.receivedBy});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  TextEditingController messageController = new TextEditingController();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  final dateTime = DateTime.now();
  Stream chatMessageStream;
  AppLifecycleState state;
  String userStatus = "";
  String lastMessage = "";
  String lastMessagetime = "";
  String lastMessageTimeStamp = "";
  String sendBy = "";
  String useremail;
  bool isLastMsgSeen;
  File image;
  String uploadedFileURL;
  final picker = ImagePicker();
  String imageUrl;
  bool loading = false;

  Widget ChatMessageList() {
    print(widget.receivedBy);
    print("called chat message list");
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.docs.length >= 1) {
          lastMessage = snapshot.data.docs[0].data()["message"];
          lastMessageTimeStamp =
              snapshot.data.docs[0].data()["time"].toString();

          lastMessagetime = snapshot.data.docs[0].data()["msgTime"];
          sendBy = snapshot.data.docs[0].data()["sendBy"];
        }
        return snapshot.hasData && snapshot.data.docs.length >= 1
            ? Container(
                padding: EdgeInsets.only(bottom: 58),
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data.docs[index].data()["message"],
                      isSendByMe: snapshot.data.docs[index].data()["sendBy"] ==
                          Constants.myName,
                      sendBy: snapshot.data.docs[index].data()["sendBy"],
                      isNextMsgSendByMe: index > 0
                          ? snapshot.data.docs[index - 1].data()["sendBy"] ==
                              Constants.myName
                          : false,
                      msgTime: snapshot.data.docs[index].data()["msgTime"],
                      lastMsg: snapshot.data.docs[0].data()["message"],
                      lastMsgDate: snapshot.data.docs.length >= 1
                          ? snapshot.data.docs[index].data()["msgDate"]
                          : "",
                      compare: index < snapshot.data.docs.length - 1
                          ? snapshot.data.docs[index + 1].data()["msgDate"]
                          : "",
                      compareMsg: index < snapshot.data.docs.length - 1
                          ? snapshot.data.docs[index + 1].data()["message"]
                          : "",
                      isLastMessageSeen:
                          isLastMsgSeen == null ? false : isLastMsgSeen,
                      groupName: widget.groupName,
                      //chatRoomId: widget.chatRoomId,
                      isWhite: widget.isWhite,
                      isImage: snapshot.data.docs[index].data()["isImage"],
                      receivedBy: widget.receivedBy,
                    );
                  },
                ),
              )
            : Container();
      },
    );
  }

  @override
  sendMessage() async {
    print("send messsage called");
    List<String> receivedBy;

    if (messageController.text.isNotEmpty) {
      int timeStamp = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "receivedBy": widget.receivedBy,
        "time": timeStamp,
        "msgTime": DateFormat.jm().format(DateTime.now()),
        "msgDate": DateTimeFormat.format(dateTime),
        "groupName": widget.groupName
      };

      messageController.text = "";
      await dataBaseMethods.addGroupMessages(widget.groupId, messageMap);
    }
  }

  Future pickImageGallery(context) async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      uploadFile(context);
      print("URL added");
    }
    setState(() {});
  }

  Future pickImageCamera(context) async {
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 50);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      uploadFile(context);
      print("URL added");
    }
    setState(() {});
  }

  Future uploadFile(context) async {
    setState(() {
      loading = true;
    });
    var r = Random();
    String imageName =
        String.fromCharCodes(List.generate(20, (index) => r.nextInt(33) + 89));
    print(imageName);
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child(widget.groupName + "." + Constants.myName + imageName)
        .putFile(image)
        .whenComplete(() {
      print("complete");
    });
    var downloadUrl = await snapshot.ref.getDownloadURL();
    print(downloadUrl.toString());
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> messageMap = {
      "message": downloadUrl,
      "sendBy": Constants.myName,
      "time": timeStamp,
      "msgTime": DateFormat.jm().format(DateTime.now()),
      "msgDate": DateTimeFormat.format(dateTime),
      "isImage": true,
      "receivedBy": widget.receivedBy,
      "groupName": widget.groupName
    };

    await dataBaseMethods.addGroupMessages(widget.groupId, messageMap);

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    dataBaseMethods.getGroupMessages(widget.groupId).then((value) {
      setState(() {
        print(value.toString() + " .... ");
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isWhite ? Colors.grey[100] : Colors.black45,
      appBar: AppBar(
        leadingWidth: 35,
        backgroundColor: widget.isWhite ? Colors.teal[700] : Colors.teal[900],
        title: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupInfo(
                      groupName: widget.groupName,
                      users: widget.receivedBy,
                      isWhite: widget.isWhite,
                      groupId: widget.groupId,
                      groupPicUrl: widget.groupPicUrl,
                    ))).then((value) {
                      setState(() {
                        widget.groupPicUrl = value;
                      });
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image:
                        widget.groupPicUrl != null && widget.groupPicUrl != ""
                            ? CachedNetworkImageProvider(widget.groupPicUrl)
                            : AssetImage('assets/empty_profile.png'),
                  ),
                  color: Colors.teal[900],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        brightness: Brightness.dark,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: widget.isWhite
                ? widget.whitebg == "" || widget.whitebg == null
                    ? AssetImage('assets/day2.jpg')
                    : AssetImage('assets/${widget.whitebg}')
                : widget.blackbg == "" || widget.blackbg == null
                    ? AssetImage('assets/night.jpeg')
                    : AssetImage('assets/${widget.blackbg}'),
            fit: BoxFit.cover,
          )),
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              ChatMessageList(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 95,
                  ),
                  Container(
                    // alignment: Alignment(0, 0.98),
                    width: (MediaQuery.of(context).size.width - 10) * 0.85,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: widget.isWhite
                            ? Colors.grey[100]
                            : Colors.teal[100],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (String s) async {
                                //await setTypingStatus(s);
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: messageController,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type message...',
                                hintStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          messageController.text == ""
                              ? GestureDetector(
                                  onTap: () {
                                    pickImageCamera(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    height: 40,
                                    width: 30,
                                    child: Icon(
                                      CupertinoIcons.camera_fill,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                          GestureDetector(
                            onTap: () {
                              pickImageGallery(context);
                            },
                            child: Container(
                              //color: Colors.black,
                              padding: EdgeInsets.all(8),
                              height: 40,
                              width: 30,
                              child: Icon(
                                Icons.image,
                                size: 25,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      width: (MediaQuery.of(context).size.width - 10) * 0.14,
                      decoration: BoxDecoration(
                          color: widget.isWhite
                              ? Colors.teal[700]
                              : Colors.teal[300],
                          shape: BoxShape.circle),
                      height: 50,
                      child: Icon(
                        Icons.send_rounded,
                        size: 30,
                        color: widget.isWhite
                            ? Colors.grey[300]
                            : Colors.grey[200],
                      ),
                    ),
                  )
                ],
              ),
              loading
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final String message;
  final bool isSendByMe;
  final String sendBy;
  final bool isNextMsgSendByMe;
  final String msgTime;
  final String lastMsg;
  String lastMsgDate = "";
  String compare = "";
  String compareMsg = "";
  bool isLastMessageSeen;
  bool isWhite;
  DateTime diffDate;
  bool isImage;
  String groupName;
  List<dynamic> receivedBy;
  MessageTile(
      {this.message,
      this.isSendByMe,
      this.msgTime,
      this.lastMsg,
      this.lastMsgDate,
      this.compare,
      this.compareMsg,
      this.isLastMessageSeen,
      this.isWhite,
      this.isNextMsgSendByMe,
      this.isImage,
      this.groupName,
      this.sendBy,
      this.receivedBy}) {

    print("Message Tile called");
    if (compare != null && compare != "") {
      compare = compare.substring(0, 10);
      compare = compare.split('-').reversed.join('-');
    }
    if (lastMsgDate != null && lastMsgDate != "") {
      lastMsgDate = lastMsgDate.substring(0, 10);
      lastMsgDate = lastMsgDate.split('-').reversed.join('-');
      diffDate = DateFormat('d-M-yyyy').parse(lastMsgDate);
    }
  }

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  Stream chatMessageStream;
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  Map<String, Color> uniqueColor = {"Mohit Mundra" : Colors.deepOrangeAccent, "Prachii" : Colors.amberAccent, "Sansku Modi": Colors.blue[400], "manav": Colors.lightGreenAccent};
  int i = 0;
  @override
  void initState() {
    List<Color> col = [Colors.black, Colors.yellowAccent, Colors.red, Colors.blue];

    //decryptMsg(widget.message);
    dataBaseMethods.getLastMessageSeen().then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });

    super.initState();
  }

  void findSeen() async {}

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("did change app life cycle called");
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String todaysDate = DateTimeFormat.format(DateTime.now())
        .toString()
        .substring(0, 10)
        .split('-')
        .reversed
        .join('-');
    int diff = DateTime.now().difference(widget.diffDate).inDays;
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.lastMsgDate != null &&
                      widget.lastMsgDate != "" &&
                      widget.compare != null
                  ? widget.lastMsgDate != widget.compare
                      ? 5
                      : 0
                  : 0,
            ),
            Container(
              width: 83,
              height: widget.lastMsgDate != null &&
                      widget.lastMsgDate != "" &&
                      widget.compare != null
                  ? widget.lastMsgDate != widget.compare
                      ? 17
                      : 0
                  : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: widget.isWhite
                    ? Colors.blue[400].withOpacity(0.6)
                    : Colors.blue[200].withOpacity(0.4),
              ),
              child: Center(
                child: Text(
                  widget.lastMsgDate != null &&
                          widget.lastMsgDate != "" &&
                          widget.compare != null
                      ? widget.lastMsgDate != widget.compare
                          ? widget.lastMsgDate == todaysDate
                              ? "Today"
                              : diff == 1
                                  ? "Yesterday"
                                  : widget.lastMsgDate
                          : ""
                      : "",
                  style: TextStyle(
                    fontSize: widget.lastMsgDate != null &&
                            widget.lastMsgDate != "" &&
                            widget.compare != null
                        ? widget.lastMsgDate != widget.compare
                            ? 14.5
                            : 0
                        : 0,
                    color: widget.isWhite ? Colors.black : Colors.white70,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: widget.lastMsgDate != null &&
                      widget.lastMsgDate != "" &&
                      widget.compare != null
                  ? widget.lastMsgDate != widget.compare
                      ? 5
                      : 0
                  : 0,
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(
              left: widget.isSendByMe ? 80 : 0,
              right: widget.isSendByMe ? 0 : 80),
          alignment:
              widget.isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        widget.isImage != null && widget.isImage ? 5 : 10,
                    vertical: widget.isImage != null && widget.isImage ? 5 : 7),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: widget.isWhite
                            ? widget.isSendByMe
                                ? [
                                    Colors.teal[600].withOpacity(0.6),
                                    Colors.teal[600].withOpacity(0.8),
                                    Colors.teal[600].withOpacity(0.95)
                                  ]
                                : [
                                    Colors.grey[800].withOpacity(0.95),
                                    Colors.grey[800].withOpacity(0.8),
                                    Colors.grey[800].withOpacity(0.5)
                                  ]
                            : widget.isSendByMe
                                ? [
                                    Colors.teal[600].withOpacity(0.15),
                                    Colors.teal[600].withOpacity(0.53),
                                    Colors.teal[600].withOpacity(0.8)
                                  ]
                                : [
                                    Colors.grey[800].withOpacity(0.85),
                                    Colors.grey[800].withOpacity(0.53),
                                    Colors.grey[800].withOpacity(0.15)
                                  ]),
                    borderRadius: widget.isSendByMe
                        ? BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          )
                        : BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          )),
                child: Column(
                  crossAxisAlignment: widget.isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    !widget.isSendByMe
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 2),
                            child: Text(widget.sendBy,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: uniqueColor[widget.sendBy] == null ? Colors.pink : uniqueColor[widget.sendBy],
                                  letterSpacing: 0.3,
                                )),
                          )
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                    widget.isImage == null || !widget.isImage
                        ? SelectableText(
                            widget.message != null ? widget.message : "NUll",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.start,
                            enableInteractiveSelection: true,
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowImage(
                                            imageUrl: widget.message,
                                            appBarText: widget.isSendByMe
                                                ? "You"
                                                : widget.groupName,
                                            tag: widget.message,
                                          )));
                            },
                            child: Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width / 1.5,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      widget.message),
                                ),
                                color: widget.isWhite
                                    ? Colors.transparent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                    !widget.isSendByMe
                        ? Container(
                            child: Text(
                              widget.msgTime,
                              style: TextStyle(
                                color: widget.isWhite
                                    ? Colors.grey[400]
                                    : Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          )
                        : StreamBuilder(
                            stream: chatMessageStream,
                            builder: (context, snapshot) {
                              if (!widget.isLastMessageSeen) findSeen();
                              return Container(
                                width:
                                    widget.message == widget.lastMsg ? 57 : 57,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.msgTime,
                                      style: TextStyle(
                                        color:
                                            Colors.grey[100].withOpacity(0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                  ],
                                ),
                              );
                            }),
                  ],
                ),
              ),
              SizedBox(
                height: widget.isSendByMe == widget.isNextMsgSendByMe ? 1 : 5,
              )
            ],
          ),
        ),
      ],
    );
  }
}
