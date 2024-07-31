import 'dart:developer' as developer;
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/general/widgets/title_divider.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:auto_share/general/widgets/offer_calender.dart';
import 'package:auto_share/general/widgets/custom_dates_range_picker.dart';
import 'package:auto_share/database/database_api.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/owner/utils.dart';
import 'package:auto_share/general/send_notification.dart';
import 'package:auto_share/renter/searchmodal.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';


class OfferDetailsPage extends StatefulWidget {
  final Offer offer;

  const OfferDetailsPage({Key? key, required this.offer}) : super(key: key);

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _datesRangeController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _addressController.text = widget.offer.location;
    _selectedStartDate = widget.offer.startDateHour;
    _selectedEndDate = widget.offer.endDateHour;
    _datesRangeController.text = formattedDatesRange(
        _selectedStartDate, _selectedEndDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AuthenticationNotifier>().userDataBase!.getCars(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          Offer offer = widget.offer;
          var urlImages = offer.car.pictures;
          int activeIndex = 0;
          final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Offer details'),
              actions: [
                GestureDetector(
                  child: const Icon(Icons.delete),
                  onTap: () async {
                    // show dialog to confirm delete
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete offer'),
                            content: const Text(
                                'Are you sure you want to delete this offer?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await ProgressDialog.future(
                                    context,
                                    title: const Text("Deleting offer.."),
                                    message: const Text("This may take few seconds"),
                                    future: Database.deleteOfferDoc(widget.offer.id),
                                    onProgressFinish: (doc) {
                                      developer.log('Offer ${widget.offer.id} was deleted successfully');
                                      snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'Offer was deleted successfully');
                                      GoRouter.of(context).pop();
                                    },
                                    onProgressError: (error) {
                                      developer.log('Error: $error');
                                      snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'Error: $error');
                                    },
                                    dismissable: false,
                                  );
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        });
                  },
                )
              ],
            ),
            body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater){
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${offer.car.make} ${offer.car.model} ${offer.car.year != null ? offer.car.year.toString() : ""}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  urlImages.isEmpty
                                      ? Container(
                                    height: 200,
                                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                    color: Colors.grey,
                                    child: Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          carImage('assets/car_icon.png'),
                                          const Text(
                                            "No pictures available",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // child: Text("No pictures available"),
                                    ),
                                  )
                                      : CarouselSlider.builder(
                                      options: CarouselOptions(
                                        height: 200,
                                        enlargeCenterPage: true,
                                        enlargeStrategy: CenterPageEnlargeStrategy.height,
                                        enableInfiniteScroll: false,
                                        onPageChanged: (index, reason) {
                                          setStater(() {
                                            activeIndex = index;
                                          });
                                        },
                                      ),
                                      itemCount: urlImages.length,
                                      itemBuilder: (context, index, realIndex){
                                        final urlImage = urlImages[index];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                          color: Colors.grey,
                                          child: CachedNetworkImage(
                                            imageUrl: urlImage,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                          ),
                                        );
                                      }
                                  ),
                                  const Divider(height: 10, color: Colors.transparent),
                                  urlImages.isEmpty
                                      ? const SizedBox.shrink()
                                      : AnimatedSmoothIndicator(
                                    activeIndex: activeIndex,
                                    count: urlImages.length,
                                    effect: const JumpingDotEffect(
                                      dotHeight: 8,
                                      dotWidth: 8,
                                      dotColor: Colors.grey,
                                      activeDotColor: Palette.autoShareBlue,
                                    ),
                                  ),
                                ],
                              )
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Pick-up & return dates"),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(
                              formattedDatesRange(_selectedStartDate, _selectedEndDate),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            leading: const Icon(Icons.calendar_today, color: Palette.autoShareBlue,),
                            minLeadingWidth: 0,
                            trailing:  GestureDetector(
                              child: const Icon(Icons.edit),
                              onTap: () async {
                                Future<String> onConfirm (DateTime startDate, DateTime endDate) async {
                                  String msg = "success";
                                  await ProgressDialog.future(
                                      context,
                                      title: const Text("Updating dates..."),
                                      message: const Text("This may take few seconds"),
                                      future: context.read<AuthenticationNotifier>()
                                          .userDataBase!
                                          .createNewOfferDoc(
                                          updateExistingOffer: true,
                                          id: widget.offer.id,
                                          carId: widget.offer.car.id,
                                          startDate: startDate,
                                          endDate: endDate,
                                          address: _addressController.text
                                      ),
                                      onProgressError: (dynamic error) {
                                        developer.log("error while updating dates");
                                        developer.log(error.toString());
                                        msg = error.toString();
                                      },
                                      onProgressFinish: (doc) {
                                        offer = Offer.createFromDocument(doc, offer.car, offer.owner);
                                        developer.log("dates of offer ${doc.id} have been updated");
                                        snackBarMassage(scaffoldKey: _scaffoldKey, msg:
                                        'Dates was updated successfully');
                                      });
                                  return msg;
                                }
                                var datesRange = await customDatesRangePicker(
                                  context,
                                  initialStartDate: _selectedStartDate,
                                  initialEndDate: _selectedEndDate,
                                  onConfirmRange: onConfirm,
                                );
                                setStater(() {
                                  _selectedStartDate = datesRange.startDate?? _selectedStartDate;
                                  _selectedEndDate = datesRange.endDate?? _selectedEndDate;
                                });
                              },
                            ),
                            horizontalTitleGap: 7,

                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Pick-up & return location"),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(
                              _addressController.text,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            leading: const Icon(Icons.location_on, color: Palette.autoShareBlue),
                            minLeadingWidth: 0,
                            trailing: GestureDetector(
                              child: const Icon(Icons.edit),
                              onTap: () async {
                                var location = await modalSearchBar(context);
                                if (location==null) return;
                                if(!mounted) return;
                                await ProgressDialog.future(
                                    context,
                                    title: const Text("Updating address..."),
                                    message: const Text("This may take few seconds"),
                                    future: context.read<AuthenticationNotifier>()
                                        .userDataBase!
                                        .createNewOfferDoc(
                                        updateExistingOffer: true,
                                        id: widget.offer.id,
                                        carId: widget.offer.car.id,
                                        startDate: widget.offer.startDateHour,
                                        endDate: widget.offer.endDateHour,
                                        address: location!.address
                                    ),
                                    onProgressError: (dynamic error) {
                                      developer.log("error while updating address: $error");
                                      snackBarMassage(scaffoldKey: _scaffoldKey, msg: error.toString());
                                    },
                                    onProgressFinish: (doc) {
                                      developer.log("address of offer ${doc.id} has been updated");
                                      _addressController.text = location!.address;
                                      setStater(() {
                                        offer = Offer.createFromDocument(doc, offer.car, offer.owner);
                                        snackBarMassage(scaffoldKey: _scaffoldKey, msg:
                                        'Address was updated successfully');
                                      });
                                    });
                              },
                            ),
                            horizontalTitleGap: 7,

                          ),
                          //TODO: find how to rebuild after modal of request closed
                          // const Padding(
                          //   padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                          //   child: TitleDivider(title: "Pending requests"),
                          // ),
                          // FutureBuilder(
                          //   future: context
                          //       .read<AuthenticationNotifier>()
                          //       .userDataBase!
                          //       .getOfferRequests(offer, RequestStatus.pending),
                          //   builder: (context, AsyncSnapshot<List<Request>> snapshot) {
                          //     if(snapshot.hasData){
                          //       var requests = snapshot.data;
                          //       if(requests!.isEmpty){
                          //         return const Text("No pending requests");
                          //       }
                          //       return ListView.separated(
                          //         scrollDirection: Axis.vertical,
                          //         shrinkWrap: true,
                          //         itemCount: requests.length,
                          //         separatorBuilder: (_, __) =>
                          //         const Divider(
                          //           height: 7,
                          //           color: Colors.transparent,
                          //         ),
                          //         itemBuilder: (context, index) {
                          //           Request request = requests[index];
                          //           return CalenderItemTemplate(
                          //             title: "${request.requestedBy.firstName.toTitleCase()} ${request.requestedBy.lastName.toTitleCase()}",
                          //             subtitle: formattedDatesRange(request.startDateHour, request.endDateHour),
                          //             imageUrl: request.requestedBy.profilePicture,
                          //             onTap: () async {
                          //               setStater(() async {
                          //                 await requestInfoModalBottomSheet(
                          //                   context,
                          //                   request,
                          //                   onConfirmClick: () async {
                          //                     if(await Database.confirmRequest(request)){
                          //                       snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Request confirmed');
                          //                     }
                          //                     else{
                          //                       snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Error has occurred while confirming request');
                          //                     }
                          //                   },
                          //                   onRejectClick: () async {
                          //                     if(await Database.rejectRequest(request)){
                          //                       snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Request rejected');
                          //                     }
                          //                     else{
                          //                       snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Error has occurred while rejecting request');
                          //                     }
                          //                   },
                          //                 );
                          //                 developer.log("modal closed");
                          //                   // update the list
                          //               });
                          //             },
                          //           );
                          //         },
                          //       );
                          //     }
                          //     else if (snapshot.hasError) {
                          //       return const Center(
                          //         child: Text("Error while loading requests"),
                          //       );
                          //     }
                          //     return const Center(
                          //       child: CircularProgressIndicator(),
                          //     );
                          //   }
                          // ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Confirmed rides"),
                          ),
                          OfferCalender(offer: offer),
                        ],
                      ),
                    ),
                  );
                }
            )
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
