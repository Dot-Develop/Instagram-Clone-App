//import 'dart:html';

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:instacloneapp/models/user.dart';
import 'package:instacloneapp/widgets/progress.dart';
import 'package:image/image.dart' as im;
import 'package:uuid/uuid.dart';
import 'home.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  //final picker = ImagePicker();
  File _file;
  bool isUploading = false;
  String postId = Uuid().v4();
//  handleTakePhoto() async {
//    Navigator.pop(context);
//    File file = await ImagePicker.pickImage(
//        source: ImageSource.camera, maxHeight: 675.0, maxWidth: 960.0);
//
//    setState(() {
//      _file = file;
//    });
//  }

//  Future handleChooseFromGallery() async {
//    Navigator.pop(context);
//    PickedFile file = await picker.getImage(
//        source: ImageSource.gallery, maxHeight: 675.0, maxWidth: 960.0);
//    setState(() {
//      _file = File(file.path);
//    });
//  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo with camera'),
                onPressed: () {
                  //    handleTakePhoto();
                },
              ),
              SimpleDialogOption(
                child: Text('Image from gallery'),
                onPressed: () {
                  //handleChooseFromGallery();
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              onPressed: () {
                selectImage(context);
              },
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      _file = null;
    });
  }

//  compressImage() async {
//    //final tempDir = await getTemporaryDirectory();
//    final path = tempDir.path;
//    im.Image imageFile = im.decodeImage(_file.readAsBytesSync());
//    final compressedImageFile = File('$path/img_$postId.jpg')
//      ..writeAsBytesSync(im.encodeJpg(imageFile, quality: 85));
//
//    setState(() {
//      _file = compressedImageFile;
//    });
//  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'location': location,
      'description': description,
      'timestamp': DateTime.now(),
      'likes': {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    // await compressImage();
    String mediaUrl = await uploadImage(_file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    locationController.clear();
    captionController.clear();
    setState(() {
      _file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        backgroundColor: Colors.white70,
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(''),
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              size: 35.0,
              color: Colors.orange,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Where was this photo taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: () {
                getUserLocation();
              },
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                'Use Current Location',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAddress = '${placemark.locality}, ${placemark.country}';
    locationController.text = formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return _file == null ? buildSplashScreen() : buildUploadForm();
  }
}
