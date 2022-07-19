import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instacloneapp/models/user.dart';
import 'package:instacloneapp/pages/home.dart';
import 'package:instacloneapp/pages/profile.dart';
import 'package:instacloneapp/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();

  Future<QuerySnapshot> searchResultFuture;
  handleSearch(String product) {
    //final usersRef = Firestore.instance.collection('users');
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isGreaterThanOrEqualTo: product)
        .getDocuments();

    setState(() {
      searchResultFuture = users;
      if (_searchController.text.trim().length == 0) {
        clearSearch();
      }
    });
  }

  clearSearch() {
    _searchController.clear();

    setState(() {
      searchResultFuture = null;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          filled: true,
          prefixIcon: Icon(Icons.account_box),
          suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                clearSearch();
              }),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              'Find users',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {

          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });

        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: buildSearchField(),
      body:
          searchResultFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.purple[300], Colors.teal[300]],
      )),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              showProfile(context, profileId: user.id);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
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
