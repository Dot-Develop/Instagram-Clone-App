import 'package:flutter/material.dart';
import 'package:instacloneapp/models/my_provider.dart';
import 'package:instacloneapp/pages/post_screen.dart';
import 'package:instacloneapp/widgets/custom_image.dart';

class PostTile extends StatelessWidget {
  final MyProvider post;
  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showPost(context);
      },
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
