import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/Model/token_model.dart';
import 'package:flutter_chat_app/helper/constants.dart';
import 'package:flutter_chat_app/helper/constants.dart';

class DataBaseMethods {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  getUserByUsername(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: username)
        .get();
  }

  checkIfUserExists(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .get();
  }

  getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .get();
  }

  uploadUserInfo(userMap, userId) async {
    FirebaseFirestore.instance.collection("users").doc(userId).set(userMap);
    print('user added');
  }

  updateUserTheme(String username, bool isWhite) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .update({"isWhite": isWhite});
  }

  uploadUserToken(tokenMap, userId) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("tokens")
        .doc("Notification Token")
        .set(TokenModel(
        token: tokenMap['token'], createdAt: tokenMap['createdAt'])
        .toJson());
    print('token added');
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .set(chatRoomMap);
  }

  addConversationMessages(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap);
  }

  addGroupMessages(String groupId, messageMap) async {
    await FirebaseFirestore.instance.collection('groups').where(
        "groupId", isEqualTo: groupId).get().then((value) {
      print(value);
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection('groups')
            .doc(element.id)
            .collection("chats")
            .add(messageMap);
      });
    });
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  getGroupMessages(String groupId) async {
    String id;
    await FirebaseFirestore.instance.collection('groups').where(
        "groupId", isEqualTo: groupId).get().then((value) {
      value.docs.forEach((element) async {
        id = element.id;
      });
    });
    return await FirebaseFirestore.instance.collection('groups')
        .doc(id)
        .collection('chats')
        .orderBy("time", descending: true)
        .snapshots();
  }

  getChatRooms(String username) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .where("users", arrayContains: username)
        .orderBy("lastMsgTimeStamp", descending: true)
        .snapshots();
  }

  getGroups() async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .where("users", arrayContains: Constants.myName).snapshots();
  }

  setStatus(String username, statusMap) async {
    print("set status of " + username + " to" + statusMap["status"]);
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("status")
        .doc("stat")
        .set(statusMap);
  }

  getUserStatus(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("status")
        .snapshots();
  }

  getProfileChangeStatus(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .snapshots();
  }

  setTypingStatus(Map<String, String> statusMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(Constants.myName)
        .collection("status")
        .doc("TypingStat")
        .set(statusMap);
  }

  updateLastMsgSeen(String chatRoomId) async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .update({"seen": true});
  }

  getProfilePicUrl(String username) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .snapshots();
  }

  getUrl(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .get();
  }

  updateProfilePicUrl(String url, String username) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .update({"profilePicURL": url});
  }

  updateGroupPicUrl(String url, String groupId) async {
    await FirebaseFirestore.instance
        .collection("groups")
        .where("groupId", isEqualTo: groupId)
        .get().then((value) {
          value.docs.forEach((element) async{
            await FirebaseFirestore.instance.collection('groups').doc(element.id).update({"groupPicUrl" : url});
          });
    });
  }

  updateChatRoom(String chatRoomId, chatRoomMap) async {
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .update(chatRoomMap);
  }

  getLastMessageSeen() async {
    await FirebaseFirestore.instance.collection("ChatRoom").snapshots();
  }

  updateUrlEverywhere(String url, String username) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .where("users", arrayContains: username)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        String url1 = element.data()["profilePicUrl"][0];
        String url2 = element.data()["profilePicUrl"][1];
        String user1 = element.data()["users"][0];
        List<String> urls = [url1, url2];
        if (user1 == username) {
          urls[0] = url;
        } else {
          urls[1] = url;
        }
        String n1 = Constants.myName + "height";
        String n2 = Constants.myName + "width";
        FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(element.id)
            .update({"profilePicUrl": urls});
      });
    });
  }

  updateUniqueProfilePic(String chatRoomId, String url, String username) async {
    List<String> urls;
    await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .get()
        .then((value) {
      urls = [value["profilePicUrl"][0], value["profilePicUrl"][1]];
      if (value["users"][0] == username)
        urls[0] = url;
      else
        urls[1] = url;
    });
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .update({"profilePicUrl": urls});
  }

  updateBackgroundImage(String image, bool isWhite) async {
    if (isWhite)
      await FirebaseFirestore.instance
          .collection("users")
          .doc(Constants.myName)
          .update({"WhiteBackgroundImage": image});
    else
      await FirebaseFirestore.instance
          .collection("users")
          .doc(Constants.myName)
          .update({"BlackBackgroundImage": image});
  }
}
