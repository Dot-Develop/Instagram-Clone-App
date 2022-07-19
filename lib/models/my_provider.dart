import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class MyProvider extends StatefulWidget {
  final String profileId;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  MyProvider(
      {this.profileId,
      this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes});

  factory MyProvider.fromDocument(doc) {
    return MyProvider(
      profileId: doc['profileId'],
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  _MyProviderState createState() => _MyProviderState(
        profileId: this.profileId,
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
      );
}

class _MyProviderState extends State<MyProvider> {
  final String profileId;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map likes;
  _MyProviderState({
    this.profileId,
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Text('');
  }
}
