import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DatesRange {
  DateTime start;
  DateTime end;
  DatesRange(this.start, this.end);
  int get diff => end.difference(start).inDays;
}

dynamic profileImage(String? path){
  if(path == null || path.isEmpty){
    return const AssetImage('assets/circle_person_avatar.jpg');
  }
  else if (path.startsWith('assets')){
    return AssetImage(path);
  }
  return CachedNetworkImageProvider(
      path
  );
}

dynamic carImage(String path){
  if (path.startsWith('assets')){
    return Image(image: AssetImage(path));
  }
  return CachedNetworkImage(
    imageUrl: path,
    fit: BoxFit.cover,
    progressIndicatorBuilder: (context, url, progress) => Center(
      child: CircularProgressIndicator(
        value: progress.progress,
      ),
    ),
  );
}

class MissingField implements Exception {
  String field;
  String docId;
  MissingField(this.field, this.docId):super();

  @override
  toString() => "Missing field: $field in document: $docId";
}

class MissingDocument implements Exception {
  String docId;
  MissingDocument(this.docId):super();

  @override
  toString() => "Missing document: $docId";
}

class CarHasOffers implements Exception {
  String carId;
  CarHasOffers(this.carId):super();

  @override
  toString() => "'Cannot delete car that has offers'";
}

class OfferHasRelatedRequests implements Exception {
  String offerId;
  OfferHasRelatedRequests(this.offerId):super();

  @override
  toString() => "This change interferes with related requests";
}

class UserHasRequestOnOffer implements Exception {
  String offerId;
  UserHasRequestOnOffer(this.offerId):super();

  @override
  toString() => "You already have a confirmed request for these dates";
}

class OfferConflict implements Exception {
  OfferConflict():super();

  @override
  toString() => "There is a times conflict with another offer of that car.";
}

extension QuerySnapshotExtension on QuerySnapshot<Map<String, dynamic>> {
  QueryDocumentSnapshot<Map<String, dynamic>> getDocById(String id){
    var res = docs.where((doc) => id==doc.id);
    if (res.isNotEmpty){
      return res.first;
    }
    else{
      throw MissingDocument(id);
    }
  }
}

extension DocumentSnapshotExtension on DocumentSnapshot<Map<String, dynamic>>{

  dynamic getValue(String key, {bool throwException=true}){
    if (data()?.keys.contains(key)??false){
      return data()![key];
    }
    else{
      if (throwException){
        throw MissingField(key, id);
      }
      else{
        return null;
      }
    }
  }
}

DateTime? timestampToDatetime(dynamic timestamp){
  if (timestamp.runtimeType.toString() != 'Timestamp'){
    return null;
  }
    return timestamp.toDate();
}

int priceCalculator(DateTime startDate, DateTime endDate, int pricePerHour, int pricePerDay){
  int price;
  int hoursDiff = endDate.difference(startDate).inHours;
  if(hoursDiff == 0){
    hoursDiff+=1;
  }
  DateTime startDay = DateTime(startDate.year,startDate.month,startDate.day);
  DateTime endDay = DateTime(endDate.year,endDate.month,endDate.day);
  int daysDiff = endDay.difference(startDay).inDays + 1;
  if(hoursDiff < 24){
    price =  min(pricePerHour*hoursDiff, pricePerDay*daysDiff);
    return price;
  }
  return pricePerDay * daysDiff;
}

String formattedDatesRange(DateTime startDate, DateTime endDate){
  const format = [M, ' ', d, ' • ', H, ':', nn];
  return "${formatDate(startDate, format)} - ${formatDate(endDate, format)}";
}

bool checkIfTimesOverlap(DateTime startDate1, DateTime endDate1, DateTime startDate2, DateTime endDate2){
  return (endDate2.isAfter(startDate1) && endDate1.isAfter(startDate2));
}

bool isOfferAvailableOnDates(DocumentSnapshot<Map<String, dynamic>> offerDoc,
    DateTime startDate, DateTime endDate) {
  DateTime offerStartDate = timestampToDatetime(offerDoc.get('start_date'))!;
  DateTime offerEndDate = timestampToDatetime(offerDoc.get('end_date'))!;
  if (startDate.isBefore(offerStartDate) || endDate.isAfter(offerEndDate)) {
    return false;
  }
  bool res = true;
  Map<String, dynamic> offerConfirmedRequests =
      offerDoc.getValue('confirmed_requests', throwException: false) ?? {};
  offerConfirmedRequests.forEach((key, value) {
    List datesRange = value as List;
    if (checkIfTimesOverlap(
        startDate,
        endDate,
        timestampToDatetime(datesRange[0])!,
        timestampToDatetime(datesRange[1])!)) {
      res = false;
    }
  });
  return res;
}

class GeographicInfo{
  GeographicInfo({this.geopoint, required this.address, this.icon, this.currentLocation = false, this.placeId});
  final LatLng? geopoint;
  final String address;
  final Icon? icon;
  final bool currentLocation;
  final String? placeId;

  Map<String,dynamic> toMap(){
    return {
      'address': address,
      'geo_point': GeoPoint(geopoint!.latitude, geopoint!.longitude),
    };
  }

  factory GeographicInfo.fromMap(Map<String,dynamic> map){
    return GeographicInfo(
      geopoint: LatLng(map['geo_point'].latitude, map['geo_point'].longitude),
      address: map['address'],
      icon: const Icon(Icons.history),
    );
  }

  @override
  String toString() => "Latitude: ${geopoint?.latitude}, Longitude: ${geopoint?.longitude}, Address: $address";
}
