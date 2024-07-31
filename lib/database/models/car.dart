import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_share/database/utils.dart';
import 'package:flutter/cupertino.dart';

class Car {
  Car({required this.id,
    required this.make,
    required this.model,
    required this.ownerId,
    required this.licencePlate,
    this.year,
    this.mileage,
    this.gearbox,
    required this.category,
    required this.location,
    this.description,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.pictures,
  });

  final String id;
  final String make;
  final String model;
  final String ownerId;
  final String? licencePlate;
  final int? year;
  final int? mileage;
  final String? gearbox;
  final String category;
  final dynamic location;
  final String? description;
  final int pricePerHour;
  final int pricePerDay;
  final List<String> pictures;

  String get primaryPicture => pictures.isNotEmpty ? pictures.first : 'assets/car_icon.png';

  factory Car.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data();
    return Car(
        id: doc.id,
        make: doc.getValue('make'),
        model: doc.getValue('model'),
        ownerId: doc.getValue('owner_id'),
        licencePlate: doc.getValue('licence_plate'),
        year: doc.getValue('year', throwException: false),
        mileage: doc.getValue('mileage', throwException: false),
        gearbox: doc.getValue('gear_box', throwException: false),
        category: doc.getValue('category'),
        location: doc.getValue('location', throwException: false),
        description: doc.getValue('description', throwException: false),
        pricePerHour: doc.getValue('price_per_hour'),
        pricePerDay: doc.getValue('price_per_day'),
        pictures: doc.getValue('pictures', throwException: false) == null
            ? const <String>[]
            : List.from(doc.getValue('pictures', throwException: false))
                .map((path) => (path as String))
                .toList(),
    );
  }

  Map toJson() => {
    'id' : id.toString(),
    'make' : make.toString(),
    'model' : model.toString(),
    'owner_id' : ownerId.toString(),
    'licence_plate' : licencePlate.toString(),
    'year' : year.toString(),
    'mileage' : mileage.toString(),
    'category' : category.toString(),
    'location' : location.toString(),
    'description' : description.toString(),
    'price_per_hour' : pricePerHour.toString(),
    'price_per_day' : pricePerDay.toString(),
    'pictures' : pictures.toString(),
  };

  @override
  int get hashCode => hashValues(id, make, model, ownerId);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Car otherCar = other;
    return id == otherCar.id;
  }

  @override
  String toString() => "${this.make} ${this.model}";
}
