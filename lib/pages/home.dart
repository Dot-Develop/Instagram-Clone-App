import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instacloneapp/models/my_provider.dart';
import 'package:instacloneapp/models/user.dart';
import 'package:instacloneapp/pages/activity_feed.dart';
import 'package:instacloneapp/pages/create_account.dart';
import 'package:instacloneapp/pages/profile.dart';
import 'package:instacloneapp/pages/search.dart';
import 'package:instacloneapp/pages/upload.dart';
import 'package:provider/provider.dart';
import 'timeline.dart';

final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');

User currentUser;

final StorageReference storageRef = FirebaseStorage.instance.ref();
final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController _pageController;
  int _pageIndex = 0;
  MyProvider post;
  MyProvider myProvider;

  @override
  void initState() {
    currentUser = new User();
    getPost();
    super.initState();

    _pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    });

    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((e) {
      print(e.message);
    });
  }

  getPost() async {
    QuerySnapshot snapshot = await postsRef
        .document(currentUser.id)
        .collection('userPosts')
        .getDocuments();
    //post = MyProvider.fromDocument(snapshot.documents);
    // myProvider = MyProvider.fromDocument(snapshot.documents);
    print(snapshot.documents);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    // check if user exists
    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      //print(username);

      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': DateTime.now(),
      });

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);

//    print(currentUser.id);
//    print(currentUser.username);
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      print(account);
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  loginViaGoogle() async {
    await googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      _pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    myProvider = Provider.of<MyProvider>(context);

    return Scaffold(
      body: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Timeline(currentUser: currentUser, postId: myProvider.postId),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: _pageController,
        onPageChanged: onPageChanged,
        //physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text('Timeline'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            title: Text('Activity Feed'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 35.0),
            title: Text('Upload'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text('Account'),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor,
              ]),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'InstaCloneApp',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Bitter',
                fontSize: 50.0,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                loginViaGoogle();
              },
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
