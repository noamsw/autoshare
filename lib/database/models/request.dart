import 'dart:ui';
import 'offer.dart';
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_share/database/utils.dart';

enum RequestStatus {
  pending,
  confirmed,
  rejected
}

class Request {

  Request({required this.id,
    required this.requestedBy,
    required this.offer,
    this.status,
    required this.startDateHour,
    required this.endDateHour,
    required this.createdAt,
    this.renterApprovedPickUp = false,
    this.ownerApprovedReturn = false,
    this.extra,
  });

  final String id;
  final AutoShareUser requestedBy;
  final Offer offer;
  RequestStatus? status;
  final DateTime startDateHour;
  final DateTime endDateHour;
  final DateTime createdAt;
  bool renterApprovedPickUp = false;
  bool ownerApprovedReturn = false;
  Object? extra;

  factory Request.create(DocumentSnapshot<Map<String, dynamic>> doc, Offer offer, AutoShareUser requestedBy){
    return Request(
        id: doc.id,
        offer: offer,
        requestedBy: requestedBy,
        status: RequestStatus.values.byName(doc.getValue('status')),
        startDateHour: timestampToDatetime(doc.getValue('start_date')) ??
            DateTime(2022),
        endDateHour: timestampToDatetime(doc.getValue('end_date')) ??
            DateTime(2022),
        createdAt: timestampToDatetime(doc.getValue('created_at')) ??
            DateTime(2022),
        renterApprovedPickUp: doc.getValue('renter_approved_pickup') ?? false,
        ownerApprovedReturn: doc.getValue('owner_approved_return') ?? false,
    );
  }

  Map toJson() => {
    'id' : id.toString(),
    'requested_by' : requestedBy.toString(),
    'offer' : offer.toString(),
    'status' : status.toString(),
    'start_date' : startDateHour.toString(),
    'end_date' : endDateHour.toString(),
    'created_at' : createdAt.toString(),
  };

  @override
  int get hashCode => hashValues(id, requestedBy, offer, status, startDateHour, endDateHour);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Request otherRequest = other;
    return id == otherRequest.id;
  }

  @override
  String toString() => "requested by: ${requestedBy?.toString()}, offer: ${offer?.toString()}, dates: ${startDateHour}-${endDateHour}";
}
