//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instacloneapp/pages/home.dart';
import 'package:instacloneapp/pages/profile.dart';
import 'package:instacloneapp/widgets/header.dart';
import 'package:instacloneapp/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

final commentsRef = Firestore.instance.collection('comments');

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  Comments({this.postId, this.postOwnerId, this.postMediaUrl});
  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  CommentsState({this.postId, this.postOwnerId, this.postMediaUrl});

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComments() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': DateTime.now(),
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id
    });
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (!isNotPostOwner) {
      activityFeedRef.document(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentController.text,
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': postMediaUrl,
        'timestamp': DateTime.now(),
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, 'Comments', 22.0, true),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Write a comment'),
            ),
            trailing: OutlineButton(
              onPressed: () {
                addComments();
              },
              borderSide: BorderSide.none,
              child: Text('Comment'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String comment;
  final String avatarUrl;
  final Timestamp timestamp;
  Comment(
      {this.username,
      this.userId,
      this.comment,
      this.avatarUrl,
      this.timestamp});

  factory Comment.fromDocument(doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      avatarUrl: doc['avatarUrl'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          title: Text(comment),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
