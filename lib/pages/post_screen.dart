//import 'dart:html';

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instacloneapp/models/like_count.dart';
import 'package:instacloneapp/models/my_provider.dart';
import 'package:instacloneapp/models/user.dart';
import 'package:instacloneapp/pages/comments.dart';
import 'package:instacloneapp/pages/home.dart';
import 'package:instacloneapp/pages/profile.dart';
import 'package:instacloneapp/widgets/custom_image.dart';
import 'package:instacloneapp/widgets/header.dart';
import 'package:instacloneapp/widgets/progress.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  final String postId;
  final String userId;
  PostScreen({
    this.postId,
    this.userId,
  });

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  //List<dynamic> postT = [];
  MyProvider post;
  User user;
  List<MyProvider> posts = [];
  var showHeart = false;
  //Profile likeCount;
  int likes = 0;

  @override
  void initState() {
    getUser();
    getProfilePosts();
    super.initState();
  }

//  int getLikeCount(index) {
//    if (posts[index].likes == null) {
//      return 0;
//    }
//    int count = 0;
//    posts[index].likes.forEach((key, val) {
//      if (val == true) {
//        count = count + 1;
//      }
//    });
//
//    return count;
//  }

  getProfilePosts() async {
    QuerySnapshot snapshot = await postsRef
        .document(widget.userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      posts = snapshot.documents.map((doc) {
        return MyProvider.fromDocument(doc);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // likeCount = Provider.of<Profile>(context);
    //likes = getLikeCount(likeCount.index);
    return FutureBuilder(
      future: postsRef
          .document(widget.userId)
          .collection('userPosts')
          .document(widget.postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        post = MyProvider.fromDocument(snapshot.data);

        return Center(
          child: Scaffold(
            appBar: header(context, post.description, 22.0, true),
            body: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                buildPostHeader(),
                buildPostImage(),
                buildPostFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  getUser() async {
    DocumentSnapshot snapshot = await usersRef.document(widget.userId).get();
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
    var isLiked = post.likes[widget.userId] == true;

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
    var isLiked = post.likes[widget.userId] == true;

    if (isLiked) {
      postsRef
          .document(post.ownerId)
          .collection('userPosts')
          .document(post.postId)
          .updateData({
        'likes.${widget.userId}': false,
      }).catchError((e) {
        print(e);
      });
      // removeLikeFromActivityFeed();

      setState(() {
        likes -= 1;
        isLiked = false;
        post.likes[widget.userId] = false;
      });
    } else if (!isLiked) {
      postsRef
          .document(post.ownerId)
          .collection('userPosts')
          .document(post.postId)
          .updateData({
        'likes.${widget.userId}': true,
      }).catchError((e) {
        print(e);
      });

      //addLikeToActivityFeed();

      setState(() {
        likes += 1;
        isLiked = true;
        showHeart = true;
        post.likes[widget.userId] = true;
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
