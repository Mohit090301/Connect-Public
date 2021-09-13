import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/helper/helper.dart';
import 'package:flutter_chat_app/services/auth.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/views/conversation_screen.dart';
import 'package:flutter_chat_app/views/profile_pic.dart';
import 'package:flutter_chat_app/views/search.dart';
import 'package:flutter_chat_app/views/settings.dart';
import 'package:flutter_chat_app/views/show_image.dart';
import 'package:intl/intl.dart';

import 'groupChatScreen.dart';

Stream repeat;

class ChatRoom extends StatefulWidget {
  final String email;

  ChatRoom({this.email});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  Stream chatRoomsStream;
  Stream groupStream;
  String username = "";
  String lastmessage = "";
  String lastMessagetime;
  var lastMessageTimeStamp;
  bool isWhite = false;
  Stream messageStream;
  String blackbg = "";
  String whitebg = "";
  TabController _controller;
  bool isSoundEnabled;

  Widget ChatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  username = snapshot.data.docs[index]
                      .data()["chatRoomId"]
                      .toString()
                      .replaceAll("*", "")
                      .replaceAll(Constants.myName, "");
                  lastmessage = snapshot.data.docs[index].data()["lastMsg"];
                  lastMessageTimeStamp =
                      snapshot.data.docs[index].data()["lastMsgTimeStamp"];
                  lastMessagetime =
                      snapshot.data.docs[index].data()["lastMsgTime"];
                  return ChatRoomsTile(
                    username: snapshot.data.docs[index]
                        .data()["chatRoomId"]
                        .toString()
                        .replaceAll("*", "")
                        .replaceAll(Constants.myName, ""),
                    chatRoom: snapshot.data.docs[index].data()["chatRoomId"],
                    lastMsgTime: snapshot.data.docs[index]
                        .data()["lastMsgTime"]
                        .toString(),
                    lastMsg: snapshot.data.docs[index].data()["lastMsg"],
                    lastMsgSendBy: snapshot.data.docs[index].data()["SendBy"],
                    isSeen: snapshot.data.docs[index].data()["seen"],
                    email: widget.email,
                    isWhite: isWhite,
                    url: snapshot.data.docs[index].data()["users"][0] ==
                            username
                        ? snapshot.data.docs[index].data()["profilePicUrl"]
                                    [0] ==
                                null
                            ? ""
                            : snapshot.data.docs[index].data()["profilePicUrl"]
                                [0]
                        : snapshot.data.docs[index].data()["profilePicUrl"]
                                    [1] ==
                                null
                            ? ""
                            : snapshot.data.docs[index].data()["profilePicUrl"]
                                [1],
                    myUrl: snapshot.data.docs[index].data()["users"][0] ==
                            Constants.myName
                        ? snapshot.data.docs[index].data()["profilePicUrl"]
                                    [0] ==
                                null
                            ? ""
                            : snapshot.data.docs[index].data()["profilePicUrl"]
                                [0]
                        : snapshot.data.docs[index].data()["profilePicUrl"]
                                    [1] ==
                                null
                            ? ""
                            : snapshot.data.docs[index].data()["profilePicUrl"]
                                [1],
                    lastMsgTimeStamp: lastMessageTimeStamp,
                    whitebg: whitebg,
                    blackbg: blackbg,
                    isImage: snapshot.data.docs[index].data()["isImage"],
                    isSoundEnabled: isSoundEnabled,
                    isPdf: snapshot.data.docs[index].data()["isPdf"],
                  );
                },
              )
            : Container();
      },
    );
  }

  Widget groupList() {
    return StreamBuilder(
      stream: groupStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return GroupTile(
                      groupName: snapshot.data.docs[index].data()["groupName"],
                      groupPicUrl:
                          snapshot.data.docs[index].data()["groupPicUrl"],
                      isWhite: isWhite,
                      groupId: snapshot.data.docs[index].data()["groupId"],
                      blackbg: blackbg,
                      whitebg: whitebg,
                      receivedBy: snapshot.data.docs[index].data()["users"],
                      isSoundEnabled: isSoundEnabled,
                      lastMsg: snapshot.data.docs[index].data()["lastMsg"],
                      lastMsgSendBy: snapshot.data.docs[index].data()["SendBy"],
                      lastMsgTime:
                          snapshot.data.docs[index].data()["lastMsgTime"],
                      lastMsgTimeStamp:
                          snapshot.data.docs[index].data()["lastMsgTimeStamp"]);
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    _controller = TabController(vsync: this, length: 2);
    _controller.addListener(() {
      getUserInfo();
    });
    getUserInfo();
    isSoundEnabled = true;
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void getChats() async {
    await dataBaseMethods.getChatRooms(Constants.myName).then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print(AppLifecycleState.values);
    print("values");
    if (state == AppLifecycleState.resumed) {
      getChats();
      Map<String, String> statusMap = {"status": "online"};
      ChatRoom(email: widget.email);
      await dataBaseMethods.setStatus(Constants.myName, statusMap);
    } else {
      String date = DateTime.now().format("d-m-y");
      Map<String, String> statusMap = {
        "status": "Last seen: " +
            DateFormat.jm().format(DateTime.now()).toString() +
            ", " +
            date
      };
      await dataBaseMethods.setStatus(Constants.myName, statusMap);
    }
    await setTypingStatus();
    setState(() {});
  }

  setTypingStatus() async {
    Map<String, String> statusMap = {"TypingTo": "NoOne"};
    await dataBaseMethods.setTypingStatus(statusMap);
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Map<String, String> statusMap = {"TypingTo": "NoOne"};
    await dataBaseMethods.getChatRooms(Constants.myName).then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(Constants.myName)
        .get()
        .then((value) {
      setState(() {
        isWhite = value["isWhite"];
        if (value.data().length >= 6) {
          blackbg = value["BlackBackgroundImage"];
          whitebg = value["WhiteBackgroundImage"];
        }
      });
    });
    dataBaseMethods.getGroups().then((value) {
      setState(() {
        groupStream = value;
      });
    });
    await dataBaseMethods.setTypingStatus(statusMap);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      child: Scaffold(
          backgroundColor: isWhite ? Colors.grey[100] : Colors.black54,
          appBar: AppBar(
            backgroundColor: isWhite ? Colors.teal[700] : Colors.teal[900],
            title: Text(
              'CONNECT',
              style: TextStyle(
                  fontSize: 24,
                  color: isWhite ? Colors.grey[100] : Colors.white70,
                  fontWeight: FontWeight.w700),
            ),
            brightness: Brightness.dark,
            centerTitle: false,
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => settings(
                                value: isWhite,
                                isSoundEnabled: isSoundEnabled,
                              ))).then((value) {
                    if (mounted) {
                      setState(() {
                        isWhite = value[0];
                        whitebg = value[1] == "" ? whitebg : value[1];
                        blackbg = value[2] == "" ? blackbg : value[2];
                        isSoundEnabled = value[3];
                      });
                    }
                  });
                },
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.settings,
                      size: 21,
                      semanticLabel: "Settings",
                    )),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchScreen(
                                isWhite: isWhite,
                                whiteBg: whitebg,
                                blackBg: blackbg,
                              )));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.search,
                    semanticLabel: "Search",
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePic(
                                email: widget.email,
                                isWhite: isWhite,
                              ))).then((value) {});
                },
                child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                    child: Icon(
                      Icons.person_rounded,
                      semanticLabel: "Profile",
                    )),
              ),
            ],
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              controller: _controller,
              indicatorWeight: 2.5,
              tabs: [
                Tab(
                  child: Text(
                    "CHATS",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Tab(
                  child: Text(
                    "GROUPS",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),
          body: TabBarView(
            controller: _controller,
            children: [
              ChatRoomList(),
              Stack(
                children: [
                  groupList(),
                  Positioned(
                    bottom: 30,
                    right: 15,
                    child: FloatingActionButton(
                      onPressed: () {},
                      child: Icon(Icons.group),
                      tooltip: "New Group",
                    ),
                  )
                ],
              )
            ],
          )),
      length: 2,
    );
  }
}

