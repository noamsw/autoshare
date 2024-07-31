import 'dart:developer' as developer;
import 'package:auto_share/database/models/request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'models/car.dart';
import 'models/history_item.dart';
import 'models/offer.dart';
import 'models/user.dart';
import 'utils.dart';
import 'package:auto_share/general/send_notification.dart';

class Database {

  static final _firestore = FirebaseFirestore.instance.collection('versions')
      .doc('v1');

  AutoShareUser loggedInAutoShareUser;

  Database({required this.loggedInAutoShareUser});

  set setLoggedInAutoShareUser(AutoShareUser user) {
    loggedInAutoShareUser = user;
  }

  Future<void> switchUserMode(String mode) async {
    loggedInAutoShareUser.lastMode = mode;
    await _firestore.collection('users').doc(loggedInAutoShareUser.id).update(
        {'last_mode': mode});
  }

  static Future<AutoShareUser> getAutoShareUserById(String id) async {
    var doc = await _firestore.collection('users').doc(id).get();
    List<dynamic> searchHistory = doc.getValue('search_history', throwException: false)??[];
    List<GeographicInfo> searchHistoryList = [];
    try{
      for (var historyItem in searchHistory) {
        searchHistoryList.add(GeographicInfo.fromMap(historyItem));
      }
    } on PlatformException catch (e) {
      developer.log('Error in getting search history', error: e);
    }
    var user = AutoShareUser.fromDoc(doc);
    user.searchHistory = searchHistoryList;
    return user;
  }

