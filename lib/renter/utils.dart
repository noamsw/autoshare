import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/general/widgets/title_divider.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_share/res/custom_colors.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/general/widgets/text_via_whatsapp_button.dart';
import 'package:auto_share/general/widgets/call_button.dart';

void offerInfoModalBottomSheet(context, Offer offer, DateTime requestStartDate, DateTime requestEndDate,
    {void Function()? onConfirmClick, void Function()? onRejectClick, void Function()? onCancelClick, double scrollableHeight = 0.55}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        int activeIndex = 0;
        final urlImages = offer.car.pictures;
        final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModal){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: <Widget>[
                      const Text("Offer details"),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * scrollableHeight,
                    child: Scaffold(
                        key: scaffoldKey,
                        body: Padding(
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
                                                setStateModal(() {
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
                                const TitleDivider(title: "Owner"),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        flex: 26,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          radius: 55.0,
                                          backgroundImage: profileImage(offer.owner.profilePicture),
                                        )
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(flex: 74, child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // const Divider(height: 15, color: Colors.transparent),
                                        Text(
                                          offer.owner.toString().toTitleCase(),
                                          style: const TextStyle(
                                            fontSize: 25,
                                            color: Colors.black,
                                            // fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                                offer.owner.phone == null ? const SizedBox.shrink()
                                    : const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                                  child: TitleDivider(title: "Contact options"),
                                ),
                                offer.owner.phone == null ? const SizedBox.shrink()
                                    : Row(
                                  children: [
                                    TextViaWhatsappButton(
                                        scaffoldKey: scaffoldKey,
                                        message: "Hi ${offer.owner.firstName.toCapitalized()},\n"
                                            "It's ${context.read<AuthenticationNotifier>().autoShareUser.firstName} "
                                            "and I'm contacting you regarding your AutoShare car rental...",
                                        phoneNumber: offer.owner.phone
                                    ),
                                    const SizedBox(width: 10),
                                    CallButton(
                                      scaffoldKey: scaffoldKey,
                                      phoneNumber: offer.owner.phone
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                                  child: TitleDivider(title: "Request pick-up & return dates"),
                                ),
                                Row(
                                  children: <Widget>[
                                    const Icon(Icons.calendar_today, color: Palette.autoShareBlue,),
                                    const SizedBox(width: 10),
                                    Text(
                                      formattedDatesRange(requestStartDate, requestEndDate),
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                                  child: TitleDivider(title: "Pick-up & return location"),
                                ),
                                Row(
                                  children: <Widget>[
                                    const Icon(Icons.location_on),
                                    const SizedBox(width: 10),
                                    Text(
                                      offer.location.toString().toTitleCase(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                                  child: TitleDivider(title: "Technical details"),
                                ),
                                ListTile(
                                    title: const Text('Year'),
                                    trailing: Text(
                                      offer.car.year != null ? offer.car.year.toString() : "No info",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(vertical: -4)
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: const Divider(
                                    color: Colors.black45,
                                  ),
                                ),
                                ListTile(
                                    title: const Text('Mileage'),
                                    trailing: Text(
                                      offer.car.mileage != null ? offer.car.mileage.toString() : "No info",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(vertical: -4)
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: const Divider(
                                    color: Colors.black45,
                                  ),
                                ),
                                ListTile(
                                    title: const Text('Gearbox'),
                                    trailing: Text(
                                      offer.car.gearbox != null ? offer.car.gearbox.toString() : "No info",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(vertical: -4)
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: const Divider(
                                    color: Colors.black45,
                                  ),
                                ),
                                offer.car.description == "" ? const SizedBox.shrink()
                                    : const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                                  child: TitleDivider(title: "Car description"),
                                ),
                                offer.car.description == "" ? const SizedBox.shrink()
                                    : Text(
                                  "${offer.car.description}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: TitleDivider(title: "Pricing"),
                                ),
                                ListTile(
                                    title: const Text('Total rental fee'),
                                    trailing: Text(
                                      "${rentalPeriodToPrice(requestStartDate, requestEndDate, offer.car.pricePerDay, offer.car.pricePerHour)}\$",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(vertical: -4)
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: const Divider(
                                    color: Colors.black45,
                                  ),
                                ),
                                ListTile(
                                    title: const Text('Price per day'),
                                    trailing: Text(
                                      "${offer.car.pricePerDay}\$",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(vertical: -4)
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: const Divider(
                                    color: Colors.black45,
                                  ),
                                ),
                                ListTile(
                                    title: const Text('Price per hour'),
                                    trailing: Text(
                                      "${offer.car.pricePerHour}\$",
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                    visualDensity: const VisualDensity(vertical: -4)
                                ),
                              ],
                            ),
                          ),
                        )
                    ),
                  ),
                  onConfirmClick == null
                      ? const SizedBox.shrink()
                      : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 7.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              backgroundColor: Palette.autoShareDarkBlue,
                              disabledBackgroundColor: Palette.autoShareDarkBlue
                          ),
                          onPressed: (){
                            onConfirmClick();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Send request",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(flex: 1, child: ElevatedButton(
                          onPressed: (){
                            if(onRejectClick != null){
                              onRejectClick();
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 7.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Palette.autoShareLightGrey,
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black, fontSize: 14,),
                          ),
                        )),
                      ],
                    ),
                  ),
                  onCancelClick == null
                      ? const SizedBox.shrink()
                      : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        developer.log("onCancelClick pressed");
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm cancellation"),
                                content: const Text("Are you sure you want to cancel this rental request?"),
                                actions: [
                                  TextButton(
                                    onPressed: (){
                                      onCancelClick();
                                      snackBarMassage(scaffoldKey: scaffoldKey, msg: "Request is canceled");
                                      Navigator.pop(context);// pop dialog
                                      Navigator.pop(context);// pop modal

                                    },
                                    child: const Text("Yes"),
                                  ),
                                  TextButton(
                                    onPressed:  (){
                                      Navigator.pop(context);
                                    },
                                    child: const Text("No"),
                                  ),
                                ],
                              );
                            }
                        );

                        // Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 7.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Cancel request",
                        style: TextStyle(color: Colors.black, fontSize: 14,),
                      ),
                    ),
                  )
                ],
              );
            }
        );
      }
  );
}

