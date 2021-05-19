import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/helper.dart';
import 'package:flutter_chat_app/services/auth.dart';
import 'package:flutter_chat_app/views/chatRoomsScreen.dart';
import 'package:flutter_chat_app/widgets/widget.dart';
import 'package:flutter_chat_app/services/database.dart';

class SignUp extends StatefulWidget {
  final Function toggle;

  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController userNameTextEditingController =
      new TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passwordTextEditingController =
      new TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
  new TextEditingController();
  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool exists = false;
  QuerySnapshot snapshot;
  bool seePass = false;
  bool seePass2 = false;

  signMeUp() async{

    final fcmToken = await _fcm.getToken();
    dataBaseMethods.checkIfUserExists(userNameTextEditingController.text).then((value){
      setState(() {
        print(value.data());
        exists = value.data() != null;
        if(exists == true)
          return;
      });
    });
    if (formKey.currentState.validate()) {
      Map<String, dynamic> userInfoMap = {
        "name": userNameTextEditingController.text,
        "email": emailTextEditingController.text,
        "profilePicURL": "",
        "isWhite": false,
        "BlackBackgroundImage" : "",
        "WhiteBackgroundImage": "",
      };

      Map<String, dynamic> tokenMap = {
        "token": fcmToken,
        "createdAt": FieldValue.serverTimestamp(),
      };

      HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);
      HelperFunctions.saveUserNameSharedPreference(userNameTextEditingController.text);

      setState(() {
        isLoading = true;
      });

      HelperFunctions.saveUserLoggedInSharedPreference(true);
      authMethods
          .signUpWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((value) {
        dataBaseMethods.uploadUserInfo(userInfoMap, userNameTextEditingController.text);
        dataBaseMethods.uploadUserToken(tokenMap, userNameTextEditingController.text);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (contex) => ChatRoom(email: emailTextEditingController.text,)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
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
                          onChanged: (val) {
                            dataBaseMethods.checkIfUserExists(userNameTextEditingController.text).then((value){
                              exists = value.data() != null;
                            });
                          },
                          validator: (val){
                            return val.isEmpty || val.length <= 4
                                ? "Please provide valid username"
                                :  exists ? "Username already exists.Please provide another username." : null;
                          },
                          controller: userNameTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration('Username'),
                          textAlignVertical: TextAlignVertical.bottom,
                        ),
                        TextFormField(
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Not a valid email";
                          },
                          controller: emailTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration('Email'),
                          textAlignVertical: TextAlignVertical.bottom,
                        ),
                        TextFormField(
                          obscureText: seePass ? false : true,
                          validator: (val) {
                            return val.length >= 8
                                ? null
                                : "Password must be atleast 8 characters";
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
                        TextFormField(
                          obscureText: seePass2 ? false : true,
                          validator: (val) {
                            return passwordTextEditingController.text == confirmPasswordTextEditingController.text
                                ? confirmPasswordTextEditingController.text.length >= 8 ? null : "Password must be atleast 8 characters"
                                : "Password didn't match";
                          },
                          controller: confirmPasswordTextEditingController,
                          style: simpleTextStyle(),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 7),
                            hintText: "Confirm Password",
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
                                  seePass2 = !seePass2;
                                });
                              },
                              child: Icon(!seePass2 ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill,
                                  color: Colors.grey, size: 16),
                            ),
                          ),
                          textAlignVertical: TextAlignVertical.bottom,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      signMeUp();
                      setState(() {

                      });
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
                        'Sign Up',
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
                        "Already have an account? ",
                        style: mediumTextStyle(),
                      ),
                      GestureDetector(
                        onTap: widget.toggle,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Sign in',
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
    );
  }
}
