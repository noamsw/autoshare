import 'dart:developer' as developer;
import 'dart:io';
import 'package:auto_share/general/network_status_service.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/storage_api.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/router/my_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({Key? key, required RouterArgs routerArgs}) : _routerArgs = routerArgs, super(key: key);
  final RouterArgs _routerArgs;


  @override
  ProfilePictureScreenState createState() {
    return ProfilePictureScreenState();
  }
}

// Create a corresponding State class.
class ProfilePictureScreenState extends State<ProfilePictureScreen> {

  var defaultProfilePic = const AssetImage('assets/circle_person_avatar.jpg');


  File? chosenProfilePic;
  String? pickedImagePath;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    context.watch<AuthenticationNotifier>().status;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Profile picture'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Choose a profile picture to your account',
                  style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(10,0,0,0),
                child: Text(
                  'A profile picture is recommended to make your account more trustworthy to others',
                  style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                  ),
                ),
              ),
              const Padding(
                  padding: EdgeInsets.fromLTRB(10,0,10,10),
                  child: Divider()
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,10,0,10),
                child: CircleAvatar(
                  backgroundImage: chosenProfilePic != null ? Image.file(chosenProfilePic!).image : defaultProfilePic,
                  backgroundColor: Colors.white,
                  radius: 70,
                  child: const Align(
                    alignment: Alignment.bottomRight,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                      ),
                      child: const Text('Choose a photo'),
                      onPressed: () async {
                        if (chosenProfilePic != null) {
                          // widget.imageRemoved(_image!);
                          chosenProfilePic!.delete();
                          chosenProfilePic = null;
                        }
                        var pickedImage = await ImagePicker().pickImage(
                          imageQuality: 10,
                          source: ImageSource.gallery,
                        );
                        if(pickedImage != null){
                          setState(() {
                            pickedImagePath = pickedImage.path;
                            chosenProfilePic = File(pickedImage.path);
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: (!context.read<AuthenticationNotifier>().isUnAuthenticated()) ? null :
                          () async {
                        if(context.read<NetworkStatusNotifier>().status == NetworkStatus.offline){
                              snackBarMassage(scaffoldKey: _scaffoldKey, msg: "No network connection");
                              return;
                            }
                        developer.log(widget._routerArgs.controllerMap.toString(), name: "widget._routerArgs.controllerMap.toString()");

                        var userFirstName = widget._routerArgs.controllerMap['firstNameController']!.text;
                        var userLastName = widget._routerArgs.controllerMap['lastNameController']!.text;
                        var userEmail = widget._routerArgs.controllerMap['emailController']!.text;
                        var userPassword = widget._routerArgs.controllerMap['passwordController']!.text;
                        var userPhoneNumber = widget._routerArgs.controllerMap['phoneNumberController']!.text;
                        var birthDate = widget._routerArgs.controllerMap['birthDateController']!.text;
                        var licenseNumber = widget._routerArgs.controllerMap['licenseNumberController']!.text;

                        var userCredential = await context.read<AuthenticationNotifier>().signUp(userEmail, userPassword);
                        // var userCredential = null;
                        List<String> birthDateSplit = birthDate.split("-");
                        if(userCredential != null){
                          var imageUrls =  chosenProfilePic != null ? await StorageService.uploadImages([chosenProfilePic!],'profile_pictures/') : null;
                          if(!mounted) return;
                          context.read<AuthenticationNotifier>().autoShareUser = await Database.createNewAutoShareUserDoc(
                            id: userCredential.user!.uid,
                            firstName: userFirstName,
                            lastName: userLastName,
                            email: userEmail,
                            phone: userPhoneNumber == "" ? null : userPhoneNumber,
                            birthDate: (birthDate != "") ? DateTime(int.parse(birthDateSplit[0]), int.parse(birthDateSplit[1]), int.parse(birthDateSplit[2])) : null,
                            licenseNumber: licenseNumber == "" ? null : int.parse(licenseNumber),
                            profilePicture: imageUrls?[0],
                          );
                          if(!mounted) return;
                          context.read<AuthenticationNotifier>().userDataBase!.loggedInAutoShareUser = context.read<AuthenticationNotifier>().autoShareUser;
                          developer.log('Signup successful, going to main screen', name: "goNamed(renter)");
                          context.goNamed(RouteConstants.homeRoute);
                        }else{
                          snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'There was an error signing up into the app');
                        }
                      },
                      child: (!context.read<AuthenticationNotifier>().isUnAuthenticated())
                          ? const Center(child: SizedBox(height: 30, child: CircularProgressIndicator(),))
                          : const Text('SIGN UP'),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          '${widget._routerArgs.pageIndex} out of 7',
                          style: const TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),
                      )
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}
