import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instacloneapp/pages/home.dart';
import 'package:instacloneapp/pages/profile.dart';
import 'package:provider/provider.dart';
import 'package:instacloneapp/models/my_provider.dart';
import 'models/my_provider.dart';

void main() {
//  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
//    print('timestamps enabled from snapshots. \n');
//  }, onError: (_) {
//    print('error enabling timestamps in snapshots.. \n');
//  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  GoogleSignInAccount id = googleSignIn.currentUser;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MyProvider>(
          create: (context) => MyProvider(),
        ),
        Provider<Profile>(
          create: (context) => Profile(),
        ),
      ],
      child: MaterialApp(
        title: 'InstaCloneApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Bitter',
          primarySwatch: Colors.purple,
          accentColor: Colors.teal,
        ),
        home: Home(),
      ),
    );
  }
}