  static Future<AutoShareUser> createNewAutoShareUserDoc({ required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    DateTime? birthDate,
    int? licenseNumber,
    String? profilePicture }) async {
    AutoShareUser user = AutoShareUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      birthDate: birthDate,
      licenseNumber: licenseNumber,
      profilePicture: profilePicture,
    );
    await _firestore.collection('users').doc(id).set(user.toJson());
    developer.log('User document created with id: $id');
    return user;
  }

  Future<void> setMessagingToken({String? token, bool remove=false}) async {

    if(remove){
      developer.log("Removing messaging token");
      await _firestore.collection('users').doc(loggedInAutoShareUser.id).update({
        'messaging_token': null
      });
    }
    else{
      developer.log("Setting messaging token: $token");
      await _firestore.collection('users').doc(loggedInAutoShareUser.id).update({
        'messaging_token': token
      });
      _firestore.collection('users').get().then((snapshot) {
        snapshot.docs.forEach((userDoc) {
          if (userDoc.id != loggedInAutoShareUser.id &&
              token == userDoc.getValue('messaging_token', throwException: false)) {
            userDoc.reference.update({'messaging_token': null});
          }
        });
      });
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> createNewCarDoc({
    bool updateExistingCar = false,
    String? id,
    required String make,
    required String model,
    String? licencePlate,
    int? year,
    int? mileage,
    String? gearbox,
    required String category,
    String? location,
    String? description,
    required int pricePerHour,
    required int pricePerDay,
    List<String>? imageUrls}) async {
    developer.log("addCar function started");
    Map<String, dynamic> data = {
      'make': make,
      'model': model,
      'owner_id': loggedInAutoShareUser.id,
      'licence_plate': licencePlate,
      'year': year,
      'mileage': mileage,
      'gear_box': gearbox,
      'category': category,
      'location': location,
      'description': description,
      'price_per_hour': pricePerHour,
      'price_per_day': pricePerDay,
      'pictures': imageUrls,
    };
    var doc = updateExistingCar ? _firestore.collection('cars').doc(id) : _firestore.collection('cars').doc();
    if (updateExistingCar) {
      await doc.update(data);
      developer.log('Car document: ${doc.id} updated');
    } else {
      await doc.set(data);
      developer.log('Car document created with id: ${doc.id}');
    }
    return doc;
  }

  static Future<void> deleteCarDoc(String id) async {
    var carOffers = await _firestore.collection('offers').where('car_id', isEqualTo: id).get();
    if (carOffers.docs
        .where((doc) => timestampToDatetime(doc.getValue('end_date'))!
            .isAfter(DateTime.now()))
        .isNotEmpty) {
      throw CarHasOffers(id);
    }
    await _firestore.collection('cars').doc(id).delete();
    developer.log('Car document: $id deleted');
  }

  static Future<void> deleteOfferDoc(String id) async {
    var relatedRequests = await _firestore.collection('requests').where('offer_id', isEqualTo: id).where("status", isNotEqualTo: 'rejected').get().then((value) => value.docs);
    if (relatedRequests
        .where((doc) => timestampToDatetime(doc.getValue('end_date'))!
            .isAfter(DateTime.now()) && doc.getValue('owner_approved_return') == false)
        .isNotEmpty) {
      developer.log("Offer $id has related confirmed/pending requests");
      throw OfferHasRelatedRequests(id);
    }
    await _firestore.collection('offers').doc(id).delete();
    developer.log('Offer document: $id deleted');
  }

  static Future<void> deleteRequestDoc(String id) async {
    var requestDoc = await _firestore.collection('requests').doc(id).get();
    if (requestDoc.getValue('status') == 'confirmed') {
      var offerDoc = await _firestore.collection('offers').doc(requestDoc.getValue('offer_id')).get();
      var confirmedRequests = offerDoc.getValue('confirmed_requests', throwException: false) as Map<String, dynamic>;
      confirmedRequests.remove(id);
      await offerDoc.reference.update({'confirmed_requests': confirmedRequests});
    }
    requestDoc.reference.delete();
    developer.log('Request document: $id deleted');
  }

  static Future<void> approvePickUpReturn(String requestId, String userMode, String pickUpOrReturn, {bool unapproved = false}) async{
    _firestore.collection('requests').doc(requestId).update({
      '${userMode}_approved_$pickUpOrReturn': unapproved ? false : true,
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> createNewRequestDoc({
    required DateTime startDate,
    required DateTime endDate,
    required String offerId,
    required String ownerId,
    required String renterId,}) async {
    var requests = await _firestore.collection('requests').where('offer_id', isEqualTo: offerId).where('requested_by_id', isEqualTo: renterId).get().then((value) => value.docs);
    for (var requestDoc in requests) {
      var docStartDate = timestampToDatetime(requestDoc.getValue('start_date'))!;
      var docEndDate = timestampToDatetime(requestDoc.getValue('end_date'))!;
      if (checkIfTimesOverlap(startDate, endDate, docStartDate, docEndDate)) {
        throw UserHasRequestOnOffer(loggedInAutoShareUser.id);
      }
    }
    Map<String, dynamic> data = {
      'created_at': Timestamp.fromDate(DateTime.now()),
      'end_date': Timestamp.fromDate(endDate),
      'start_date': Timestamp.fromDate(startDate),
      'offer_owner_id': ownerId,
      'offer_id': offerId,
      'requested_by_id': renterId,
      'status': "pending",
      'renter_approved_pickup': false,
      'owner_approved_return': false,
    };
    var newDoc = _firestore.collection('requests').doc();
    await newDoc.set(data);
    developer.log('request created with id: ${newDoc.id}');
    var offerDoc = await _firestore.collection('offers').doc(offerId).get();
    var ownerDoc = await _firestore.collection('users').doc(ownerId).get();
    var carDoc = await _firestore.collection('cars').doc(offerDoc.getValue('car_id')).get();
    Offer offer = Offer.createFromDocument(
        offerDoc,
        Car.fromDoc(carDoc),
        AutoShareUser.fromDoc(ownerDoc)
    );
    if(offer.owner.messagingToken != null){
      sendNotification(
          title: 'New Request',
          body: 'New request for your offer of ${offer.car.toString()} on ${formattedDatesRange(offer.startDateHour, offer.endDateHour)}',
          image: offer.owner.profilePicture,
          token: offer.owner.messagingToken!,
          requestType: 'new_request');
    }
    return newDoc;
  }

  static Future<bool> checkConflictWithExistingOffers(String? offerId, String carId, DateTime startDate, DateTime endDate) async {
    var offers = await _firestore.collection('offers')
        .where('car_id', isEqualTo: carId).get().then((snapshot) => snapshot.docs);
    if (offerId != null) {
       offers.removeWhere((doc) => doc.id == offerId);
    }
    for (var offer in offers) {
      var offerStartDate = timestampToDatetime(offer.getValue('start_date'))!;
      var offerEndDate = timestampToDatetime(offer.getValue('end_date'))!;
      if(checkIfTimesOverlap(startDate, endDate, offerStartDate, offerEndDate)){
        developer.log("Offer ${offer.id} has a conflict with the new offer");
        return true; //There is a conflict
      }
    }
    return false; //There are no conflicts
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> createNewOfferDoc({
    bool updateExistingOffer = false,
    String? id,
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    required String address
  }) async {
    if(await checkConflictWithExistingOffers(id, carId, startDate, endDate)){
      throw OfferConflict();
    }
    GeoFirestore geoFirestore = GeoFirestore(_firestore.collection('offers'));
    List<Location> locationsList = await locationFromAddress(address);
    var geoLocation = GeoPoint(
        locationsList[0].latitude, locationsList[0].longitude);
    var startTime = Timestamp.fromDate(startDate);
    var endTime = Timestamp.fromDate(endDate);
    Map <String, dynamic> offerData =
    {
      "owner_id": loggedInAutoShareUser.id,
      "car_id": carId,
      "start_date": startTime,
      "end_date": endTime,
      "address": address,
    };
    return FirebaseFirestore.instance.runTransaction<DocumentSnapshot<Map<String, dynamic>>>((transaction) async {
      var doc = updateExistingOffer ? _firestore.collection('offers').doc(id!) : _firestore.collection('offers').doc();
      if (updateExistingOffer) {
        developer.log("update existing offer: $id");
        var relatedRequests = await _firestore.collection('requests').where('offer_id', isEqualTo: id).where("status", isNotEqualTo: 'rejected').get().then((value) => value.docs);
        relatedRequests.where((doc) => timestampToDatetime(doc.getValue('end_date'))!
            .isAfter(DateTime.now()) && doc.getValue('owner_approved_return') == false);
        for (var request in relatedRequests) {
          var requestStartDate = timestampToDatetime(request.getValue('start_date'))!;
          var requestEndDate = timestampToDatetime(request.getValue('end_date'))!;
          if(requestStartDate.isBefore(startDate) || requestEndDate.isAfter(endDate)){
            developer.log("request ${request.id} has a conflict with the new offer dates");
            throw OfferHasRelatedRequests(id!);
          }
        }
        var offerDoc = await doc.get();
        if (offerDoc.getValue("address") !=  address && relatedRequests.isNotEmpty){
          throw OfferHasRelatedRequests(id!);
        }
        await doc.update(offerData);
        developer.log('Offer document: ${doc.id} updated');
      }
      else {
        await doc.set(offerData);
        developer.log('Offer document created with id: ${doc.id}');
      }
      await geoFirestore.setLocation(doc.id, geoLocation);
      return await doc.get();
    });

  }

  Stream<List<Car>> getCarsStream() {
    return _firestore
        .collection('cars')
        .where('owner_id', isEqualTo: loggedInAutoShareUser.id)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Car.fromDoc(doc)).toList());
  }

  Future<List<Car>> getCars() async {
    return await _firestore
        .collection('cars')
        .where('owner_id', isEqualTo: loggedInAutoShareUser.id)
        .get().then((cars) => cars.docs.map((doc) => Car.fromDoc(doc)).toList());
  }

  Stream<Map<Car,List<Offer?>>> getOffersStream() {
    Stream<QuerySnapshot<Map<String, dynamic>>> offersQuerySnapshot = _firestore
        .collection('offers')
        .where('owner_id', isEqualTo: loggedInAutoShareUser.id)
        .orderBy('end_date', descending: true)
        .where('end_date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots();
    Stream<QuerySnapshot<Map<String, dynamic>>> carsQuerySnapshot = _firestore
        .collection('cars')
        .where('owner_id', isEqualTo: loggedInAutoShareUser.id)
        .snapshots();
    return Rx.combineLatest2(offersQuerySnapshot, carsQuerySnapshot,
      (QuerySnapshot<Map<String, dynamic>> userOffers,
      QuerySnapshot<Map<String, dynamic>> userCars,) {
          Map<Car, List<Offer?>> result = {};
          for (var offerDoc in userOffers.docs){
            Offer offer = Offer.createFromDocument(
                offerDoc,
                Car.fromDoc(userCars.getDocById(offerDoc['car_id'])),
                loggedInAutoShareUser
            );
            if (result[offer.car] != null){
              result[offer.car]!.add(offer);
            }
            else{
              result[offer.car] = [offer];
            }
          }
          return result;
        });
  }

  Stream<Map<Car,List<Request>>> getIncomingRequestsStream() {
    var requestsQuery = _firestore
        .collection('requests')
        .where('offer_owner_id', isEqualTo: loggedInAutoShareUser.id)
        .where('status', isEqualTo: 'pending')
        .where('end_date', isGreaterThan: Timestamp.now())
        .snapshots();
    var offersQuery = _firestore
        .collection('offers')
        .where('owner_id', isEqualTo: loggedInAutoShareUser.id)
        .snapshots();
    var userCarsQuery = _firestore.collection('cars').snapshots();
    var usersQuery = _firestore.collection('users').snapshots();

    return Rx.combineLatest4(
        offersQuery, userCarsQuery, usersQuery, requestsQuery,
            (QuerySnapshot<Map<String, dynamic>> offers,
            QuerySnapshot<Map<String, dynamic>> userCars,
            QuerySnapshot<Map<String, dynamic>> users,
            QuerySnapshot<Map<String, dynamic>> requests) {
          Map<Car,List<Request>> result = {};
          for (var requestDoc in requests.docs){
            var offerDoc = offers.getDocById(requestDoc.getValue('offer_id'));
            var request = Request.create(
                requestDoc,
                Offer.createFromDocument(
                    offerDoc,
                    Car.fromDoc(userCars.getDocById(offerDoc['car_id'])),
                    loggedInAutoShareUser),
                AutoShareUser.fromDoc(
                    users.getDocById(requestDoc.getValue('requested_by_id'))));
            if (result[request.offer.car] != null){
              result[request.offer.car]!.add(request);
            }
            else{
              result[request.offer.car] = [request];
            }
          }
          return result;
        });
  }

  Stream<int> getIncomingRequestsNumberStream() {
    return _firestore
        .collection('requests')
        .where('offer_owner_id', isEqualTo: loggedInAutoShareUser.id)
        .where('status', isEqualTo: 'pending')
        .where('end_date', isGreaterThan: Timestamp.now())
        .snapshots().map((snapshot) => snapshot.docs.length);
  }

  static Stream<Request> getRequestStream(Request request){
    var requestDoc = _firestore.collection('requests').doc(request.id);
    return requestDoc.snapshots().map((doc) => Request.create(
        doc,
        request.offer,
        request.requestedBy
    ));
  }

  Stream<List<Request?>> getOutgoingRenterRequestsStream(
      RequestStatus status) {
    developer.log('getOutgoingRenterRequestsStream is running');
    var requestsQuery = _firestore
        .collection('requests')
        .where('requested_by_id', isEqualTo: loggedInAutoShareUser.id)
        .where('status', isEqualTo: status.name)
        .snapshots();
    var offersQuery = _firestore
        .collection('offers')
        .snapshots();
    var userCarsQuery = _firestore.collection('cars').snapshots();
    var usersQuery = _firestore.collection('users').snapshots();

    return Rx.combineLatest4(
        offersQuery, userCarsQuery, usersQuery, requestsQuery,
            (QuerySnapshot<Map<String, dynamic>> offers,
            QuerySnapshot<Map<String, dynamic>> userCars,
            QuerySnapshot<Map<String, dynamic>> users,
            QuerySnapshot<Map<String, dynamic>> requests) {
          return requests.docs.where((requestDoc) {
            bool isNotEnded = timestampToDatetime(requestDoc.getValue('end_date'))!.isAfter(DateTime.now());
            if (status == RequestStatus.confirmed) {
              if (isNotEnded || requestDoc.getValue('owner_approved_return') == false) {
                return true;
              }
            }
            return isNotEnded;
          }).map((requestDoc) {
            try {
              return Request.create(
                requestDoc,
                  (status == RequestStatus.rejected) ?
                    Offer.createFromMap(
                        requestDoc.getValue('offer_id'),
                      requestDoc.getValue('offer_data') as Map<String, dynamic>,
                      Car.fromDoc(userCars.getDocById(requestDoc.getValue('offer_data')['car_id'])),
                      AutoShareUser.fromDoc(users
                          .getDocById(requestDoc.getValue('offer_owner_id'))))
                  : Offer.createFromDocument(
                      offers.getDocById(requestDoc.getValue('offer_id')),
                      Car.fromDoc(userCars.getDocById(offers.getDocById(requestDoc.getValue('offer_id'))['car_id'])),
                      AutoShareUser.fromDoc(
                          users.getDocById(requestDoc.getValue('offer_owner_id')))),
                loggedInAutoShareUser);
            }
            on MissingField catch (error) {
              developer.log("missing field key: ${error.field} of request ${requestDoc.id}", name: "getOutgoingRenterRequestsStream");
              return null;
            }
            on MissingDocument catch (error) {
              developer.log("missing document ${error.docId}");
              return null;
            }
          }).toList();
        });
  }

  Stream<Map<String,List<Request?>>> getConfirmedOutgoingRequestsStream() {
    return getOutgoingRenterRequestsStream(RequestStatus.confirmed).map((requests){
      Map<String, List<Request?>> result = {};
      var inProgressRequests = requests
          .where((request) =>
      request != null &&
          (request.startDateHour.isBefore(DateTime.now()) &&
              request.ownerApprovedReturn == false))
          .toList();
      if (inProgressRequests.isNotEmpty) {result['In progress'] = inProgressRequests;}
      var upcomingRequests = requests
          .where((request) =>
      request != null &&
          request.startDateHour.isAfter(DateTime.now()))
          .toList();
      if (upcomingRequests.isNotEmpty) {result['Upcoming'] = upcomingRequests;}
      return result;
    });
  }

  Stream<Request?> getActiveRental() {
    var requestsQuery = _firestore.collection('requests')
        .where('requested_by_id', isEqualTo: loggedInAutoShareUser.id)
        .where('status', isEqualTo: "confirmed")
        .where('owner_approved_return', isEqualTo: false)
        .snapshots();
    var offersQuery = _firestore.collection('offers').snapshots();
    var userCarsQuery = _firestore.collection('cars').snapshots();
    var usersQuery = _firestore.collection('users').snapshots();
    return Rx.combineLatest4(
        offersQuery, userCarsQuery, usersQuery, requestsQuery,
            (QuerySnapshot<Map<String, dynamic>> offers,
            QuerySnapshot<Map<String, dynamic>> userCars,
            QuerySnapshot<Map<String, dynamic>> users,
            QuerySnapshot<Map<String, dynamic>> requests) {
              var res = requests.docs
                  .where((requestDoc) {
                var requestStart = timestampToDatetime(requestDoc.getValue('start_date'));
                var requestEnd = timestampToDatetime(requestDoc.getValue('end_date'));

                return requestStart!.isBefore(DateTime.now());
              }).map((requestDoc) {
                AutoShareUser offerOwner = AutoShareUser.fromDoc(
                    users.getDocById(requestDoc.getValue('offer_owner_id')));
                Car offerCar = Car.fromDoc(userCars.getDocById(
                    offers.getDocById(requestDoc.getValue('offer_id'))['car_id']));

                return Request.create(requestDoc, Offer.createFromDocument(
                    offers.getDocById(requestDoc.getValue('offer_id')),
                    offerCar,
                    offerOwner
                ), loggedInAutoShareUser);
              }).toList();
              return res.isEmpty ? null : res.first;;
        });
  }


  Stream<List<Request>> getUpcomingCarOwnerActivityStream(
      {bool inProgress = false}) {
    Stream<QuerySnapshot<Map<String, dynamic>>> requestsQuery;
    requestsQuery = inProgress ?
    _firestore
        .collection('requests')
        .where('offer_owner_id', isEqualTo: loggedInAutoShareUser.id)
        .where('status', isEqualTo: 'confirmed')
        .where('start_date', isLessThanOrEqualTo: DateTime.now())
        .where('owner_approved_return', isEqualTo: false)
        .snapshots()
        :
    _firestore
        .collection('requests')
        .where('offer_owner_id', isEqualTo: loggedInAutoShareUser.id)
        .where('status', isEqualTo: 'confirmed')
        .where('start_date', isGreaterThanOrEqualTo: DateTime.now())
        .snapshots();
    var offersQuery = _firestore
        .collection('offers')
        .where('owner_id', isEqualTo: loggedInAutoShareUser.id)
        .snapshots();
    var userCarsQuery = _firestore.collection('cars').snapshots();
    var usersQuery = _firestore.collection('users').snapshots();
    return Rx.combineLatest4(
        offersQuery, userCarsQuery, usersQuery, requestsQuery,
            (QuerySnapshot<Map<String, dynamic>> offers,
            QuerySnapshot<Map<String, dynamic>> userCars,
            QuerySnapshot<Map<String, dynamic>> users,
            QuerySnapshot<Map<String, dynamic>> requests) {
      return requests.docs
          .where((requestDoc) =>
              inProgress == false ||
              (inProgress &&
                  (requestDoc['end_date'].toDate().isAfter(DateTime.now()) ||
                      requestDoc['owner_approved_return'] == false)))
          .map((requestDoc) {
            var offerDoc = offers.getDocById(requestDoc.getValue('offer_id'));
            return Request.create(requestDoc, Offer.createFromDocument(
                offerDoc,
                Car.fromDoc(userCars.getDocById(offerDoc['car_id'])),
                loggedInAutoShareUser
            ), AutoShareUser.fromDoc(
                users.getDocById(requestDoc.getValue('requested_by_id'))));
          }).toList();
        });
  }

  Future<List<Request>> getOfferRequests(Offer offer, RequestStatus status) async {
    var requestsQuery = await _firestore
        .collection('requests')
        .where('offer_id', isEqualTo: offer.id)
        .where('status', isEqualTo: status.name)
        .get();
    var usersQuery = await _firestore.collection('users').get();
    return requestsQuery.docs.map((requestDoc) {
      return Request.create(
          requestDoc,
          offer,
          AutoShareUser.fromDoc(
              usersQuery.getDocById(requestDoc.getValue('requested_by_id')))
      );
    }).toList();
  }

  Future<List<Tuple2<Offer,DatesRange>>> getAllOffers() async {
    var offersQuery = await _firestore
        .collection('offers')
        .where('end_date', isGreaterThan: Timestamp.now())
        .get();
    var userCarsQuery = await _firestore.collection('cars').get();
    var usersQuery = await _firestore.collection('users').get();
    var result =  offersQuery.docs
        .where((offerDoc) {
          if (offerDoc.getValue('owner_id') == loggedInAutoShareUser.id) return false;
          if (userCarsQuery.getDocById(offerDoc.getValue('car_id')).getValue('pictures', throwException: false) == null) return false;
          return true;
        }).map((offerDoc){
          Offer offer = Offer.createFromDocument(
              offerDoc,
              Car.fromDoc(
                  userCarsQuery.getDocById(offerDoc.getValue('car_id'))),
              AutoShareUser.fromDoc(
                  usersQuery.getDocById(offerDoc['owner_id'])));
          Map<String, dynamic>? takenDates = offerDoc.getValue('confirmed_requests', throwException: false);
          var datesRangesList = takenDates?.values.map((range) => DatesRange(timestampToDatetime((range as List)[0])!, timestampToDatetime((range)[1])!)).toList();
          datesRangesList?.sort((a, b) => a.start.isAfter(b.start)? 1 : -1);
          DatesRange? maxRange;
          if (datesRangesList!=null && datesRangesList!.isNotEmpty && offer.startDateHour.isAfter(DateTime.now())) {
            maxRange = DatesRange(offer.startDateHour, datesRangesList!.first.start);
          }
          for (int i=0; i<(datesRangesList?.length??0); i++) {
            var datesRange = datesRangesList![i];
            DateTime date = (i == datesRangesList.length-1)? offer.endDateHour : datesRangesList[i+1].start;
            if (date.isAfter(DateTime.now())){
              continue;
            }
            else if (datesRange.end.isBefore(DateTime.now())){
              datesRange.end = DateTime.now();
            }
            if (maxRange != null && maxRange!.diff < date.difference(datesRange.end).inDays){
              maxRange = DatesRange(datesRange.end, date);
            }
          }
          maxRange??= DatesRange(offer.startDateHour.isAfter(DateTime.now())?offer.startDateHour:DateTime.now(), offer.endDateHour);
          return Tuple2(offer, maxRange);
        }).toList();
    return result;
  }

  Future<void> documentUserSearchHistory(GeographicInfo geoLocation) async{
    developer.log("Documenting last search address: ${geoLocation.address} in search history");
    var userDocRef = _firestore.collection('users').doc(loggedInAutoShareUser.id);
    var userDoc = await userDocRef.get();
    List<dynamic> searchHistory = userDoc.getValue('search_history', throwException: false) ?? [];
    for (var i=0; i<searchHistory.length; i++){
      var historyItem = searchHistory[i] as Map<String, dynamic>;
      if (historyItem['address'] == geoLocation.address){
        return;
      }
    }
    searchHistory.removeRange(0, searchHistory.length >= 4 ? searchHistory.length - 3 : 0);
    searchHistory.add(geoLocation.toMap());
    userDocRef.update({
      'search_history': searchHistory
    });
    List<GeographicInfo> searchHistoryList = [];
    for (var location in searchHistory) {
      searchHistoryList.add(GeographicInfo.fromMap(location));
    }
    loggedInAutoShareUser.setSearchHistory(searchHistoryList);
  }

  Future<List<Offer?>> getOffersByLocationAndDates(
      {
        required dynamic location,
        required DateTime startDate,
        required DateTime endDate,
        required double range,
        int? minYear,
        int? maxYear,
        int? minPrice,
        int? maxPrice,
        String? category,
      }) async {
    GeoFirestore geoFirestore = GeoFirestore(_firestore.collection('offers'));
    GeoPoint? queryLocation;
    if (location is String) {
      List<Location> locationsList = await locationFromAddress(location);
      queryLocation = GeoPoint(
          locationsList[0].latitude, locationsList[0].longitude);
    }
    if (location is LatLng) {
      queryLocation = GeoPoint(location.latitude, location.longitude);
    }
    else{
      throw Exception('Invalid location type: ${location.runtimeType}');
    }
    var offersQuery = await geoFirestore.getAtLocation(queryLocation!, range);
    var userCarsQuery = await _firestore.collection('cars').get();
    var usersQuery = await _firestore.collection('users').get();
    return offersQuery.where((offerDoc) {
      bool result =
      isOfferAvailableOnDates(offerDoc, startDate, endDate) &&
          offerDoc.getValue('owner_id', throwException: false) != loggedInAutoShareUser.id;
      if (result) {
        var car = Car.fromDoc(
            userCarsQuery.getDocById(offerDoc.getValue('car_id')));
        if (result && minYear != null && maxYear != null) {
          if (car.year != null) {
            result = (car.year! >= minYear && car.year! <= maxYear);
          }
          else {
            result = false;
          }
        }
        if (result && minPrice != null && maxPrice != null) {
          int price = priceCalculator(
              startDate,
              endDate,
              car.pricePerHour,
              car.pricePerDay);
          result = price >= minPrice && price <= maxPrice;
        }
        if (result && category != null) {
          result = (car.category == category);
        }
      }
      return result;
    }).map((offerDoc) => Offer.createFromDocument(
        offerDoc,
        Car.fromDoc(userCarsQuery.getDocById(offerDoc['car_id'])),
        AutoShareUser.fromDoc(usersQuery.getDocById(offerDoc['owner_id'])))).toList();
  }


  Future<GeoPoint> getGeoPointFromAddress(
      {
        required String address,
      }) async {
    List<Location> locationsList = await locationFromAddress(address);
    return GeoPoint(
        locationsList[0].latitude, locationsList[0].longitude);
  }

  static Future<Map<String, dynamic>> getMakeModelList() async {
    var makeModelList = await _firestore.get().then((doc) =>
        doc.get('make_model_list'));
    return makeModelList as Map<String, dynamic>;
  }

  //TODO: consider run it with cloud function
  static Future<void> onRequestConfirmation(String requestId) async {
    var requestDoc = await _firestore.collection('requests')
        .doc(requestId)
        .get();
    var offerDoc = await _firestore.collection('offers').doc(
        requestDoc.get('offer_id')).get();
    var offerRequests = await _firestore.collection('requests')
        .where('offer_id', isEqualTo: offerDoc.id).get();
    // rejecting the rest of the requests for that offer with overlapping dates
    for (var doc in offerRequests.docs) {
      if (doc.id != requestId &&
          checkIfTimesOverlap(
              requestDoc.getValue('start_date').toDate(),
              requestDoc.getValue('end_date').toDate(),
              doc.getValue('start_date').toDate(),
              doc.getValue('end_date').toDate())) {
        await doc.reference.update({'status': 'rejected'});
      }
      //rejecting pending extension requests that overlap with the new request
      var extensionRequest = doc.getValue('extension_request', throwException: false) as Map<String, dynamic>?;
      if (extensionRequest != null &&
          extensionRequest['status'] as String == 'pending' &&
          checkIfTimesOverlap(
              timestampToDatetime(requestDoc.getValue('start_date'))!,
              timestampToDatetime(requestDoc.getValue('end_date'))!,
              timestampToDatetime(doc.getValue('start_date'))!,
              timestampToDatetime(extensionRequest['time'])!)) {

        await doc.reference.update({'extension_request': null});
      }
    }

    // deleting pending requests of the renter with overlapping times
    var renterRequests = await _firestore.collection('requests')
        .where('requested_by_id', isEqualTo: requestDoc['requested_by_id'])
        .where('status', isEqualTo: 'pending').get();
    renterRequests.docs.where((doc) {
      if (doc.id == requestId) {
        return false; //skip the confirmed request
      }
      return checkIfTimesOverlap(timestampToDatetime(doc['start_date'])!, timestampToDatetime(doc['end_date'])!,
          timestampToDatetime(requestDoc['start_date'])!, timestampToDatetime(requestDoc['end_date'])!);
    }).forEach((requestDoc) {
      requestDoc.reference.delete();
    });
  }

  static Future<bool> confirmRequest(Request request) async {
    var requestDoc = await _firestore.collection('requests')
        .doc(request.id)
        .get();
    if (requestDoc['status'] == 'confirmed'){
      return false;
    }
    var offerDoc = await _firestore.collection('offers').doc(
        requestDoc.get('offer_id')).get();
    if (!(isOfferAvailableOnDates(
        offerDoc,
        timestampToDatetime(requestDoc['start_date'])!,
        timestampToDatetime(requestDoc['end_date'])!))) {
      developer.log('dates are not available', name: 'confirmRequest');
      return false;
    }
    onRequestConfirmation(request.id);
    await requestDoc.reference.update({'status': 'confirmed'});
    Map<String, dynamic> confirmedRequests = offerDoc.getValue('confirmed_requests', throwException: false)??{};
    confirmedRequests[request.id] = [
      requestDoc.get('start_date'),
      requestDoc.get('end_date')
    ];
    await offerDoc.reference.update({'confirmed_requests': confirmedRequests});
    if (request.requestedBy.messagingToken != null){
      sendNotification(
          title: 'Request confirmed',
          body: 'Your request for ${request.offer.car.toString()} on ${formattedDatesRange(request.startDateHour, request.endDateHour)} has been confirmed',
          image: request.offer.car.primaryPicture,
          token: request.requestedBy.messagingToken!,
          requestType: 'outgoing_request_confirmed'
      );
    }
    return true;
  }

  static Future<bool> rejectRequest(Request request) async {
    var requestDoc = await _firestore.collection('requests')
        .doc(request.id).get();
    var offerDoc = await _firestore.collection('offers').doc(
        requestDoc.getValue('offer_id')).get();
    requestDoc.reference.update({'offer_data' : offerDoc.data()!});
    await requestDoc.reference.update({'status': 'rejected'});
    if (request.requestedBy.messagingToken != null){
      sendNotification(
          title: 'Request rejected',
          body: 'Your request for ${request.offer.car.toString()} on ${formattedDatesRange(request.startDateHour, request.endDateHour)} has been rejected',
          image: request.offer.car.primaryPicture,
          token: request.requestedBy.messagingToken!,
          requestType: 'outgoing_request_rejected'
      );
    }
    developer.log("request ${request.id} rejected", name: 'rejectRequest');
    return true;
  }

  static Request requestByDoc(
      QuerySnapshot<Map<String, dynamic>> offers,
      QuerySnapshot<Map<String, dynamic>> cars,
      QuerySnapshot<Map<String, dynamic>> users,
      QueryDocumentSnapshot<Map<String, dynamic>> requestDoc) {
    var offerDoc = offers.getDocById(requestDoc.getValue('offer_id'));
    var carDoc = cars.getDocById(offerDoc['car_id']);
    var requestedByDoc =
        users.getDocById(requestDoc.getValue('requested_by_id'));
    var ownerDoc = users.getDocById(offerDoc['owner_id']);
    return Request.create(
        requestDoc,
        Offer.createFromDocument(
            offerDoc, Car.fromDoc(carDoc), AutoShareUser.fromDoc(ownerDoc)),
        AutoShareUser.fromDoc(requestedByDoc));
  }

  Future<void> cleanOutOfDateRequestsAndOfferAndUpdateHistory() async {
    try{
      var offers = _firestore.collection('offers');
      var requests = _firestore.collection('requests');
      var cars = await _firestore.collection('cars').get();
      var users = _firestore.collection('users');
      var loggedInUserIncomingRequests = await requests
          .where('offer_owner_id', isEqualTo: loggedInAutoShareUser.id)
          .get();
      loggedInUserIncomingRequests.docs.forEach((requestDoc) async {
        if (requestDoc.getValue('status') == 'confirmed') {
          if (timestampToDatetime(requestDoc.getValue('start_date'))!.isBefore(DateTime.now()) && requestDoc['owner_approved_return']) {
            try {
              Request request = requestByDoc(
                  await offers.get(), cars, await users.get(), requestDoc);
              users.doc(loggedInAutoShareUser.id)
                  .collection("owner_history")
                  .doc()
                  .set(CarOwnerHistoryItem.fromRequest(request).toJson());
              developer.log(
                  "New owner history item added for user ${loggedInAutoShareUser
                      .id}",
                  name: "cleanOutOfDateRequestsAndOfferAndUpdateHistory");
              users
                  .doc(requestDoc['requested_by_id'])
                  .collection("renter_history")
                  .doc()
                  .set(RenterHistoryItem.fromRequest(request).toJson());
              developer.log(
                  "New renter history item added for user ${requestDoc['requested_by_id']}",
                  name: "cleanOutOfDateRequestsAndOfferAndUpdateHistory");
              var offerDoc = await offers.doc(requestDoc['offer_id']).get();
              Map<String, dynamic> confirmedRequests = offerDoc.getValue(
                  'confirmed_requests', throwException: false) ?? {};
              confirmedRequests.remove(requestDoc.id);
              requestDoc.reference.delete();
            }
            catch(e){
              developer.log("Error while cleaning out of date request ${requestDoc.id}: $e", name: "cleanOutOfDateRequestsAndOfferAndUpdateHistory");
            }
          }
        }
        else if(timestampToDatetime(requestDoc.getValue('end_date'))!.isBefore(DateTime.now())){
          requestDoc.reference.delete();
        }
      });
      await offers
          .where('end_date', isLessThan: DateTime.now())
          .where('owner_id', isEqualTo: loggedInAutoShareUser.id)
          .get()
          .then((snapshot) =>
          snapshot.docs.where((doc) {
            for (var request in loggedInUserIncomingRequests.docs) {
              if (request['offer_id'] == doc.id && !request['owner_approved_return']) {
                return false;
              }
            }
            return true;
          })
              .forEach((doc) => doc.reference.delete()));
      await requests
          .where('requested_by_id', isEqualTo: loggedInAutoShareUser.id)
          .get()
          .then((requestsDocs) {
        requestsDocs.docs.forEach((requestDoc) async {
          if (requestDoc.getValue('status') == 'confirmed') {
            if (timestampToDatetime(requestDoc.getValue('start_date'))!.isBefore(DateTime.now()) && requestDoc['owner_approved_return']) {
              Request request = requestByDoc(
                  await offers.get(), cars, await users.get(), requestDoc);
              users.doc(loggedInAutoShareUser.id)
                  .collection("owner_history")
                  .doc()
                  .set(CarOwnerHistoryItem.fromRequest(request).toJson());
              developer.log(
                  "New owner history item added for user ${loggedInAutoShareUser.id}",
                  name: "cleanOutOfDateRequestsAndOfferAndUpdateHistory");
              users
                  .doc(requestDoc['requested_by_id'])
                  .collection("renter_history")
                  .doc()
                  .set(RenterHistoryItem.fromRequest(request).toJson());
              developer.log(
                  "New renter history item added for user ${requestDoc['requested_by_id']}",
                  name: "cleanOutOfDateRequestsAndOfferAndUpdateHistory");
              var offerDoc = await offers.doc(requestDoc['offer_id']).get();
              Map<String, dynamic> confirmedRequests = offerDoc.getValue('confirmed_requests', throwException: false)??{};
              confirmedRequests.remove(requestDoc.id);
              requestDoc.reference.delete();
            }
          }
          else if(timestampToDatetime(requestDoc.getValue('end_date'))!.isBefore(DateTime.now())){
            requestDoc.reference.delete();
          }
        });
      });
    }
    on MissingField catch (e){
      developer.log(e.toString(), name: 'cleanOutOfDateRequestsAndOfferAndUpdateHistory');
    }
    on MissingDocument catch (e){
      developer.log(e.toString(), name: 'cleanOutOfDateRequestsAndOfferAndUpdateHistory');
    }
  }

  Future<List<CarOwnerHistoryItem>> getCarsOwnerHistory() async {
    var historyItemsQuery = await _firestore
        .collection('users')
        .doc(loggedInAutoShareUser.id)
        .collection("owner_history")
        .orderBy('end_date', descending: true)
        .get();
    return historyItemsQuery.docs.map((historyItemDoc) => CarOwnerHistoryItem.fromDoc(historyItemDoc)).toList();
  }

  Future<List<RenterHistoryItem>> getRenterHistory() async {
    var historyItemsQuery = await _firestore
        .collection('users')
        .doc(loggedInAutoShareUser.id)
        .collection("renter_history")
        .orderBy('end_date', descending: true)
        .get();
    return historyItemsQuery.docs.map((historyItemDoc) => RenterHistoryItem.fromDoc(historyItemDoc)).toList();
  }

  static Future<DateTime> maxExtensionTimeForActiveRide(String requestId) async {
    var requestDoc = await _firestore.collection('requests').doc(requestId).get();
    DateTime endTime = timestampToDatetime(requestDoc.getValue('end_date'))!;
    var offerDoc = await _firestore.collection('offers').doc(requestDoc['offer_id']).get();
    var confirmedRequests = offerDoc.getValue('confirmed_requests', throwException: false) as Map<String, dynamic>?;
    DateTime maxExtensionTime = timestampToDatetime(offerDoc.getValue('end_date'))!;
    if (confirmedRequests != null) {
      confirmedRequests.removeWhere((key, value) => key == requestId);
      confirmedRequests.forEach((key, value) {
        DateTime requestStartDate = timestampToDatetime(
            (value as List<dynamic>)[0])!;
        if (requestStartDate.isAfter(endTime) &&
            requestStartDate.isBefore(maxExtensionTime)) {
          maxExtensionTime =
              requestStartDate.subtract(const Duration(minutes: 30));
        }
      });
    }
    if(endTime.isAfter(maxExtensionTime)){
      maxExtensionTime = endTime;
    }
    return maxExtensionTime;
  }

  static Future<void> activeRideExtensionRequest(String requestId, DateTime newEndDate) async {
    var requestDoc = await _firestore.collection('requests').doc(requestId).get();
    await requestDoc.reference.update({'extension_request': {'time':newEndDate, 'status':'pending'}});
  }

  //returns request object formatted: {time: [new_time], status: [pending/accepted/rejected]}, and null if there is no extension request
  static Stream<Map<String,dynamic>?> getActiveRideExtensionRequest(String requestId) {
    return _firestore
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .map((snapshot) => snapshot.getValue('extension_request', throwException: false));
  }

  static Future<void> approveRejectActiveRideExtensionRequest(String requestId, {bool reject=false}) async {
    var requestDoc = await _firestore.collection('requests').doc(requestId).get();
    Map<String, dynamic>? extensionRequest = requestDoc.getValue('extension_request', throwException: false) as Map<String, dynamic>?;
    if (requestDoc.getValue('extension_request', throwException: false) == null || extensionRequest!['status'] != 'pending') {
      developer.log("Extension request is neither existed nor pending", name: "approveRejectActiveRideExtensionRequest");
      return;
    }

    // await requestDoc.reference.update({'end_date': extensionRequest['time']});
    extensionRequest['status'] = reject? 'rejected' : 'confirmed';
    await requestDoc.reference.update({'extension_request': extensionRequest});
    if(!reject){
      await requestDoc.reference.update({'end_date': extensionRequest['time']});

      _firestore.collection('offers')
        .doc(requestDoc.getValue('offer_id'))
        .get()
        .then((offerDoc) {
          var confirmedRequests = offerDoc.getValue('confirmed_requests', throwException: false) as Map<String, dynamic>?;
          confirmedRequests?[requestId][1] = extensionRequest['time'];
          offerDoc.reference.update({'confirmed_requests':confirmedRequests});
        }
      );
    }
  }

}