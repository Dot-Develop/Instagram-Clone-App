import 'dart:async';
//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instacloneapp/models/like_count.dart';
import 'package:instacloneapp/models/my_provider.dart';
import 'package:instacloneapp/models/user.dart';
import 'package:instacloneapp/pages/comments.dart';
import 'package:instacloneapp/pages/edit_profile.dart';
import 'package:instacloneapp/pages/home.dart';
import 'package:instacloneapp/widgets/custom_image.dart';
import 'package:instacloneapp/widgets/header.dart';
import 'package:instacloneapp/widgets/post_tile.dart';
import 'package:instacloneapp/widgets/progress.dart';
import 'package:provider/provider.dart';

final activityFeedRef = Firestore.instance.collection('feed');
final timelinePostsRef = Firestore.instance.collection('timeline');

class Profile extends StatefulWidget {
  final String profileId;
  int likeCount;
  int index;
  Profile({this.profileId, this.likeCount = 0, this.index = 0});

  @override
  _ProfileState createState() => _ProfileState(
        likeCount: this.likeCount,
        index: this.index,
      );
}

class _ProfileState extends State<Profile> {
  _ProfileState({this.likeCount, this.index});

  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  bool isFollowing = false;
  List<MyProvider> posts = [];
  String postOrientation = 'grid';
  MyProvider myProvider;
  var showHeart = false;
  var isLiked;
  var test = false;
  int likeCount = 0;
  int index = 0;
  int followerCount = 0;
  int followingCount = 0;
  int postCount = 0;
  //LikeCount likes;
  final Firestore _db = Firestore.instance;

  int getLikeCount(index) {
    if (posts[index].likes == null) {
      return 0;
    }
    int count = 0;
    posts[index].likes.forEach((key, val) {
      if (val == true) {
        count = count + 1;
      }
    });

    return count;
  }

  @override
  void initState() {
    getProfilePosts();
    super.initState();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();

    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();

    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) {
        return MyProvider.fromDocument(doc);
      }).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.blue : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: 'Unfollow',
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: 'Follow',
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() async {
    setState(() {
      isFollowing = false;
    });

    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    QuerySnapshot timelineQuery = await timelinePostsRef
        .document(currentUserId)
        .collection('timelinePosts')
        .getDocuments();

    timelineQuery.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() async {
    setState(() {
      isFollowing = true;
    });

    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});

    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});

    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUser.id,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': DateTime.now(),
    });

//    timelinePostsRef.document(currentUserId).collection('timelinePosts');

    QuerySnapshot followedUserPostsRef = await postsRef
        .document(currentUserId)
        .collection('userPosts')
        .getDocuments();

    print(followedUserPostsRef.documents);
    // var querySnapshot = followedUserPostsRef;

    followedUserPostsRef.documents.forEach((doc) {
      if (doc.exists) {
        var postId = doc.documentID;
        var postData = doc.data;
        timelinePostsRef
            .document(currentUser.id)
            .collection('timelinePosts')
            .document(postId)
            .setData(postData);
      }
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("posts", postCount),
                            buildCountColumn("followers", followerCount),
                            buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  handleLikePost(index) {
    isLiked = posts[index].likes[currentUserId] == true;

    if (isLiked) {
      postsRef
          .document(posts[index].ownerId)
          .collection('userPosts')
          .document(posts[index].postId)
          .updateData({
        'likes.$currentUserId': false,
      }).catchError((e) {
        print(e);
      });
      removeLikeFromActivityFeed();

      setState(() {
        //likes.likeDecrement();
        likeCount -= 1;
        //LikeCount(likeCount: likeCount);

        isLiked = false;
        posts[index].likes[currentUserId] = false;
      });
    } else if (!isLiked) {
      postsRef
          .document(posts[index].ownerId)
          .collection('userPosts')
          .document(posts[index].postId)
          .updateData({
        'likes.$currentUserId': true,
      }).catchError((e) {
        print(e);
      });

      addLikeToActivityFeed();

      setState(() {
        likeCount += 1;
        //likes.likeIncrement();
        //LikeCount(likeCount: likeCount);
        isLiked = true;
        showHeart = true;
        posts[index].likes[currentUserId] = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() async {
    bool isNotPostOwner = currentUserId != posts[index].ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(posts[index].ownerId)
          .collection('feedItems')
          .document(posts[index].postId)
          .setData({
        'type': 'like',
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': posts[index].postId,
        'mediaUrl': posts[index].mediaUrl,
        'timestamp': DateTime.now(),
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != posts[index].ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(posts[index].ownerId)
          .collection('feedItems')
          .document(posts[index].postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        } else {
          print('No document found!');
        }
      });
    }
  }

  buildProfilePosts() {
    //showHeart = test;
    if (isLoading) {
      return circularProgress();
    }
    if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == 'list') {
      if (posts.isEmpty) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/images/no_content.svg',
                height: 260.0,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'No Posts',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        itemCount: posts.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        // mainAxisSize: MainAxisSize.min,
        itemBuilder: (context, index) {
          likeCount = getLikeCount(index);
          //LikeCount(likeCount: likeCount);
          this.index = index;

          return Column(
            children: <Widget>[
              buildPostHeader(index),
              GestureDetector(
                onDoubleTap: () {
                  handleLikePost(index);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    cachedNetworkImage(posts[index].mediaUrl),
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
              ),
              buildPostFooter(index),
            ],
          );
        },
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  FutureBuilder buildPostHeader(index) {
    return FutureBuilder(
      future: usersRef.document(posts[index].ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == posts[index].ownerId;
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
          subtitle: Text(posts[index].location),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    handleDeletePost(context);
                  },
                )
              : Text(''),
        );
      },
    );
  }

  handleDeletePost(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text('Do you want to delete this post?'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                deletePost();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
              ),
            ),
          ],
        );
      },
    );
  }

  deletePost() async {
    // deleting the post
    postsRef
        .document(posts[index].ownerId)
        .collection('userPosts')
        .document(posts[index].postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    timelinePostsRef
        .document(posts[index].ownerId)
        .collection('timelinePosts')
        .document(posts[index].postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // deleting the image post in storage
    storageRef.child('post_${posts[index].postId}.jpg').delete();

    // delete all activity feed notifications
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(posts[index].ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: posts[index].postId)
        .getDocuments();

    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(posts[index].postId)
        .collection('comments')
        .getDocuments();

    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Column buildPostFooter(index) {
    isLiked = posts[index].likes[currentUserId] == true;

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
                handleLikePost(index);
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
                    postId: posts[index].postId,
                    ownerId: posts[index].ownerId,
                    mediaUrl: posts[index].mediaUrl);
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
                likeCount <= 1 ? '$likeCount like' : '$likeCount likes',
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
                posts[index].username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 4.0,
            ),
            Expanded(child: Text(posts[index].description)),
          ],
        ),
      ],
    );
  }

  buildPostToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == 'grid'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () {
            setPostOrientation('grid');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            color: postOrientation == 'list'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () {
            setPostOrientation('list');
          },
        ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    myProvider = Provider.of<MyProvider>(context);
    return Scaffold(
      appBar: header(context, "Profile", 22, true),
      body: RefreshIndicator(
        onRefresh: () => getProfilePosts(),
        child: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(),
            buildPostToggle(),
            Divider(
              height: 0.0,
            ),
            buildProfilePosts(),
          ],
        ),
      ),
    );
  }
}
