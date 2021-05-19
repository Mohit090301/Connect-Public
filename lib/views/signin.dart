import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/helper.dart';
import 'package:flutter_chat_app/services/auth.dart';
import 'package:flutter_chat_app/services/database.dart';
import 'package:flutter_chat_app/widgets/widget.dart';

import 'chatRoomsScreen.dart';

class SignIn extends StatefulWidget {
  final Function toggle;

  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool loading = false;
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passwordTextEditingController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  QuerySnapshot snapshotUserInfo;
  String username;
  bool seePass = false;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  signMeIn() async {
    final fcmToken = await _fcm.getToken();
    print(fcmToken + " token");
    if (formKey.currentState.validate()) {
      Map<String, dynamic> tokenMap = {
        "token": fcmToken,
        "createdAt": FieldValue.serverTimestamp(),
      };

      HelperFunctions.saveUserEmailSharedPreference(
          emailTextEditingController.text);

      dataBaseMethods
          .getUserByUserEmail(emailTextEditingController.text)
          .then((value) {
        snapshotUserInfo = value;
        username = snapshotUserInfo.docs[0].data()['name'];
        HelperFunctions.saveUserNameSharedPreference(
            snapshotUserInfo.docs[0].data()['name']);
      });
      setState(() {
        isLoading = true;
      });
      authMethods
          .signInWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((value) async {
        if (value != null) {
          Map<String, dynamic> userMap = {
            "name": username,
            "email": emailTextEditingController.text,
          };
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          await dataBaseMethods.uploadUserToken(tokenMap, username);
          //await dataBaseMethods.uploadUserInfo(userMap, username);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatRoom(email: emailTextEditingController.text)));
        } else
          setState(() {
            isLoading = false;
          });
      });
    }
  }

  bool MailDoesntExist(String val) {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height - 60,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (val) {
                                  return MailDoesntExist(val.toString())
                                      ? "Email doesn't exist"
                                      : null;
                                },
                                controller: emailTextEditingController,
                                style: simpleTextStyle(),
                                decoration: textFieldInputDecoration('Email'),
                                textAlignVertical: TextAlignVertical.bottom,
                              ),
                              TextFormField(
                                cursorHeight: 18,
                                obscureText: seePass ? false : true,
                                validator: (val) {
                                  return val.length >= 8
                                      ? null
                                      : "Wrong Password";
                                },
                                controller: passwordTextEditingController,
                                style: simpleTextStyle(),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 7),
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                    color: Colors.white54,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        seePass = !seePass;
                                      });
                                    },
                                    child: Icon(!seePass ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                                        color: Colors.grey, size: 16),
                                  ),
                                ),
                                textAlignVertical: TextAlignVertical.bottom,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  loading = true;
                                });
                                bool success = await authMethods
                                    .resetPass(emailTextEditingController.text);
                                print(success);
                                final snackBar = SnackBar(
                                  content: Text(
                                    success
                                        ? "Password change email sent successfully"
                                        : emailTextEditingController.text == ""
                                            ? "Provide valid email to change password"
                                            : "Failed to send password reset mail",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  duration: Duration(milliseconds: 1000),
                                  backgroundColor: Colors.black,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                setState(() {
                                  loading = false;
                                });
                              },
                              child: Text('Forgot Password?',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () {
                            signMeIn();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.teal[900], Colors.teal[800]],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: mediumTextStyle(),
                            ),
                            GestureDetector(
                              onTap: widget.toggle,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Register Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                loading
                    ? Center(child: CircularProgressIndicator())
                    : Container()
              ],
            ),
    );
  }
}
