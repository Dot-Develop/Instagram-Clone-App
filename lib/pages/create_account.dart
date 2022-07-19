import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instacloneapp/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  String username;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  submit(){

    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      SnackBar snackBar = SnackBar(content: Text('Welcome $username'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), (){
        Navigator.pop(context, username);

      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, 'Set up your profile', 22.0, false),

      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text(
                          'Create a username',
                          style: TextStyle(fontSize: 25.0),
                        ),
                    ),
                ),
                Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Form(
                        key: _formKey,
                          child: TextFormField(
                            autovalidate: true,
                            onSaved: (val)=> username = val,
                            validator: (val){
                              if(val.isEmpty){
                                return 'Username is required!';
                              }
                              if(val.trim().length <3){
                                return 'Username must be greater than 3 characters!';
                              }
                              return null;


                            },
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              hintText: 'Enter a username here'
                            ),
                          )
                      ),
                    ),
                ),

                GestureDetector(
                  onTap: submit,
                  child: Container(
                    width: 350.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
