import 'dart:developer' as developer;
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/car.dart';
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

import '../../router/route_constants.dart';


class CarDetailsPage extends StatefulWidget {
  final Car car;

  const CarDetailsPage({Key? key, required this.car}) : super(key: key);

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Car? _car;

  @override
  void initState() {
    _car = widget.car;
    super.initState();
  }

  //callback for updating _car field
  void _updateCar(Car car){
    setState(() {
      _car = car;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AuthenticationNotifier>().userDataBase!.getCars(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          Car car = _car!;
          var urlImages = car.pictures;
          int activeIndex = 0;
          final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Car details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.pushNamed(RouteConstants.updateCar, extra: {'car': car, 'update_car': _updateCar});
                    setState(() {
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete car'),
                          content: const Text('Are you sure you want to delete this car?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await Database.deleteCarDoc(car.id);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }
                                catch (error){
                                  developer.log(error.toString());
                                  Navigator.of(context).pop();
                                  snackBarMassage(scaffoldKey: _scaffoldKey, msg: error.toString());
                                }
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setStater){
                  developer.log('build CarDetailsPage');
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
                                      "${car.make} ${car.model} ${car.year != null ? car.year.toString() : ""}",
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
                            child: TitleDivider(title: "Technical details"),
                          ),
                          ListTile(
                              title: const Text('license plate'),
                              trailing: Text(
                                car.licencePlate.toString(),
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
                              title: const Text('category'),
                              trailing: Text(
                                car.category.toString(),
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
                              title: const Text('Year'),
                              trailing: Text(
                                car.year != null ? car.year.toString() : "No info",
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
                                car.mileage != null ? car.mileage.toString() : "No info",
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
                                car.gearbox != null ? car.gearbox.toString() : "No info",
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
                          car.description == "" ? const SizedBox.shrink()
                              : const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Car description"),
                          ),
                          car.description == "" ? const SizedBox.shrink()
                              : Text(
                            "${car.description}",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: TitleDivider(title: "Pricing"),
                          ),
                          ListTile(
                              title: const Text('Price per hour'),
                              trailing: Text(
                                "${car.pricePerHour}\$",
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
                                "${car.pricePerDay}\$",
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
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                            child: TitleDivider(title: "Default pick-up & return location"),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(
                              car.location,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            leading: const Icon(Icons.location_on, color: Palette.autoShareBlue),
                            minLeadingWidth: 0,
                            horizontalTitleGap: 7,

                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                            child: const Divider(
                              color: Colors.black45,
                            ),
                          ),
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
