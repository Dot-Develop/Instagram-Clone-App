import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:instacloneapp/models/user.dart';
import 'package:instacloneapp/pages/home.dart';
import 'package:instacloneapp/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  User user;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser()async{
  setState(() {
    isLoading = true;
  });



 DocumentSnapshot doc =  await usersRef.document(widget.currentUserId).get();
  user = User.fromDocument(doc);
  displayNameController.text = user.displayName;
  bioController.text = user.bio;
  setState(() {
    isLoading = false;
  });

  }

  @override
  void dispose(){
    _formKey.currentState.dispose();
    _scaffoldKey.currentState.dispose();
    super.dispose();
  }

   buildDisplayNameField(){
    return Form(
      key: _formKey,
      child: TextFormField(
        //autovalidate: true,
        validator: (val){
          if(val.isEmpty){
            return 'Display Name is required!';
          }
          if(val.trim().length <3){
            return 'Display Name must be greater than three characters!';
          }
          return null;
        },
        controller: displayNameController,
          decoration: InputDecoration(
          labelText: 'Display Name',
          hintText: 'Update Display Name here',
      ),

      ),
    );
  }
  buildBioField(){
    return TextFormField(
      maxLength: 60,
      controller: bioController,
      decoration: InputDecoration(
        labelText: 'Bio',
        hintText: 'Update Bio here',
      ),

    );
  }

  updateProfileData(){
    usersRef.document(widget.currentUserId).updateData({
      'displayName': displayNameController.text,
      'bio': bioController.text,
    });

    SnackBar snackBar = SnackBar(content: Text('Profile updated!'),);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  logout()async{
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
            'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: ()=> Navigator.pop(context),
              icon: Icon(
                  Icons.done,
                size: 30.0,
                color: Colors.green,
              ),

          ),
        ],
        centerTitle: true,

      ),

      body: isLoading?
      circularProgress():
          ListView(
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                      radius: 50.0,
                    ),
                  ),

                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          buildDisplayNameField(),
                          buildBioField(),
                        ],
                      ),
                    ),

                    RaisedButton(
                        onPressed: (){
                        if(_formKey.currentState.validate()){
                            updateProfileData();
                        }
                    },
                    child: Text(
                      'Update Profile',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: FlatButton.icon(
                          onPressed: (){
                            logout();
                          },
                          icon: Icon(Icons.cancel, color: Colors.red,),
                          label: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0
                              ),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ,
    );
  }
}
