import 'dart:developer' as developer;
import 'dart:math';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/widgets/custom_dates_range_picker.dart';
import 'package:auto_share/renter/renter_screens_manager.dart';
import 'package:auto_share/renter/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';


class OfferCardsListView extends StatelessWidget {
  const OfferCardsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AuthenticationNotifier>().userDataBase!.getAllOffers(),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          developer.log('snapshot error');
        }
        if(snapshot.hasData){
          List<Offer?> offers = snapshot.data as List<Offer?>;
          List<int> randomIndexes = List.generate(10, (index) => Random().nextInt(offers.length));
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              int randomIndex = randomIndexes[index];
              if(index >= randomIndexes.length / 2){
                randomIndexes.addAll(List.generate(10, (index) => Random().nextInt(offers.length)));
              }
              Offer? offer = offers?[randomIndex];
              if (offer == null) {
                return const SizedBox();
              }
              return SizedBox(
                    width: 250,
                    child: Card(
                      color: Colors.blueGrey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Divider(
                            color: Colors.transparent,
                            thickness: 2,
                          ),
                          Expanded(flex: 1, child: Text(offer.car.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                          const Divider(
                            color: Colors.transparent,
                            height: 10,
                          ),
                          Expanded(
                              flex: 8,
                              child: Container(
                                  width: 250,
                                  padding: EdgeInsets.zero,
                                  color: Colors.grey,
                                  child: CachedNetworkImage(
                                    imageUrl: offer.car.primaryPicture,
                                    fit: BoxFit.cover
                                  ),
                              ),
                          ),
                          const Divider(
                            color: Colors.transparent,
                            height: 8,
                          ),
                          Expanded(flex: 1, child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: Colors.black45,),
                                Flexible(child: Text(offer.location, overflow: TextOverflow.visible))
                              ],
                            )),
                          const Divider(
                            color: Colors.transparent,
                            height: 6,
                          ),
                        ],
                      ),
                    ));
              },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }
}

class ClickableOfferCardsListView extends StatelessWidget {
  const ClickableOfferCardsListView({Key? key}) : super(key: key);
  // DateTime _startDate = DateTime.now();
  // DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    return FutureBuilder(
        future: context.read<AuthenticationNotifier>().userDataBase!.getAllOffers(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            developer.log('snapshot error: ${snapshot.error}', name: 'ClickableOfferCardsListView');
            return Container();
          }
          if(snapshot.hasData){
            var offers = snapshot.data as List<Tuple2<Offer, DatesRange>>;
            if (offers.isEmpty) {
              return Container();
            }
            List<int> randomIndexes = List.generate(10, (index) => Random().nextInt(offers.length));
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                int randomIndex = randomIndexes[index];
                if(index >= randomIndexes.length / 2){
                  randomIndexes.addAll(List.generate(10, (index) => Random().nextInt(offers.length)));
                }
                Offer offer = offers[randomIndex].item1;
                DatesRange datesRange = offers[randomIndex].item2;
                return InkWell(
                  onTap: () {
                    offerInfoModalBottomSheet(
                        context,
                        offer,
                        datesRange.start,
                        datesRange.end,
                        onConfirmClick: () async {
                          // Navigator.of(context).pop();
                          try {
                            await context.read<AuthenticationNotifier>().userDataBase!.createNewRequestDoc(startDate: datesRange.start, endDate: datesRange.end, offerId: offer.id, ownerId: offer.owner.id, renterId: context.read<AuthenticationNotifier>().autoShareUser.id, );
                          } on Exception catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(e.toString())
                              ),
                            );
                            return;
                          }
                          screenManagerKey.currentState!.routeTo(BottomNavScreens.activityScreen.index);
                        },
                        onRejectClick: (){
                          // Navigator.of(context).pop();
                              return;
                        }
                    );
                    // showOfferDetails(context,
                    //     "${offer.car.toString()} - $price\$",
                    //     "Send a request to drive a\n${offer.car.toString()} \nfrom ${dateRangeFormat(offer.startDateHour, offer.endDateHour)} \nfor $price\$?\nPickup: ${offer.location}",
                    //   () async {
                    //     Navigator.of(context).pop();
                    //     try {
                    //       await context.read<AuthenticationNotifier>().userDataBase!.createNewRequestDoc(startDate: offer.startDateHour, endDate: offer.endDateHour, offerId: offer.id, ownerId: offer.owner.id, renterId: context.read<AuthenticationNotifier>().autoShareUser.id, );
                    //     } on Exception catch (e) {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(
                    //             content: Text(e.toString())
                    //         ),
                    //       );
                    //       return;
                    //     }
                    //     screenManagerKey.currentState!.routeTo(BottomNavScreens.activityScreen.index);
                    //   },
                    //   (){
                    //     Navigator.of(context).pop();
                    //   },
                    // );
                  },
                  child:
                    SizedBox(
                        width: 250,
                        child: Card(
                          color: Colors.blueGrey.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Divider(
                                color: Colors.transparent,
                                thickness: 2,
                              ),
                              Expanded(flex: 1, child: Text(offer.car.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                              const Divider(
                                color: Colors.transparent,
                                height: 10,
                              ),
                              Expanded(
                                flex: 8,
                                child: Container(
                                  width: 250,
                                  padding: EdgeInsets.zero,
                                  color: Colors.grey,
                                  child: CachedNetworkImage(
                                      imageUrl: offer.car.primaryPicture,
                                      fit: BoxFit.cover
                                  ),
                                ),
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 8,
                              ),
                              Expanded(flex: 1, child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, color: Colors.black45,),
                                  Flexible(child: Text(offer.location, overflow: TextOverflow.visible))
                                ],
                              )),
                              const Divider(
                                color: Colors.transparent,
                                height: 6,
                              ),
                              Expanded(flex: 1, child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.date_range_outlined, color: Colors.black45,),
                                  Flexible(child: Text(formattedDatesRange(datesRange.start, datesRange.end), overflow: TextOverflow.visible))
                                ],
                              )),
                              const Divider(
                                color: Colors.transparent,
                                height: 8,
                              ),
                            ],
                          ),
                        )
                    ),
                );
              },
            );
          }
          else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
}

void showOfferDetails(BuildContext context,String titleText, String bodyText,void Function()? onConfirmClick, void Function()? onRejectClick){

  Widget confirmButton = TextButton(
    onPressed:  onConfirmClick,
    child: const Text("Confirm"),
  );

  Widget cancelButton = TextButton(
    onPressed:  onRejectClick,
    child: const Text("Cancel"),
  );


  AlertDialog alert = AlertDialog(
    title: Text(titleText),
    content: Text(bodyText),
    actions: [
      cancelButton,
      confirmButton,
    ],

  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

String dateRangeFormat(DateTime startDate, DateTime endDate){
  const format = [M, ' ', d, ' • ', H, ':', nn];
  return "${formatDate(startDate, format)} till ${formatDate(endDate, format)}";
}