class ChatRoomsTile extends StatefulWidget {
  final String username;
  final String chatRoom;
  String lastMsgTime;
  String lastMsg;
  String lastMsgSendBy;
  bool isSeen;
  final String email;
  bool isWhite;
  String url;
  String myUrl;
  int lastMsgTimeStamp;
  String blackbg;
  String whitebg;
  bool isImage, isPdf;
  bool isSoundEnabled;

  ChatRoomsTile(
      {this.username,
      this.chatRoom,
      this.lastMsgTime,
      this.lastMsg,
      this.lastMsgSendBy,
      this.isSeen,
      this.email,
      this.isWhite,
      this.url,
      this.myUrl,
      this.lastMsgTimeStamp,
      this.blackbg,
      this.whitebg,
      this.isImage,
      this.isPdf,
      this.isSoundEnabled}){
    if(isImage == null)
      isImage = false;
    if(isPdf == null)
      isPdf = false;
  }

  @override
  _ChatRoomsTileState createState() => _ChatRoomsTileState();
}

class _ChatRoomsTileState extends State<ChatRoomsTile> {
  Stream chatMessageStream;
  Stream profile;
  Stream seen;
  String lastMsgSnapshot;
  String typingTo = "";
  String status = "";
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  bool sendByMe;
  String usermail;
  String imageUrl;

