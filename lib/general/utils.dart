import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/general/widgets/active_rental_content.dart';
import 'package:auto_share/database/database_api.dart';


enum UserMode {
  renterMode,
  ownerMode,
}

extension DateTimeExtension on DateTime {
  bool isAtSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

class ModeAppBar extends StatelessWidget implements PreferredSizeWidget{
  const ModeAppBar({
    Key? key,
    required String mainText,
    required String modeText,
    required Icon modeIcon
  }) :
        _mainText = mainText,
        _modeText = modeText,
        _modeIcon = modeIcon,
        super(key: key);

  final String _mainText;
  final String _modeText;
  final Icon _modeIcon;


  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_mainText),
      actions: <Widget>[
        Center(
            child: Text(
              _modeText,
              style: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              )
            )
        ),
        IconButton(
            onPressed: null,
            icon: _modeIcon
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

String birthDateToString(DateTime? birthDate) {
  if (birthDate == null) {
    return '';
  }
  return '${birthDate.day}/${birthDate.month}/${birthDate.year}';
}

int rentalPeriodToPrice(DateTime startDate, DateTime endDate, int pricePerDay, int pricePerHour){
  int price;
  int hoursDiff = endDate.difference(startDate).inHours;
  if(hoursDiff == 0){
    hoursDiff+=1;
  }
  DateTime startDay = DateTime(startDate.year,startDate.month,startDate.day);
  DateTime endDay = DateTime(endDate.year,endDate.month,endDate.day);
  int daysDiff = endDay.difference(startDay).inDays + 1;
  if(hoursDiff < 24){
    price =  min(pricePerHour*hoursDiff, pricePerDay*daysDiff);
    return price;
  }
  return pricePerDay * daysDiff;
  // return min(priceToRentByHours, priceToRentByDays);
}

List<DateTime> getDatesFromRange(DateTime startDate, DateTime endDate) {
  List<DateTime> dates = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    dates.add(startDate.add(Duration(days: i)));
  }
  return dates;
}

Future<void> activeRentalModalBottomSheet(context, Request request, UserMode rentalMode) async {
  await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (builder) {
        final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text("Active rental details"),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Scaffold(
                key: scaffoldKey,
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: SingleChildScrollView(
                    child: StreamBuilder(
                      stream: Database.getRequestStream(request),
                      builder: (context, snapshot) {
                        if (snapshot.hasData || snapshot.data != null) {
                          return ActiveRentalContent(
                            scaffoldKey: scaffoldKey,
                            request: snapshot.data!,
                            userMode: rentalMode,
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
  );
}
