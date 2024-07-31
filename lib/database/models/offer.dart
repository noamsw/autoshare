import 'dart:ui';
import 'car.dart';
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_share/database/utils.dart';
import 'dart:developer' as developer;

class Offer {

  Offer({required this.id,
    required this.owner,
    required this.car,
    required this.location,
    required this.startDateHour,
    required this.endDateHour,
    required this.longitude,
    required this.latitude
  });

  final String id;
  final AutoShareUser owner;
  final Car car;
  final String location;
  final DateTime startDateHour;
  final DateTime endDateHour;
  final double latitude;
  final double longitude;

  factory Offer.createFromMap(String id, Map<String, dynamic> data, Car car, AutoShareUser owner){
    return Offer(
        id: id,
        owner: owner,
        car: car,
        location: data['address'],
        startDateHour: timestampToDatetime(data['start_date'])!,
        endDateHour: timestampToDatetime(data['end_date'])!,
        latitude: data['l'][0],
        longitude: data['l'][1],
    );
  }

  factory Offer.createFromDocument(DocumentSnapshot<Map<String, dynamic>> doc, Car car, AutoShareUser owner){
    return Offer(
        id: doc.id,
        owner: owner,
        car: car,
        location: doc.getValue('address'),
        startDateHour: timestampToDatetime(doc.getValue('start_date'))!,
        endDateHour: timestampToDatetime(doc.getValue('end_date'))!,
        latitude: doc.getValue('l')[0],
        longitude: doc.getValue('l')[1],
    );
  }

  Map toJson() => {
    'owner' : owner.toString(),
    'car' : car.toJson().toString(),
    'location' : location.toString(),
    'start_date' : startDateHour.toString(),
    'end_date' : endDateHour.toString(),
  };

  @override
  int get hashCode => hashValues(id, owner, car, location, startDateHour, endDateHour);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Offer otherOffer = other;
    return id == otherOffer.id;
  }

  @override
  String toString() => "owner: ${owner.toString()}, car: ${car.toString()}";
}
