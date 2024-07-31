import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/database/utils.dart';


class CarOwnerHistoryItem {

  final String carInfo;
  final DateTime startDate;
  final DateTime endDate;
  final int price;
  final String renterName;
  final String? renterPhone;
  final String location;

  CarOwnerHistoryItem({
    required this.carInfo,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.renterName,
    this.renterPhone,
    required this.location,
  });

  factory CarOwnerHistoryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc){
    return CarOwnerHistoryItem(
      carInfo: doc.getValue('car_info'),
      startDate: timestampToDatetime(doc.getValue('start_date'))!,
      endDate: timestampToDatetime(doc.getValue('end_date'))!,
      price: doc.getValue('price'),
      renterName: doc.getValue('renter_name'),
      renterPhone: doc.getValue('renter_phone'),
      location: doc.getValue('location'),
    );
  }
  factory CarOwnerHistoryItem.fromRequest(Request request) {
    return CarOwnerHistoryItem(
      carInfo: request.offer.car.toString(),
      startDate: request.startDateHour,
      endDate: request.endDateHour,
      price: priceCalculator(request.startDateHour, request.endDateHour, request.offer.car.pricePerHour, request.offer.car.pricePerDay),
      renterName: request.requestedBy.toString(),
      renterPhone: request.requestedBy.phone,
      location: request.offer.location,
    );
  }

  Map<String, dynamic> toJson() => {
    'car_info' : carInfo,
    'start_date' : startDate,
    'end_date' : endDate,
    'price' : price,
    'renter_name' : renterName,
    'renter_phone' : renterPhone,
    'location' : location,
  };
}


class RenterHistoryItem {

  final String carInfo;
  final DateTime startDate;
  final DateTime endDate;
  final int price;
  final String carOwnerName;
  final String? carOwnerPhone;
  final String location;

  RenterHistoryItem({
    required this.carInfo,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.carOwnerName,
    this.carOwnerPhone,
    required this.location,
  });

  factory RenterHistoryItem.fromRequest(Request request) {
    return RenterHistoryItem(
      carInfo: request.offer.car.toString(),
      startDate: request.startDateHour,
      endDate: request.endDateHour,
      price: priceCalculator(request.startDateHour, request.endDateHour, request.offer.car.pricePerHour, request.offer.car.pricePerDay),
      carOwnerName: request.offer.owner.toString(),
      carOwnerPhone: request.offer.owner.phone,
      location: request.offer.location,
    );
  }

  factory RenterHistoryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc){
    return RenterHistoryItem(
      carInfo: doc.getValue('car_info'),
      startDate: timestampToDatetime(doc.getValue('start_date'))!,
      endDate: timestampToDatetime(doc.getValue('end_date'))!,
      price: doc.getValue('price'),
      carOwnerName: doc.getValue('car_owner_name'),
      carOwnerPhone: doc.getValue('car_owner_phone'),
      location: doc.getValue('location'),
    );
  }

  Map<String, dynamic> toJson() => {
    'car_info' : carInfo,
    'start_date' : startDate,
    'end_date' : endDate,
    'price' : price,
    'car_owner_name' : carOwnerName,
    'car_owner_phone' : carOwnerPhone,
    'location' : location,
  };
}