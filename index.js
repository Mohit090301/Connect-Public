const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
const fcm = admin.messaging();

exports.notifyNewMessage = functions.firestore.
    document("ChatRoom/{chatRoomId}/chats/{chatId}").
    onCreate(async (snapshot) => {
      const msg = snapshot.data();
      console.log(msg.sendBy);
      console.log(msg.receivedBy);
      var sendBy = msg.sendBy;
      var receivedBy = msg.receivedBy;
      var isImage = msg.isImage;
      console.log(isImage);
      const deviceTokens = await db.collection("users")
          .doc(msg.receivedBy)
          .collection("tokens").get();
      var docId;
      if(sendBy < receivedBy)
        docId = sendBy + "*" + receivedBy;
      else
        docId = receivedBy + "*" + sendBy;
      var url = "";
      var index;
      const snap = await db.collection("ChatRoom").doc(docId).get();
      if(snap.data()["users"][0] == sendBy)
        index = 0;
      else
        index = 1;
      url = snap.data()["profilePicUrl"][index];
      console.log(url);
      var tokens = [];
      for(var tkn of deviceTokens.docs){
        tokens.push(tkn.data().token);
      }
      console.log(tokens);
      if(isImage){
      console.log(msg.message);
      const payload = {
      notification: {
          title: msg.sendBy,
          body: "Image",
          icon: "ic_sharp_connect_without_contact_24",
          tag: msg.sendBy,
          image: msg.message,
          picture: msg.message,
          priority: "max",
          imageUrl: msg.message,
        },
        data : {
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        }
        };
        const res = await fcm.sendToDevice(tokens, payload);
              console.log('Message Sent Successfully');
      }
      else
      {
         const payload = {
                    notification: {
                      title: msg.sendBy,
                      body: msg.message,
                      icon: "ic_sharp_connect_without_contact_24",
                      tag: msg.sendBy,

                    },
                    data : {
                      click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    }
                  };
         const res = await fcm.sendToDevice(tokens, payload);
               console.log('Message Sent Successfully');
      }
    });