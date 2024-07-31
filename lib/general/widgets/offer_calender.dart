import 'package:auto_share/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:developer' as developer;
import 'package:auto_share/general/utils.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/owner/utils.dart';



class OfferCalender extends StatelessWidget {
  final Offer offer;

  const OfferCalender({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context
          .read<AuthenticationNotifier>()
          .userDataBase!
          .getOfferRequests(offer, RequestStatus.confirmed),
      builder: (BuildContext context, AsyncSnapshot<List<Request>> snapshot) {
        if (snapshot.hasError){
          developer.log("error in offer calender: ${snapshot.error}", name: "offerCalender");
          return const Center(child: Text('Error'));
        }
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No confirmed requests'));
          }
          Map<DateTime, List<Request>> dayToRequestsMap = {};
          List<Color> colors = [
            Colors.green,
            Colors.orange,
            Colors.blue,
            Colors.red,
            Colors.yellow,
            Colors.purple,
            Colors.pink,
            Colors.teal,
            Colors.cyan,
            Colors.lime,
            Colors.indigo,
            Colors.brown,
          ];
          int index = 0;
          for (Request request in snapshot.data!) {
            request.extra = colors[index++ % colors.length];
            var dates =
                getDatesFromRange(request.startDateHour, request.endDateHour);
            for (DateTime date in dates) {
              DateTime dateOnly = DateUtils.dateOnly(date);
              if (dayToRequestsMap.containsKey(dateOnly)) {
                dayToRequestsMap[dateOnly]!.add(request);
              } else {
                dayToRequestsMap[dateOnly] = [request];
              }
            }
          }
          return EventsCalender(
            offer: offer,
            requests: dayToRequestsMap,
          );
        }
        else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class EventsCalender extends StatefulWidget {
  final Offer offer;
  final Map<DateTime, List<Request>>? requests;

  const EventsCalender({Key? key, required this.offer, this.requests})
      : super(key: key);

  @override
  State<EventsCalender> createState() => _EventsCalenderState();
}

class _EventsCalenderState extends State<EventsCalender> {
  DateTime selectedDay = DateTime.now();

  @override
  initState() {
    developer.log("init state", name: "EventsCalender");
    super.initState();
    selectedDay = DateUtils.dateOnly(widget.offer.startDateHour);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedDay.isBefore(widget.offer.startDateHour) ||
        selectedDay.isAfter(widget.offer.endDateHour)) {
      selectedDay = DateUtils.dateOnly(widget.offer.startDateHour);
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TableCalendar(
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            firstDay: widget.offer.startDateHour,
            lastDay: widget.offer.endDateHour,
            focusedDay: selectedDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekVisible: true,
            //Day Changed
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = DateUtils.dateOnly(selectedDay);
                // this.focusedDay = focusedDay; // update `_focusedDay` here as well
              });
            },
            eventLoader: (day) {
              // Use `eventLoader` to return a list of events
              // that will be displayed on the specified `day`.
              return widget.requests![DateUtils.dateOnly(day)] ?? [];
            },

            //To style the Calendar
            calendarStyle: const CalendarStyle(
              isTodayHighlighted: false,
              selectedDecoration: BoxDecoration(
                color: Palette.autoShareBlue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              formatButtonShowsNext: false,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Colors.black,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Colors.black,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (Object? request in events)
                      Container(
                        margin: const EdgeInsets.all(1),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (request as Request).extra! as Color,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(
            thickness: 2,
            color: Colors.transparent,
          ),
          Stack(
            children: [
              Container(
                height: 300
              ),
              widget.requests != null
                  ? ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.requests![selectedDay]?.length ?? 0,
                separatorBuilder: (_, __) =>
                const Divider(
                  height: 7,
                  color: Colors.transparent,
                ),
                itemBuilder: (context, index) {
                  Request request = widget.requests![selectedDay]![index];
                  return CalenderItemTemplate(
                    title: "${request.requestedBy.firstName.toTitleCase()} ${request.requestedBy.lastName.toTitleCase()}",
                    subtitle: formattedDatesRange(request.startDateHour, request.endDateHour),
                    leadingColor: request.extra as Color,
                    imageUrl: request.requestedBy.profilePicture,
                    onTap: () => requestInfoModalBottomSheet(
                      context,
                      request,
                    ),
                  );
                },
              )
                  : Container()
            ]
          )
        ],
      ),
    );
  }
}
