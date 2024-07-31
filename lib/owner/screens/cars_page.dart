import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/models/car.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

class CarsList extends StatelessWidget {
  const CarsList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Car?>>(
      stream: context.read<AuthenticationNotifier>().userDataBase!.getCarsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          developer.log("error: ${snapshot.error}", name: 'CarsList');
          return const Text('Something went wrong');
        } else if (snapshot.hasData || snapshot.data != null) {
          return snapshot.data!.isNotEmpty ?
            ListView.separated(
            separatorBuilder: (context, index) => Container(height: 8.0),
            padding: const EdgeInsets.fromLTRB(10,25,10,20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var car = snapshot.data![index];
              NumberFormat numFormat = NumberFormat.decimalPattern('en_us');
              List<String?> carInfos = [
                car?.mileage != null ? "${numFormat.format(car?.mileage)} km" : null,
                car?.year?.toString(),
                car?.gearbox?.toString(),
              ].where((e) => e != null).toList();
              return car==null? const Text('error') : ListItemTemplate(
                      title: car.toString(),
                      firstSubtitle: carInfos.join(' • ').toString(),
                      secondSubtitle: "${car.pricePerHour}\$/h • ${car.pricePerDay}\$/day",
                      imageUrl: car.primaryPicture,
                      onTap: () => context.pushNamed(RouteConstants.carDetails, extra: car),);
            },
          ):
            const Center(child: Text("You haven't added cars yet"));
        }
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class CarsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const CarsPage(this.scaffoldKey, {Key? key}) : super(key: key);

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {

  @override
  Widget build(BuildContext context) {
    return const CarsList();
  }
}

