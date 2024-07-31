import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/models/user.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

enum Status {
  authenticatingEmailPassword,
  authenticatingGoogle,
  unauthenticated,
  authenticated
}

enum GoogleStatus{
  exception,
  canceled,
  successful
}

enum LoginAuthStatus{
  exception,
  noEmailOrPassword,
  error,
  userDisabled,
  successful
}

class AuthenticationNotifier extends ChangeNotifier {

  final _auth = FirebaseAuth.instance;
  User? _user;
  Status _status = Status.unauthenticated;

  Database? _userDataBase;
  AutoShareUser? _autoShareUser;

  String? _messagingToken;

  GoogleSignInAccount? _userGoogle;
  final _googleSignIn = GoogleSignIn();
  GoogleSignInAuthentication? _googleAuth;
  bool _isNewGoogleUser = false;

  FirebaseAuth get auth => _auth;
  Status get status => _status;
  User? get user => _user;
  GoogleSignInAccount? get userGoogle => _userGoogle;
  GoogleSignInAuthentication? get googleAuth => _googleAuth;
  bool get isNewGoogleUser => _isNewGoogleUser;
  AutoShareUser get autoShareUser => _autoShareUser!;
  Database? get userDataBase => _userDataBase;

  set autoShareUser(AutoShareUser autoShareUser) {
    _autoShareUser = autoShareUser;
    notifyListeners();
  }

  set status(Status status) {
    _status = status;
    notifyListeners();
  }

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> switchUserMode(String mode) async {
    _autoShareUser!.lastMode = mode;
    await _userDataBase!.switchUserMode(mode);
  }

  String? getUid() => _user?.uid.characters.string;
  String getEmail() => _user?.email??'';

  bool isAuthenticated() => (_status == Status.authenticated);
  bool isUnAuthenticated() => (_status == Status.unauthenticated);
  bool isAuthenticating() => (isAuthenticatingEmailPassword() || isAuthenticatingGoogle());
  bool isAuthenticatingEmailPassword() => (_status == Status.authenticatingEmailPassword);
  bool isAuthenticatingGoogle() => (_status == Status.authenticatingGoogle);

  AuthenticationNotifier({AutoShareUser? autoShareUser, required String messagingToken}) : _autoShareUser = autoShareUser{
    if (autoShareUser!=null){
      _userDataBase = Database(loggedInAutoShareUser: autoShareUser);
    }
    _autoShareUser = autoShareUser;
    _messagingToken = messagingToken;
    if(isConnectedUser()){
      _user = _auth.currentUser;
      _status = Status.authenticated;
      _userDataBase?.setMessagingToken(token: _messagingToken);
    }
    _auth.authStateChanges().listen( (User? firebaseUser) async {

      developer.log("authStateChanges().listen called", name: "Auth Listen");
      if (firebaseUser == null) {
        _user = null;
        _status = Status.unauthenticated;
        _userGoogle = null;
      }
      else {
        _user = firebaseUser;
        _status = Status.authenticated;
        await _userDataBase?.setMessagingToken(token: _messagingToken);
      }
      notifyListeners();
    }
    );
  }

  bool isConnectedUser(){
    developer.log("isConnectedUser() called" ,name: "Function call");
    if(_auth.currentUser != null){
      return true;
    }
    return false;
  }

  Future<GoogleStatus> googleLogin() async {
    developer.log("googleLogin() called" ,name: "Function call");
    try{
      _status = Status.authenticatingGoogle;
      notifyListeners();
      _userGoogle = await _googleSignIn.signIn();
      developer.log("reached here" ,name: "Function call");
      if(_userGoogle == null){
        _status = Status.unauthenticated;
        notifyListeners();
        return GoogleStatus.canceled;
      }
      _googleAuth = await _userGoogle!.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: _googleAuth!.accessToken,
          idToken: _googleAuth!.idToken
      );
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      if (authResult.additionalUserInfo?.isNewUser != null && authResult.additionalUserInfo!.isNewUser) {
        _isNewGoogleUser = true;

        _autoShareUser = await Database.createNewAutoShareUserDoc(
          id: authResult.user!.uid,
          email: authResult.user!.email ?? "",
          firstName: authResult.user!.displayName?.split(' ')[0] ?? "",
          lastName: authResult.user!.displayName?.split(' ')[1] ?? "",
          profilePicture: authResult.user!.photoURL,
          phone: authResult.user!.phoneNumber,
        );
        _userDataBase ??= Database(loggedInAutoShareUser: _autoShareUser!);
        _userDataBase!.loggedInAutoShareUser = _autoShareUser!;
      }
      else{
        autoShareUser = await Database.getAutoShareUserById(authResult.user!.uid);
        _userDataBase ??= Database(loggedInAutoShareUser: _autoShareUser!);
        _userDataBase!.loggedInAutoShareUser = autoShareUser;

        _isNewGoogleUser = false;
      }
      developer.log(authResult.user.toString(), name: "google user");
      return GoogleStatus.successful;

    }catch(e){
      developer.log(e.toString(), name:"Caught Exception");
      _status = Status.unauthenticated;
      notifyListeners();
      return GoogleStatus.exception;
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    developer.log("signUp() called" ,name: "Function call");
    try {
      _status = Status.authenticatingEmailPassword;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    } catch (e) {
      developer.log(e.toString(), name:"Caught Exception");
      _status = Status.unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<LoginAuthStatus> signIn(String email, String password) async {
    developer.log("signIn() called" ,name: "Function call");
    try {
      _status = Status.authenticatingEmailPassword;
      notifyListeners();

      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      autoShareUser = await Database.getAutoShareUserById(authResult.user!.uid);
      _userDataBase ??= Database(loggedInAutoShareUser: autoShareUser);
      _userDataBase!.loggedInAutoShareUser = autoShareUser;
      return LoginAuthStatus.successful;

    } on FirebaseAuthException catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      switch (e.code) {
        case "user-not-found":
          return LoginAuthStatus.noEmailOrPassword;
        case "wrong-password":
          return LoginAuthStatus.noEmailOrPassword;
        case "user-disabled":
          return LoginAuthStatus.userDisabled;
        default:
          return LoginAuthStatus.error;
      }
    }catch (e) {
      developer.log(e.toString(), name:"Caught Exception");
      _status = Status.unauthenticated;
      notifyListeners();
      return LoginAuthStatus.exception;
    }
  }

  Future<bool> signOut() async {
    developer.log("signOut() called" ,name: "Function call");
    try {
      await _userDataBase?.setMessagingToken(token:null, remove: true);
      _status = Status.unauthenticated;
      notifyListeners();
      await _auth.signOut();
      // if(_userGoogle != null){
      await _googleSignIn.disconnect();
      // }
      return true;
    }
    catch (e) {
      developer.log(e.toString(), name:"Caught Exception");
      _status = Status.unauthenticated;
      return false;
    }
  }

  Future<bool> removeCurrentGoogleUser() async {
    try {
      _status = Status.unauthenticated;
      notifyListeners();

      final credential = GoogleAuthProvider.credential(
          accessToken: _googleAuth!.accessToken,
          idToken: _googleAuth!.idToken
      );
      final UserCredential authResult = await _user!.reauthenticateWithCredential(credential);
      developer.log(authResult.user.toString(), name:"Before delete user");
      await authResult.user!.delete();
      await _googleSignIn.disconnect();

      return true;
    }
    catch (e) {
      developer.log(e.toString(), name:"Caught Exception");
      _status = Status.unauthenticated;
      return false;
    }
  }
}