  setTypingStatus() async {
    Map<String, String> statusMap = {"TypingTo": "NoOne"};
    await dataBaseMethods.setTypingStatus(statusMap);
  }

  setOnlineStatus() async {
    Map<String, String> statusMap = {"status": "online"};
    await dataBaseMethods.setStatus(Constants.myName, statusMap);
  }

  @override
  void initState() {
    ChatRoom(email: widget.email);
    dataBaseMethods.getUserByUsername(widget.username).then((snapshot) {
      usermail = snapshot.docs[0].data()['email'];
    });

    dataBaseMethods.getProfileChangeStatus(widget.username).then((value) {
      profile = value;
    });

    dataBaseMethods.getChatRooms(Constants.myName).then((value) {});
    dataBaseMethods.getUserStatus(widget.username).then((value) {
      chatMessageStream = value;
    });

    setTypingStatus();
    setOnlineStatus();
    setState(() {});
  }

  void setSeen() async {
    String chatRoomId = getChatRoomId(Constants.myName, widget.username);
    dataBaseMethods.updateLastMsgSeen(chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    dataBaseMethods.getUserStatus(widget.username).then((value) {
      chatMessageStream = value;
    });
    double width = MediaQuery.of(context).size.width - 50;
    var lasMsgDate =
        DateTime.fromMillisecondsSinceEpoch(widget.lastMsgTimeStamp);
    int diff = DateTime.now().difference(lasMsgDate).inDays;
    String todaysDate = DateTimeFormat.format(DateTime.now())
        .toString()
        .substring(0, 10)
        .split('-')
        .reversed
        .join('-');
    String lmd =
        lasMsgDate.toString().substring(0, 10).split('-').reversed.join('-');
    if (diff == 1) diff = 2;
    if (lmd == todaysDate) diff = 0;
    if (diff == 0 && lmd != todaysDate) diff = 1;

    return StreamBuilder(
        stream: chatMessageStream,
        builder: (context, snapshot) {
          typingTo = snapshot.hasData && snapshot.data.docs.length >= 2
              ? snapshot.data.docs[0].data()["TypingTo"]
              : "";
          status = snapshot.hasData && snapshot.data.docs.length >= 2
              ? snapshot.data.docs[1].data()["status"]
              : "";
          sendByMe = widget.lastMsgSendBy != null &&
                  widget.lastMsgSendBy == Constants.myName
              ? true
              : false;
          return snapshot.hasData
              ? Container(
                  color: widget.isWhite ? Colors.grey[100] : Colors.black45,
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 11),
                  child: Row(
                    children: [
                      widget.url != null && widget.url != ""
                          ? StreamBuilder(
                              stream: profile,
                              builder: (context, snapshot) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ShowImage(
                                                imageUrl: widget.url,
                                                appBarText: widget.username,
                                                tag: widget.username)));
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 43,
                                    width: 43,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            widget.url),
                                      ),
                                      color: widget.isWhite
                                          ? Colors.teal[700]
                                          : Colors.teal[900],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              })
                          : InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShowImage(
                                              imageUrl: widget.url,
                                              appBarText: widget.username,
                                              tag: widget.username,
                                            )));
                              },
                              child: Hero(
                                tag: widget.username,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 43,
                                  width: 43,
                                  decoration: BoxDecoration(
                                    color: widget.isWhite
                                        ? Colors.teal[700]
                                        : Colors.teal[900],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    widget.username
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        flex: 1,
                        child: InkWell(
                          onTap: () async {
                            if (!sendByMe) {
                              setSeen();
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConversationScreen(
                                        username: widget.username,
                                        chatRoomId: widget.chatRoom,
                                        imageUrl: widget.url,
                                        mailid: widget.email,
                                        isLastMsgSeen: widget.isSeen,
                                        isWhite: widget.isWhite,
                                        myUrl: widget.myUrl,
                                        whitebg: widget.whitebg,
                                        blackbg: widget.blackbg,
                                        isSoundEnabled:
                                            widget.isSoundEnabled))).then(
                                (value) async {
                              await dataBaseMethods
                                  .getUserStatus(widget.username)
                                  .then((val) {
                                setState(() {
                                  repeat = val;
                                  repeat = null;
                                });
                              });
                              initState();
                            });
                          },
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: width * 0.62,
                                          child: Text(
                                            widget.username,
                                            style: TextStyle(
                                              fontSize: 19,
                                              color: widget.isWhite
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: width * 0.3,
                                          child: Text(
                                            widget.lastMsgTime != null
                                                ? diff == 0
                                                    ? widget.lastMsgTime
                                                    : diff == 1
                                                        ? "Yesterday"
                                                        : lasMsgDate
                                                            .format("d-m-y")
                                                : "",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: widget.isWhite
                                                  ? Colors.grey[700]
                                                  : Colors.grey,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Row(
                                  children: [
                                    sendByMe &&
                                            !(typingTo == Constants.myName &&
                                                status == "online")
                                        ? Column(
                                            children: [
                                              Container(
                                                width: 16,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      CupertinoIcons.eye_fill,
                                                      color: widget.isSeen ==
                                                              true
                                                          ? widget.isWhite
                                                              ? Colors.lightBlue
                                                              : Colors.yellow
                                                          : widget.isWhite
                                                              ? Colors.grey[600]
                                                              : Colors.grey,
                                                      size: 13,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    Container(
                                      width: sendByMe ? width - 50 : width - 40,
                                      child: Text(
                                        typingTo == Constants.myName &&
                                                status == "online"
                                            ? "Typing..."
                                            : widget.lastMsg != null
                                                ? sendByMe || widget.isSeen
                                                    ? widget.lastMsg
                                                    : "New Message.."
                                                : "",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: typingTo == Constants.myName &&
                                                  status == "online"
                                              ? widget.isWhite
                                                  ? Colors.teal[600]
                                                  : Colors.teal
                                              : sendByMe || widget.isSeen
                                                  ? widget.isWhite
                                                      ? Colors.grey[700]
                                                      : Colors.grey
                                                  : widget.isWhite
                                                      ? Colors.blue[700]
                                                      : Colors.blue[400],
                                          fontWeight: sendByMe ||
                                                  (typingTo ==
                                                          Constants.myName &&
                                                      status == "online")
                                              ? FontWeight.w400
                                              : widget.isSeen
                                                  ? FontWeight.w400
                                                  : FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container();
        });
  }
}

class GroupTile extends StatefulWidget {
  String groupName;
  String groupPicUrl;
  bool isWhite;
  String groupId;
  String blackbg;
  String whitebg;
  List<dynamic> receivedBy;
  bool isSoundEnabled;
  String lastMsg;
  String lastMsgSendBy;
  String lastMsgTime;
  int lastMsgTimeStamp;

  GroupTile(
      {this.groupName,
      this.groupPicUrl,
      this.isWhite,
      this.groupId,
      this.whitebg,
      this.blackbg,
      this.receivedBy,
      this.isSoundEnabled,
      this.lastMsg,
      this.lastMsgTime,
      this.lastMsgSendBy,
      this.lastMsgTimeStamp});

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 50;
    if (widget.lastMsgTimeStamp == null)
      widget.lastMsgTimeStamp = 1630858069469;
    var lasMsgDate =
        DateTime.fromMillisecondsSinceEpoch(widget.lastMsgTimeStamp);
    int diff = DateTime.now().difference(lasMsgDate).inDays;
    String todaysDate = DateTimeFormat.format(DateTime.now())
        .toString()
        .substring(0, 10)
        .split('-')
        .reversed
        .join('-');
    String lmd =
        lasMsgDate.toString().substring(0, 10).split('-').reversed.join('-');
    if (diff == 1) diff = 2;
    if (lmd == todaysDate) diff = 0;
    if (diff == 0 && lmd != todaysDate) diff = 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowImage(
                            imageUrl: widget.groupPicUrl,
                            appBarText: widget.groupName,
                          )));
            },
            child: widget.groupPicUrl == null || widget.groupPicUrl == ""
                ? Container(
                    alignment: Alignment.center,
                    height: 43,
                    width: 43,
                    decoration: BoxDecoration(
                      color:
                          widget.isWhite ? Colors.teal[700] : Colors.teal[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    height: 43,
                    width: 43,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(widget.groupPicUrl),
                      ),
                      color:
                          widget.isWhite ? Colors.teal[700] : Colors.teal[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
          ),
          SizedBox(
            width: 10,
          ),
          Flexible(
            flex: 1,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupChatScreen(
                              groupId: widget.groupId,
                              groupName: widget.groupName,
                              groupPicUrl: widget.groupPicUrl,
                              blackbg: widget.blackbg,
                              whitebg: widget.whitebg,
                              isWhite: widget.isWhite,
                              receivedBy: widget.receivedBy,
                              isSoundEnabled: widget.isSoundEnabled,
                            )));
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: width * 0.62,
                          child: Text(
                            widget.groupName,
                            style: TextStyle(
                              color: widget.isWhite
                                  ? Colors.black87
                                  : Colors.white,
                              fontSize: 19,
                              //fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                        Container(
                          width: width * 0.3,
                          child: Text(
                            widget.lastMsgTime != null
                                ? diff == 0
                                    ? widget.lastMsgTime
                                    : diff == 1
                                        ? "Yesterday"
                                        : lasMsgDate.format("d-m-y")
                                : "",
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isWhite
                                  ? Colors.grey[700]
                                  : Colors.grey,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      widget.lastMsg == null
                          ? "Null"
                          : widget.lastMsgSendBy == Constants.myName
                              ? "Me: " + widget.lastMsg
                              : widget.lastMsgSendBy + ": " + widget.lastMsg,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0))
    return b + "*" + a;
  else
    return a + "*" + b;
}
