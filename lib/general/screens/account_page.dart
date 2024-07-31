import 'dart:developer' as developer;
import 'dart:io';

import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/storage_api.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_share/general/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required UserMode userMode})  : _userMode = userMode ,super(key: key);
  final UserMode _userMode;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isNewProfileLoading = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(0,10,0,0),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.watch<AuthenticationNotifier>().autoShareUser.toString().toTitleCase(),
                        style: const TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),
                      ),
                    ),
                  )
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,0,10),
                child: CircleAvatar(
                  backgroundColor: Colors.black12,
                  radius: 70,
                  child: CircleAvatar(
                    backgroundColor: Colors.black12,
                    // backgroundImage: profileImage(context.watch<AuthenticationNotifier>().autoShareUser.profilePicture),
                    radius: 65,
                    foregroundColor: Colors.blue,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: context.watch<AuthenticationNotifier>().autoShareUser.profilePicture,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Image(
                              image: AssetImage('assets/circle_person_avatar.jpg'),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                // color: Palette.autoShareBlue,
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                height: 35,
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: const BoxDecoration(
                                  color: Palette.autoShareBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            // child: const Text(
                            //   'edit',
                            //   style: TextStyle(
                            //     decoration: TextDecoration.underline,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            onTap: () async {
                              try{
                                var pickedImage = await ImagePicker().pickImage(
                                  imageQuality: 10,
                                  source: ImageSource.gallery,
                                );
                                if(pickedImage != null){
                                  setState(() {
                                    isNewProfileLoading = true;
                                  });
                                  if(!mounted) return;
                                  if (context.read<AuthenticationNotifier>().autoShareUser.profilePicture.startsWith("https://firebasestorage")) {
                                    await StorageService.deleteImage(context.read<AuthenticationNotifier>().autoShareUser.profilePicture);
                                  }
                                  var imageUrls = await StorageService.uploadImages([File(pickedImage.path)],'profile_pictures/');

                                  if(!mounted) return;
                                  var user = context.read<AuthenticationNotifier>().autoShareUser;
                                  context.read<AuthenticationNotifier>().autoShareUser = await Database.createNewAutoShareUserDoc(
                                    id: user.id,
                                    firstName: user.firstName,
                                    lastName: user.lastName,
                                    email: user.email,
                                    phone: user.phone,
                                    birthDate: user.birthDate,
                                    licenseNumber: user.licenseNumber,
                                    profilePicture: imageUrls[0],
                                  );
                                  if(!mounted) return;
                                  context.read<AuthenticationNotifier>().userDataBase!.loggedInAutoShareUser = context.read<AuthenticationNotifier>().autoShareUser;
                                  setState(() {
                                    isNewProfileLoading = false;
                                  });
                                }
                              }catch(e){
                                developer.log(e.toString(), name:"Caught Exception");
                                setState(() {
                                  isNewProfileLoading = false;
                                });
                                snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'error editing profile picture');
                              }
                            },
                          ),
                        ),
                        isNewProfileLoading ? const CircularProgressIndicator() : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.white70,
                        shadowColor: Colors.grey,
                      ),
                      onPressed: () {
                        developer.log('_userMode: ${widget._userMode}',name: 'Value inspection');
                        if(widget._userMode == UserMode.renterMode){
                          context.goNamed(RouteConstants.ownerRoute);
                          context.read<AuthenticationNotifier>().switchUserMode('owner');
                        }
                        else if(widget._userMode == UserMode.ownerMode){
                          context.read<AuthenticationNotifier>().switchUserMode('renter');
                          context.goNamed(RouteConstants.renterRoute);
                        }
                        else{
                          snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'Problem with switching modes');
                        }
                      },
                      child: Column(
                        children: const <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0,5,0,0),
                            child: Text(
                              'Switch mode',
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                              ),
                            ),
                          ),
                          Icon(
                            Icons.swap_horiz,
                            size: 30,
                          )
                        ],
                      ),
                    )
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: const Divider(
                  color: Colors.black87,
                ),
              ),
              ListTile(
                  title: const Text('Personal details'),
                  trailing:const Icon(Icons.person_pin_rounded),
                  onTap: (){
                    if(widget._userMode == UserMode.renterMode){
                      context.pushNamed(RouteConstants.renterDetails);
                    }
                    else if(widget._userMode == UserMode.ownerMode){
                      context.pushNamed(RouteConstants.ownerDetails);
                    }
                    else{
                      snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'Problem with presenting user details');
                    }
                  },
                  visualDensity: const VisualDensity(vertical: -4)
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: const Divider(
                  color: Colors.black87,
                ),
              ),
              ListTile(
                  title: const Text('Rental history'),
                  trailing: const Icon(Icons.history_outlined),
                  onTap: (){
                    if(widget._userMode == UserMode.renterMode){
                      context.pushNamed(RouteConstants.renterRentalHistory);
                    }
                    else if(widget._userMode == UserMode.ownerMode){
                      context.pushNamed(RouteConstants.ownerRentalHistory);
                    }
                    else{
                      snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'Problem with presenting rental history');
                    }
                  },
                  visualDensity: const VisualDensity(vertical: -4)
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: const Divider(
                  color: Colors.black87,
                ),
              ),
              ListTile(
                  title: const Text('Licenses'),
                  trailing: const Icon(Icons.info),
                  onTap: () async {
                    PackageInfo packageInfo = await PackageInfo.fromPlatform();
                    String version = packageInfo.version;

                    showAboutDialog(
                      context: context,
                      applicationName: 'AutoShare',
                      applicationVersion: version,
                    );
                  },
                  visualDensity: const VisualDensity(vertical: -4)
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: const Divider(
                  color: Colors.black87,
                ),
              ),
              ListTile(
                  title: const Text('Sign out'),
                  trailing: const Icon(Icons.logout),
                  onTap: () async {

                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                          title: const Text("Are you sure you want to sign out?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {

                                Navigator.of(context).pop();

                                context.read<AuthenticationNotifier>().signOut();
                                snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'Signed out');
                                context.goNamed(RouteConstants.loginRoute);
                              },
                              child: const Text(
                                "Sign out",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ]
                      );
                    });
                  },
                  visualDensity: const VisualDensity(vertical: -4)
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: const Divider(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        )
    );
  }
}