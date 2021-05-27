import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/views/show_image.dart';

class ShowProfilePic extends StatelessWidget {
  String imageUrl;
  final String username;
  final String mail;
  double height;
  double width;
  final bool isWhite;

  ShowProfilePic(
      {this.username,
      this.mail,
      this.imageUrl,
      this.isWhite
      });

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: isWhite ? Colors.grey[200] : Colors.black54,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.teal[700] : Colors.teal[900],
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
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              //height: 150,
              child: Center(
                child: Stack(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ShowImage(
                                        imageUrl: imageUrl,
                                        appBarText: username,
                                        tag: username,
                                      )));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: height * 0.2,
                          width: height * 0.2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: imageUrl != null && imageUrl != ""
                                  ? CachedNetworkImageProvider(imageUrl)
                                  : AssetImage('assets/empty_pic.jpeg'),
                            ),
                            color: Colors.teal[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              thickness: 0.5,
              height: 40,
              color: isWhite ? Colors.black : Colors.grey,
            ),
            Text(
              'Username',
              style: TextStyle(
                color: isWhite ? Colors.black : Colors.grey,
                letterSpacing: 2.0,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              username,
              style: TextStyle(
                color: isWhite ? Colors.black : Colors.white,
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
                color: isWhite ? Colors.black : Colors.grey,
                letterSpacing: 2.0,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              mail != null ? mail : "null",
              style: TextStyle(
                color: isWhite ? Colors.black : Colors.white,
                letterSpacing: 2.0,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
