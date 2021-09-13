import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/views/pdf_viewer.dart';
import 'package:flutter_chat_app/views/play_video.dart';
import 'package:flutter_chat_app/views/show_image.dart';
import 'package:flutter_chat_app/views/show_profile_pic.dart';
import 'package:flutter_chat_app/views/unique_profilepic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

IconData msgIcon;

class ConversationScreen extends StatefulWidget {
  final String username;
  final String chatRoomId;
  final String imageUrl;
  final String mailid;
  final bool isLastMsgSeen;
  final bool isWhite;
  String myUrl;
  final String blackbg;
  final String whitebg;
  final isSoundEnabled;

  ConversationScreen(
      {this.username,
      this.chatRoomId,
      this.imageUrl,
      this.mailid,
      this.isLastMsgSeen,
      this.isWhite,
      this.myUrl,
      this.blackbg,
      this.whitebg,
      this.isSoundEnabled});

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with WidgetsBindingObserver {
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  TextEditingController messageController = new TextEditingController();
  Stream chatMessageStream, statusStream;
  final dateTime = DateTime.now();
  AppLifecycleState state;
  String userStatus = "";
  String lastMessage = "";
  String lastMessagetime = "";
  String lastMessageTimeStamp = "";
  String sendBy = "";
  String useremail;
  bool isLastMsgSeen;
  File image;
  File pdf;
  String uploadedFileURL;
  final picker = ImagePicker();
  String imageUrl;
  bool loading = false;

  Widget ChatMessageList() {
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
        if (sendBy == widget.username) {
          setSeen();
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
                      username: widget.username,
                      chatRoomId: widget.chatRoomId,
                      isWhite: widget.isWhite,
                      isImage: snapshot.data.docs[index].data()["isImage"],
                      isVideo: snapshot.data.docs[index].data()["isVideo"],
                      isPdf: snapshot.data.docs[index].data()["isPdf"],
                    );
                  },
                ),
              )
            : Container();
      },
    );
  }

  find() async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(widget.chatRoomId)
        .get()
        .then((val) {
      isLastMsgSeen = val.data()["seen"];
    });
  }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      setState(() {
        msgIcon = Icons.access_time_rounded;
      });
      if (widget.isSoundEnabled) {
        await AssetsAudioPlayer.playAndForget(
            Audio('assets/msg_sent_sound2.aac', playSpeed: 1.9),
            volume: 1,
            seek: Duration(seconds: 0));
      }
      int timeStamp = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": Constants.myName,
        "time": timeStamp,
        "msgTime": DateFormat.jm().format(DateTime.now()),
        "msgDate": DateTimeFormat.format(dateTime),
        "receivedBy": widget.username,
        "isImage": false,
        "isVideo": false,
        "isPdf": false
      };
      Map<String, dynamic> chatRoomMap = {
        "lastMsgTimeStamp": timeStamp,
        "lastMsgTime": DateFormat.jm().format(DateTime.now()).toString(),
        "lastMsg": messageController.text,
        "SendBy": Constants.myName,
        "seen": false,
        "isImage": false,
        "isVideo": false,
        "isPdf": false
      };
      messageController.clear();
      await dataBaseMethods.addConversationMessages(
          widget.chatRoomId, messageMap);
      await dataBaseMethods.updateChatRoom(widget.chatRoomId, chatRoomMap);
      setState(() {
        msgIcon = CupertinoIcons.eye_fill;
      });
      await setTypingStatus("");
    }
  }

  @override
  void initState() {
    dataBaseMethods.getUserByUsername(widget.username).then((value) {
      useremail = value.docs[0].data()['email'];
    });

    dataBaseMethods.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });

    WidgetsBinding.instance.addObserver(this);
    dataBaseMethods.getUserStatus(widget.username).then((value) {
      setState(() {
        statusStream = value;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setSeen() async {
    await dataBaseMethods.updateLastMsgSeen(widget.chatRoomId);
  }

  void setTypingStatus(String text) async {
    if (text != "") {
      Map<String, String> statusMap = {"TypingTo": widget.username};
      await dataBaseMethods.setTypingStatus(statusMap);
    } else {
      Map<String, String> statusMap = {"TypingTo": "NoOne"};
      await dataBaseMethods.setTypingStatus(statusMap);
    }
  }

  Future pickImageGallery(context) async {
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    final pickedDocument = (await getExternalStorageDirectories());
    if (pickedFile != null) {
      image = File(pickedFile.path);
      uploadFile(context, true, false, false);
      print("URL added");
    }
    setState(() {});
  }

  Future pickPdf(context) async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      image = File(result.files.single.path);
      uploadFile(context, false, false, true);
    } else {
      // User canceled the picker
    }
  }

  Future uploadFile(context, bool isImage, bool isVideo, bool isPdf) async {
    setState(() {
      loading = true;
    });
    var r = Random();
    String imageName =
        String.fromCharCodes(List.generate(20, (index) => r.nextInt(33) + 89));
    print(imageName);
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child(widget.chatRoomId + "." + Constants.myName + imageName)
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
      "receivedBy": widget.username,
      "isImage": isImage,
      "isVideo": isVideo,
      "isPdf": isPdf
    };
    Map<String, dynamic> chatRoomMap = {
      "lastMsgTimeStamp": timeStamp,
      "lastMsgTime": DateFormat.jm().format(DateTime.now()).toString(),
      "lastMsg": isImage ? "Image" : isPdf ? "PDF" : "Video",
      "SendBy": Constants.myName,
      "seen": false,
      "isImage": isImage,
      "isVideo": isVideo,
      "isPdf": isPdf
    };
    await dataBaseMethods.addConversationMessages(
        widget.chatRoomId, messageMap);
    await dataBaseMethods.updateChatRoom(widget.chatRoomId, chatRoomMap);
    setState(() {
      loading = false;
      msgIcon = Icons.access_time_rounded;
    });
    if (widget.isSoundEnabled) {
      await AssetsAudioPlayer.playAndForget(
          Audio('assets/msg_sent_sound2.aac', playSpeed: 1.9),
          volume: 1,
          seek: Duration(seconds: 0));
    }
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      msgIcon = CupertinoIcons.eye_fill;
    });
  }

  @override
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
                    builder: (context) => ShowProfilePic(
                          username: widget.username,
                          mail: useremail,
                          imageUrl: widget.imageUrl,
                          isWhite: widget.isWhite,
                        )));
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
                    image: widget.imageUrl != null && widget.imageUrl != ""
                        ? CachedNetworkImageProvider(widget.imageUrl)
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
                      widget.username,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                    StreamBuilder(
                        stream: statusStream,
                        builder: (context, snapshot) {
                          if (sendBy == widget.username) {
                            setSeen();
                          }
                          return Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              snapshot.hasData && snapshot.data.docs.length >= 2
                                  ? snapshot.data.docs[1].data()["status"] ==
                                          "online"
                                      ? snapshot.data.docs[0]
                                                  .data()["TypingTo"] ==
                                              Constants.myName
                                          ? "Typing..."
                                          : "online"
                                      : snapshot.data.docs[1].data()["status"]
                                  : snapshot.hasData &&
                                          snapshot.data.docs.length >= 1
                                      ? snapshot.data.docs[0].data()["status"]
                                      : "",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
        brightness: Brightness.dark,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UniqueProfilePic(
                          isWhite: widget.isWhite,
                          chatRoomId: widget.chatRoomId,
                          myUrl: widget.myUrl))).then((val) {
                FirebaseFirestore.instance
                    .collection("ChatRoom")
                    .doc(widget.chatRoomId)
                    .get()
                    .then((value) {
                  widget.myUrl = value["users"][0] == Constants.myName
                      ? value["profilePicUrl"][0]
                      : value["profilePicUrl"][1];
                });
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.person_outline,
              ),
            ),
          ),
        ],
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
                    height: MediaQuery.of(context).size.height * 0.88,
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
                              focusNode: FocusNode(),
                              autofocus: false,
                              onChanged: (String s) async {
                                await setTypingStatus(s);
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
                                    pickPdf(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 1, 0, 7),
                                    height: 27,
                                    width: 20,
                                    child: Icon(
                                      Icons.insert_drive_file,
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
  final bool isNextMsgSendByMe;
  final String msgTime;
  final String lastMsg;
  String lastMsgDate = "";
  String compare = "";
  String compareMsg = "";
  bool isLastMessageSeen;
  String username;
  String chatRoomId;
  bool isWhite;
  DateTime diffDate;
  bool isImage, isVideo, isPdf;

  MessageTile(
      {this.message,
      this.isSendByMe,
      this.msgTime,
      this.lastMsg,
      this.lastMsgDate,
      this.compare,
      this.compareMsg,
      this.isLastMessageSeen,
      this.username,
      this.chatRoomId,
      this.isWhite,
      this.isNextMsgSendByMe,
      this.isImage,
      this.isVideo,
      this.isPdf}) {
    if (isPdf == null) isPdf = false;
    if (isVideo == null) isVideo = false;
    if (isImage == null) isImage = false;
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
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    //decryptMsg(widget.message);
    dataBaseMethods.getLastMessageSeen().then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  void findSeen() async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(widget.chatRoomId)
        .get()
        .then((val) {
      widget.isLastMessageSeen = val.data()["seen"];
      if (mounted)
        setState(() {
          chatMessageStream = null;
        });
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  Future<void> launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
          //margin: EdgeInsets.symmetric(vertical: widget.isNextMsgSendByMe == widget.isSendByMe ? 1 : 4),
          alignment:
              widget.isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        widget.isImage != null && widget.isImage ? 0 : 10,
                    vertical: 7),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isWhite
                          ? widget.isSendByMe
                              ? widget.isImage == null || !widget.isImage
                                  ? [
                                      Colors.teal[600].withOpacity(0.6),
                                      Colors.teal[600].withOpacity(0.8),
                                      Colors.teal[600].withOpacity(0.95)
                                    ]
                                  : [Colors.transparent, Colors.transparent]
                              : widget.isImage == null || !widget.isImage
                                  ? [
                                      Colors.grey[800].withOpacity(0.95),
                                      Colors.grey[800].withOpacity(0.8),
                                      Colors.grey[800].withOpacity(0.5)
                                    ]
                                  : [Colors.transparent, Colors.transparent]
                          : widget.isSendByMe
                              ? widget.isImage == null || !widget.isImage
                                  ? [
                                      Colors.teal[600].withOpacity(0.15),
                                      Colors.teal[600].withOpacity(0.53),
                                      Colors.teal[600].withOpacity(0.8)
                                    ]
                                  : [Colors.transparent, Colors.transparent]
                              : widget.isImage == null || !widget.isImage
                                  ? [
                                      Colors.grey[800].withOpacity(0.85),
                                      Colors.grey[800].withOpacity(0.53),
                                      Colors.grey[800].withOpacity(0.15)
                                    ]
                                  : [Colors.transparent, Colors.transparent],
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    (!widget.isImage && !widget.isVideo && !widget.isPdf)
                        ? widget.message != null &&
                                    widget.message.length <= 10 ||
                                !widget.message.contains("https://", 0)
                            ? SelectableText(
                                widget.message,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                                textAlign: TextAlign.start,
                                enableInteractiveSelection: true,
                              )
                            : InkWell(
                                onTap: () async {
                                  launch(widget.message);
                                },
                                child: Container(
                                  child: Text(
                                    widget.message,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      fontSize: 17,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              )
                        : widget.isImage
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ShowImage(
                                                imageUrl: widget.message,
                                                appBarText: widget.isSendByMe
                                                    ? "You"
                                                    : widget.username,
                                                tag: widget.message,
                                              )));
                                },
                                child: Container(
                                  height: 300,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
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
                              )
                            : widget.isVideo
                                ? GestureDetector(
                                    onTap: () {
                                      String videoLink =
                                          widget.message + ".mp4";
                                      print(videoLink);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PlayVideo(
                                                  videoLink: videoLink)));
                                    },
                                    child: Container(
                                      width: 75,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Video",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => PdfViewer(
                                                  pdfUrl: widget.message, isWhite: widget.isWhite,)));
                                     // launch(widget.message);
                                    },
                                    child: Container(
                                      width: 75,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "View pdf",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
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
                                    widget.message == widget.lastMsg ? 70 : 57,
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
                                    Icon(
                                      msgIcon,
                                      color: widget.isLastMessageSeen &&
                                              widget.isSendByMe &&
                                              widget.message == widget.lastMsg
                                          ? Colors.yellow
                                          : widget.isImage == null ||
                                                  !widget.isImage
                                              ? Colors.black
                                              : Colors.white,
                                      size: widget.message == widget.lastMsg
                                          ? 13
                                          : 0,
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

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0))
    return b + "*" + a;
  else
    return a + "*" + b;
}
