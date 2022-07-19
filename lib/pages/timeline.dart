//import 'dart:html';

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instacloneapp/models/my_provider.dart';
import 'package:instacloneapp/models/user.dart';
import 'package:instacloneapp/pages/home.dart';
import 'package:instacloneapp/pages/profile.dart';
import 'package:instacloneapp/widgets/custom_image.dart';
import 'package:instacloneapp/widgets/header.dart';
import 'package:instacloneapp/widgets/progress.dart';

import 'comments.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  final String postId;
  Timeline({this.currentUser, this.postId});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<MyProvider> posts;
  User user;
  MyProvider post;
  int likes = 0;
  var showHeart = false;

  @override
  void initState() {
    super.initState();
    getTimeline();
    getUser();
    //print(widget.postId);
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelinePostsRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      posts = snapshot.documents
          .map((doc) => MyProvider.fromDocument(doc))
          .toList();
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, 'InstaCloneApp', 30.0, false),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: Center(
            child: Container(
          child: Text('Under Progress...'),
        )),
        //FutureBuilder(
//          future: timelinePostsRef
//              .document(widget.currentUser.id)
//              .collection('timelinePosts')
//              .document('3f8b7ef2-c761-4a63-af5a-9866fb924d69')
//              .get(),
//          builder: (context, snapshot) {
//            if (!snapshot.hasData) {
//              return circularProgress();
//            }
//            print('${snapshot.data} , test');
//            post = MyProvider.fromDocument(snapshot.data);
//
//            return Center(
//              child: ListView(
//                shrinkWrap: true,
//                physics: ClampingScrollPhysics(),
//                children: <Widget>[
//                  buildPostHeader(),
//                  buildPostImage(),
//                  buildPostFooter(),
//                ],
//              ),
//            );
//          },
//        ),
      ),
    );
  }

  getUser() async {
    DocumentSnapshot snapshot =
        await usersRef.document(widget.currentUser.id).get();
    user = User.fromDocument(snapshot.data);
  }

  buildPostHeader() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(user.photoUrl),
        backgroundColor: Colors.grey,
      ),
      title: GestureDetector(
        onTap: () {
          showProfile(context, profileId: user.id);
        },
        child: Text(
          user.username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      subtitle: Text(post.location),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {},
      ),
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        handleLikePost();
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(post.mediaUrl),
          showHeart
              ? AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.favorite,
                    size: 80.0,
                    color: Colors.red,
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }

  Column buildPostFooter() {
    var isLiked = post.likes[widget.currentUser.id] == true;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () {
                handleLikePost();
              },
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,

                // Icons.favorite_border,
                size: 30.0,
                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () {
                showComments(context,
                    postId: post.postId,
                    ownerId: post.ownerId,
                    mediaUrl: post.mediaUrl);
              },
              child: Icon(
                Icons.chat,
                size: 30.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                likes <= 1 ? '$likes like' : '$likes likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                post.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 4.0,
            ),
            Expanded(child: Text(post.description)),
          ],
        ),
      ],
    );
  }

  handleLikePost() {
    var isLiked = post.likes[widget.currentUser.id] == true;

    if (isLiked) {
      postsRef
          .document(post.ownerId)
          .collection('userPosts')
          .document(post.postId)
          .updateData({
        'likes.${widget.currentUser.id}': false,
      }).catchError((e) {
        print(e);
      });
      // removeLikeFromActivityFeed();

      setState(() {
        likes -= 1;
        isLiked = false;
        post.likes[widget.currentUser.id] = false;
      });
    } else if (!isLiked) {
      postsRef
          .document(post.ownerId)
          .collection('userPosts')
          .document(post.postId)
          .updateData({
        'likes.${widget.currentUser.id}': true,
      }).catchError((e) {
        print(e);
      });

      //addLikeToActivityFeed();

      setState(() {
        likes += 1;
        isLiked = true;
        showHeart = true;
        post.likes[widget.currentUser.id] = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  showComments(BuildContext context,
      {String postId, String ownerId, String mediaUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Comments(
        postId: postId,
        postOwnerId: ownerId,
        postMediaUrl: mediaUrl,
      );
    }));
  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Profile(
          profileId: profileId,
        ),
      ),
    );
  }
}
