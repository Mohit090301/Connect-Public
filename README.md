# CONNECT
### Chat Application

With over 4000 lines of code and many days of struggle, I have built my Chat Application named "Connect" right from scratch using Flutter.

The database used for storing user's data(name, email, profile pic only) and chats is Firebase(which is a NoSQL database made by Google).The code is mainly written in dart programming language and a small part of it is written in Java Script.

![Screenshot from 2021-05-20 13-09-48](https://user-images.githubusercontent.com/58728847/118939304-28ae0880-b96d-11eb-8a00-0b6a3a45bffb.png)
![Screenshot from 2021-05-20 13-10-00](https://user-images.githubusercontent.com/58728847/118938935-cbb25280-b96c-11eb-9b5c-9707a2107cba.png)
![Screenshot from 2021-05-20 13-04-59](https://user-images.githubusercontent.com/58728847/118939282-221f9100-b96d-11eb-96d8-9014643d390c.png)
![Screenshot from 2021-05-20 13-09-35](https://user-images.githubusercontent.com/58728847/118939293-25b31800-b96d-11eb-9f2b-acb064a95735.png)
![Screenshot from 2021-05-20 13-10-00](https://user-images.githubusercontent.com/58728847/118939835-bd186b00-b96d-11eb-9c9b-72d30c352944.png)
![Screenshot from 2021-05-20 13-16-10](https://user-images.githubusercontent.com/58728847/118939851-c1448880-b96d-11eb-9ad8-3ec0627e5a75.png)
![Screenshot from 2021-05-20 13-17-08](https://user-images.githubusercontent.com/58728847/118939855-c30e4c00-b96d-11eb-88ad-bbc2b54bfb63.png)


The app consists of 10 screens:-
* Sign up screen - In this screen, one can sign up by providing their username, email and password(There are certain restrictions like the username can't be less than 4 letters, password must be atleast 8 characters and the mail shoukd be in proper format)
* Sign In screen - In this screen, one can sign in with his/her email and password provided at the time of signup.
* Chat Room Screen - In this screen you can see the names of all the user's you have messaged, and the settings, profile and search icon.
* Search screen - By tapping at the search button in the Chat Room screen you will be taken to this screen where you can search any user (by their username) you want to text.
* Conversation Screen - In this screen, you can see the profile pic, name and status(whether typing, online or last seen at some time) of the user you are talking to and also all the messages you have sent to each other in proper order.This is the screen where you can "Connect" with the other user.
* Change Profile Screen - By tapping on the profile button in the Chat Room screen, you will be taken to this screen where you can see your own username and email that you provided at the time of Sign Up and in this screen you also have an option to see, update, remove or add your profile pic.
* Profile pic of the user -In this screen you can see the profile pic, username and email of the any user you have messaged.
* Settings screen - In this screen the user has an option to change the theme of the app, log out from the app and change wallpaper for both dark and light theme respectively.
* Unique Profile Pic Screen - In this screen one can change his/her profile pic and that change would be reflected only for a particular user.
* Wallpaper Screen - In this screen the user can choose one of the four options for both dark and light theme to set their conversation screen wallapper.

Packages used:-
1. "firebase_auth" - For enabling android Authentication using email and password 
2. "cloud_firestore" - For storing data in firestore database and also accessing data from it.
3. "shared_preferences" - For reading and writing simple key value pairs.
4. "date_time_format" - For easy formatting of Date and time.
5. "http" - For accessing data via web using http link.
6. "firebase_messaging" - This plugin helps to use Firebase Cloud Messaging API.
7. "path_provider" - For getting the path of the profile pic uploaded by the user in the Firebase Storage.
8. "cupertino_icons" - For using "eye" icon.
9. "cached_network_image" - For caching all the network images so as to render them faster.

-v1.0.0 -> Initial release with basic features(Sign In, Sign Up, searching for a particular user from their username and chatting with the user)

-v1.0.1 -> Added a feature which shows the time at which the user has sent the message. Also when the date changes a text of that date in dd-mm-yy format is shown in the conversation screen.Furthermore, i have also added a feature which shows last message sent in the conversation screen the time at which it was sent. 

-v1.0.2 -> Added Notification feature.It instantly notifies a person as soon as he/she receives a message.The function for notification is written in Java Script and is cloud function(which is a paid feature provided by Firebase).The function triggers as soon as the database detects any kind of document creation in its storage and sends notification to a particular user via a unique token assigned to that user while signing in or signing up.

-v1.0.3 -> Added features like Last Seen of the user and whether the user is online or not(Similar to Whatsapp).Also added a feature which sorts the names of the users you have talked with in proper order.

-v1.0.31 -> Added "Typing" feature.As soon as any user starts typing the status of the user turns from "Online" to "Typing...". Not only the conversation screen but the chat room screen tile also changes from user's last message to "Typing..." (Again similar to Whatsapp)

-v1.0.32 -> Added a feature which lets the user know whether the other person has seen his/her message or not. In the chat room screen a grey colour bulb is added which turns yellow as soon as the other person taps on the message helping the user on the other side know that he/she has seen the message.

-v.1.0.4 -> Added option to add, remove and update profile pic for the users.Removed the feature added in v1.0.3 of sorting the names in chat room(due to some bugs) and the names now appear in alphabetical order.

-v1.0.41 -> Added another screen which shows the profile of the person you are talking to.By simply clicking on the dp of the user (in the chat room screen) or clicking on the name of the user(in the conversation screen) one can see the Profile pic, username and email of that particular user.Also added a loading indicator and snackbar which pops up while adding, removing or updating your own display pic for better user experience.

-v1.0.5 -> Enhanced UX/UI while changing profile picture by adding snackbar and loading animation.Also added an option to remove profile picture.Added a feature which shows "New Message" in the chat room screen if someone hasn't seen the last message of any user(Similar to Instagram).

-v1.0.6 -> Replaced the bulb icon with an eye icon using "cupertino_icons" package.Also added a feature which will let the user know whether the other person has seen the message or not in the conversation screen(Similar to "seen" feature in Instagram).

-v1.0.7 -> Added a feature which helps user to toggle between dark and light theme.

-v1.0.71 -> Added background image for dark and light theme(Image stolen from whatsapp :P) and fixed some bugs

-v1.0.72 -> Changed background image for both dark and light theme as it was copied from whatsapp and made some other UI changes like transparency of chat messages and popping up snackbar while changing theme.

-v1.0.8 -> Added a feature which doesn't allow two or more users to sign up with the same username,i.e,every user has an unique username.

-v1.0.9 -> Added a feature which sorts the names of the users you have talked with in proper order which was removed in v1.0.4 . The bugs were fixed by manipulating the structure of the database.Few other bugs are also fixed in this version.

-v1.1.0 -> Added a feature which helps the user set different profile pic for different users(Unique Profile Picture).

-v1.1.1 -> Changed the notification icon, application icon and application name (from "flutter_chat_app" to "Connect").Also made some changes in DateTime formatting(Replaced today's date and yesterday's date with strings "Today" and "Yesterday" wherever necessary).

-v1.1.2 -> Added a new feature which helps the user to change the wallpaper of both dark and light theme respectively.Replaced all the Network Images with Cached Netwrok Image and as a result the images are rendered much faster.In conversation screen the gap between two msgs will be less if those two msgs are sent by the same user(Similar to whatsapp).Also made some UI enhancements.

-v1.1.3 -> Added a feature which lets users to share images between them.The images shared are not stored in the phone device.Also added feature to display in a new screen the profile pic and the pics shared in the chat by tapping on the photo.

-v1.1.31 -> Added the ability to zoom in and zoom out any photo viewed by the user.Made some UI enhancements as well.
 
           
