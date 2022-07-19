////import 'dart:html';
//
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:instacloneapp/pages/home.dart';
//import 'package:instacloneapp/pages/profile.dart';
//
//class Post extends StatefulWidget {
//  final String postId;
//  final String ownerId;
//  final String username;
//  final String location;
//  final String description;
//  final String mediaUrl;
//  final dynamic likes;
//  Post({this.postId, this.ownerId, this.username,this.location, this.description,this.mediaUrl,this.likes}){
//    Home(likes: likes,);
//    Profile(likes: likes, profileId: ownerId,);
//
//
//  }
//
//  factory Post.fromDocument(DocumentSnapshot doc){
//    return Post(
//      postId: doc['postId'],
//      ownerId: doc['ownerId'],
//      username: doc['username'],
//      location: doc['location'],
//      description: doc['description'],
//      mediaUrl: doc['mediaUrl'],
//      likes: doc['likes'],
//
//    );
//
//
//  }
//
//  int getLikeCount(likes){
//    if(likes == null){
//      return 0;
//    }
//    int count = 0;
//    likes.value.forEach((val){
//      if(val == true){
//        count = count +1;
//      }
//    });
//    return count;
//  }
//
//  @override
//  _PostState createState() => _PostState(
//    postId: this.postId,
//    ownerId: this.ownerId,
//    username: this.username,
//    location: this.location,
//    description: this.description,
//    mediaUrl: this.mediaUrl,
//    likes: this.likes,
//    likeCount: this.getLikeCount(this.likes)
//  );
//}
//
//
//class _PostState extends State<Post> {
//
//
//  final String postId;
//  final String ownerId;
//  final String username;
//  final String location;
//  final String description;
//  final String mediaUrl;
//  int likeCount;
//  Map likes;
//  _PostState({this.postId, this.ownerId, this.username,this.location, this.description,this.mediaUrl,this.likes, this.likeCount});
//
//
//  @override
//  void initState() {
//    Home(likes: likes,);
//    super.initState();
//  }
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return null;
//  }
//
////   FutureBuilder buildPostHeader(){
////    return FutureBuilder(
////      future: usersRef.document(ownerId).get(),
////        builder: (context , snapshot){
////          if(!snapshot.hasData){
////            return circularProgress();
////          }
////
////          User user = User.fromDocument(snapshot.data);
////          return ListTile(
////            leading: CircleAvatar(
////              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
////              backgroundColor: Colors.grey,
////            ),
////            title: GestureDetector(
////              onTap: (){
////
////              },
////              child: Text(
////                  user.username,
////                  style: TextStyle(
////                    fontWeight: FontWeight.bold,
////                    color: Colors.black,
////                  ),
////              ),
////            ),
////            subtitle: Text(location),
////            trailing: IconButton(
////                icon: Icon(Icons.more_vert),
////                onPressed: (){
////
////                },
////            ),
////          );
////        },
////    );
////  }
////
//// GestureDetector buildPostImage(){
////    return GestureDetector(
////      onDoubleTap: (){
////
////      },
////      child: Stack(
////        alignment: Alignment.center,
////        children: <Widget>[
////            Image.network(mediaUrl),
////        ],
////      ),
////    );
////  }
////
////  Column buildPostFooter(){
////    return Column(
////      children: <Widget>[
////        Row(
////          mainAxisAlignment: MainAxisAlignment.start,
////          children: <Widget>[
////            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0),),
////            GestureDetector(
////              onTap: (){
////
////              },
////              child: Icon(
////                Icons.favorite_border,
////                size: 30.0,
////              color: Colors.pink,
////              ),
////            ),
////            Padding(padding: EdgeInsets.only(right: 20.0),),
////            GestureDetector(
////              onTap: (){
////
////              },
////              child: Icon(
////                Icons.chat,
////                size: 30.0,
////                color: Colors.blue[900],
////              ),
////            ),
////
////
////          ],
////        ),
////        Row(
////          mainAxisAlignment: MainAxisAlignment.start,
////          children: <Widget>[
////            Container(
////              margin: EdgeInsets.only(left: 20.0),
////              child: Text(
////                '$likeCount likes',
////                style: TextStyle(
////                  color: Colors.black,
////                  fontWeight: FontWeight.bold,
////                ),
////              ),
////            ),
////
////          ],
////        ),
////
////        Row(
////          crossAxisAlignment: CrossAxisAlignment.start,
////          children: <Widget>[
////            Container(
////              margin: EdgeInsets.only(left: 20.0),
////              child: Text(
////                '$username',
////                style: TextStyle(
////                  color: Colors.black,
////                  fontWeight: FontWeight.bold,
////                ),
////              ),
////            ),
////            Expanded(child: Text(description)),
////
////          ],
////        ),
////      ],
////    );
////  }
////
////  @override
////  Widget build(BuildContext context) {
////    return Column(
////      mainAxisSize: MainAxisSize.min,
////      children: <Widget>[
////        buildPostHeader(),
////        buildPostImage(),
////        buildPostFooter(),
////
////      ],
////    );
////  }
//}
