import 'dart:math';
import 'dart:ui';
import 'package:auto_share/general/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_share/database/utils.dart';
import 'dart:developer' as developer;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';



import 'package:flutter/cupertino.dart';

class AutoShareUser {
  AutoShareUser({required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.birthDate,
    this.licenseNumber,
    this.messagingToken,
    String? profilePicture,
    this.lastMode = 'renter',
  }){
    this.profilePicture = profilePicture ?? 'assets/circle_person_avatar.jpg';
  }

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final DateTime? birthDate;
  final int? licenseNumber;
  final String? messagingToken;
  late String profilePicture;
  String lastMode;
  List<GeographicInfo> searchHistory = [];

  void setSearchHistory(List<GeographicInfo> searchHistoryList) {
    searchHistory = searchHistoryList;
  }

  factory AutoShareUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc, {bool withSearchHistory = false}) {
    return AutoShareUser(
      id: doc.id,
      firstName: doc.getValue('first_name'),
      lastName: doc.getValue('last_name'),
      email: doc.getValue('email'),
      phone: doc.getValue('phone', throwException: false),
      birthDate: timestampToDatetime(doc.getValue('birth_date', throwException: false)),
      licenseNumber: doc.getValue('license_number', throwException: false),
      messagingToken: doc.getValue('messaging_token', throwException: false),
      profilePicture: doc.getValue('profile_picture', throwException: false),
      lastMode: doc.getValue('last_mode', throwException: false)??'renter',
    );
  }

  Map<String,dynamic> toJson() => {
    'id' : id,
    'first_name' : firstName,
    'last_name' : lastName,
    'email' : email,
    'phone' : phone,
    'birth_date' : birthDate,
    'license_number' : licenseNumber,
    'messaging_token' : messagingToken,
    'profile_picture' : profilePicture.startsWith('assets') ? null : profilePicture,
    'last_mode': lastMode,
  };

  @override
  int get hashCode => hashValues(id, firstName, lastName, email);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final AutoShareUser otherUser = other;
    return id == otherUser.id;
  }

  @override
  String toString() => "${firstName.toTitleCase()} ${lastName.toTitleCase()}";
}