// void activeRenterRentalModalBottomSheet(context, {double scrollableHeight = 0.55}) {
//   showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//         return StatefulBuilder(
//             builder: (BuildContext context, StateSetter setStateModal){
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     height: 50,
//                     child: ListTile(
//                       leading: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const <Widget>[
//                           FaIcon(FontAwesomeIcons.key, color: Palette.autoShareBlue),
//                           // Icon(Icons.car_rental),
//                           SizedBox(width: 10),
//                           Text(
//                             "Active rental",
//                             style: TextStyle(
//                                 color: Colors.black87,
//                                 fontSize: 20
//                             ),
//                           )
//                         ],
//                       ),
//                       // leading: const Text("Active rental"),
//                       trailing: const Icon(Icons.keyboard_arrow_up),
//                     ),
//                   ),
//                   // Row(
//                   //   children: <Widget>[
//                   //     const Text("Offer details"),
//                   //     const Spacer(),
//                   //     IconButton(
//                   //       icon: const Icon(Icons.close),
//                   //       onPressed: () => Navigator.pop(context),
//                   //     )
//                   //   ],
//                   // ),
//                   SizedBox(
//                     height: MediaQuery.of(context).size.height * scrollableHeight,
//                     child: Scaffold(
//                         key: scaffoldKey,
//                         body: Padding(
//                           padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Padding(
//                                   padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
//                                   child: TitleDivider(title: "Request pick-up & return dates"),
//                                 ),
//                                 Row(
//                                   children: <Widget>[
//                                     const Icon(Icons.calendar_today, color: Palette.autoShareBlue,),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       formattedDatesRange(DateTime.now(), DateTime.now()),
//                                       style: const TextStyle(
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                     ),
//                   ),
//                 ],
//               );
//             }
//         );
//       }
//   );
// }

