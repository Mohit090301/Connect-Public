import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/widgets/widget.dart';

import 'conversation_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool isWhite;
  final String blackBg;
  final String whiteBg;

  SearchScreen({this.isWhite, this.blackBg, this.whiteBg});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchTextEditingController =
      new TextEditingController();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  QuerySnapshot searchSnapshot;
  bool loading = false;
  int count = 0;

  initiateSearch() async {
    if (searchTextEditingController.text == "") {
      setState(() {
        count = 0;
      });
      return;
    }
    setState(() {
      loading = true;
    });
    await dataBaseMethods
        .getUserByUsername(searchTextEditingController.text)
        .then((value) {
      setState(() {
        searchSnapshot = value;
      });
    });
    setState(() {
      loading = false;
    });
    if (searchSnapshot == null || searchSnapshot.docs.length == 0)
      setState(() {
        count++;
      });
    else {
      setState(() {
        count = 0;
      });
    }
    print("Count - $count");
  }

  Widget SearchList() {
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              count = 0;
              return searchSnapshot.docs.length != 0
                  ? SearchTile(
                      username: searchSnapshot.docs[index].data()["name"],
                      email: searchSnapshot.docs[index].data()["email"])
                  : Container(
                      child: Text(
                        "No user found",
                        style: TextStyle(
                          color: widget.isWhite ? Colors.black : Colors.white,
                        ),
                      ),
                    );
            })
        : Container();
  }

  createChatRoomAndStartConversation({String username}) async {
    if (username != Constants.myName) {
      List<String> users = [username, Constants.myName];
      String chatRoomId = getChatRoomId(username, Constants.myName);
      print(chatRoomId);
      print(username);
      List<String> urls = ["", ""];
      await dataBaseMethods.getUrl(username).then((value) {
        urls[0] = value.data()["profilePicURL"];
        print("url - $urls[0]");
      });
      await dataBaseMethods.getUrl(Constants.myName).then((value) {
        urls[1] = value.data()["profilePicURL"];
        print("url - $urls[0]");
      });
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatRoomId": chatRoomId,
        "lastMsgTimeStamp": DateTime.now().millisecondsSinceEpoch,
        "lastMsgTime": "",
        "seen": false,
        "profilePicUrl": urls
      };
      DataBaseMethods().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(
                    username: username,
                    chatRoomId: chatRoomId,
                    isLastMsgSeen: false,
                    isWhite: widget.isWhite,
                    imageUrl: urls[0],
                    whitebg: widget.whiteBg,
                    blackbg: widget.blackBg,
                  )));
    } else
      print('you cannot send message to yourself');
  }

  Widget SearchTile({String username, String email}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  color: widget.isWhite ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  color: widget.isWhite ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoomAndStartConversation(username: username);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: widget.isWhite ? Colors.blue[800] : Colors.blue[600],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Text',
                style: mediumTextStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: widget.isWhite ? Colors.teal[700] : Colors.teal[900],
        title: Text(
          "Let's Connect",
          style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: widget.isWhite ? Colors.white : Colors.white70),
        ),
        brightness: Brightness.dark,
      ),
      body: Stack(
        children: [
          Container(
            color: widget.isWhite ? Colors.grey[200] : Colors.black45,
            child: Column(
              children: [
                Container(
                  color: widget.isWhite ? Colors.black54 : Colors.white12,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          controller: searchTextEditingController,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search username...',
                            hintStyle: TextStyle(
                              color: widget.isWhite
                                  ? Colors.white
                                  : Colors.white24,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          initiateSearch();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 40,
                          width: 40,
                          child: Icon(
                            Icons.search_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: count >= 1
                      ? Text(
                          "No user found",
                          style: TextStyle(
                            color: widget.isWhite ? Colors.black : Colors.white,
                          ),
                        )
                      : SearchList(),
                ),
              ],
            ),
          ),
          loading ? Center(child: CircularProgressIndicator()) : Container(),
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
