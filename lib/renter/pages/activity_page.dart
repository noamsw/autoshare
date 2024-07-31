import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:auto_share/owner/widgets/headline_separated_list.dart';
import 'package:flutter/material.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/renter/utils.dart';
import 'package:auto_share/general/utils.dart';
import 'dart:developer' as developer;

final activityRenterPageKey = GlobalKey<_ActivityPageState>();

class ActivityList extends StatelessWidget {
  final RequestStatus status;
  const ActivityList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Request?>>(
      stream: context.read<AuthenticationNotifier>().userDataBase!.getOutgoingRenterRequestsStream(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        } else if (snapshot.hasData || snapshot.data != null) {
          return snapshot.data!.isNotEmpty?
          ListView.separated(
            separatorBuilder: (context, index) => Container(height: 8.0),
            padding: const EdgeInsets.fromLTRB(10,25,10,20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var request = snapshot.data![index];

              return request == null ? const SizedBox.shrink() : ListItemTemplate(
                    title: request.offer.car.toString(),
                    firstSubtitle: formattedDatesRange(
                        request.startDateHour, request.endDateHour),
                    secondSubtitle: request.offer.location.toString(),
                    locationIcon: true,
                    imageUrl: request.offer.car.primaryPicture,
                    trailing: null,
                    onTap: (){
                     if(status == RequestStatus.confirmed && request.startDateHour.isBefore(DateTime.now())){
                        activeRentalModalBottomSheet(context, request, UserMode.renterMode);
                       return;
                     }
                     else if(status == RequestStatus.pending){
                       offerInfoModalBottomSheet(
                         context,
                         request.offer,
                         request.startDateHour,
                         request.endDateHour,
                         onCancelClick: () => Database.deleteRequestDoc(request.id)
                       );
                       return;
                     }
                     offerInfoModalBottomSheet(
                         context,
                         request.offer,
                         request.startDateHour,
                         request.endDateHour,
                     );
                     return;
                    }
              );
            },
          ) :
          Center(child: Text("You don't have any ${status.name} requests"),);
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

class ConfirmedActivityHeadlinedList extends StatelessWidget {
  const ConfirmedActivityHeadlinedList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthenticationNotifier>().userDataBase!.getConfirmedOutgoingRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          developer.log("error: ${snapshot.error}");
          return const Text('Something went wrong');
        }
        else if (snapshot.hasData || snapshot.data != null) {
          var listContent = snapshot.data!.map((headline, requests){
            return MapEntry(
                headline,
                requests.map((request) => ListItemTemplate(
                    borderColor: headline == "In progress" ? ((request!.endDateHour.isBefore(DateTime.now()) && !request.ownerApprovedReturn) ? Colors.red : Colors.green) : const Color(0xBDCBCBCB),
                    aboveTrailingColor: headline == "In progress" ? ((request!.endDateHour.isBefore(DateTime.now()) && !request.ownerApprovedReturn) ? Colors.red : Colors.green) : null,
                    borderWidth: headline == "In progress" ? 2.0 : 1.0,
                    aboveTrailing:  headline == "In progress" ? ((request!.endDateHour.isBefore(DateTime.now()) && !request.ownerApprovedReturn) ? "Return keys!" : "Active") : null,
                    title: request!.offer.car.toString(),
                    firstSubtitle: formattedDatesRange(
                        request.startDateHour, request.endDateHour),
                    secondSubtitle: request.offer.location.toString(),
                    locationIcon: true,
                    imageUrl: request.offer.car.primaryPicture,
                    trailing: null,
                    onTap: (){
                      if(request.startDateHour.isBefore(DateTime.now())){
                        activeRentalModalBottomSheet(context, request, UserMode.renterMode);
                        return;
                      }
                      offerInfoModalBottomSheet(
                        context,
                        request.offer,
                        request.startDateHour,
                        request.endDateHour,
                        onCancelClick: () => Database.deleteRequestDoc(request.id)
                      );
                      return;
                    }
                )).toList()
            );
          });
          return snapshot.data!.isNotEmpty?
          HeadlineSeparatedList(content: listContent) :
          Center(child: Text("You don't have any outgoing requests"),);
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


class ActivityPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int? initialTabIndex;
  const ActivityPage(this.scaffoldKey, {Key? key, this.initialTabIndex}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with TickerProviderStateMixin {

  late TabController _tabController;

  changeTab(int value) {
    print("changeTab: $value");
    _tabController.animateTo(value);
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex??1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Rejected"),
              Tab(text: "Pending"),
              Tab(text: "Confirmed"),
            ]),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ActivityList(status: RequestStatus.rejected),
              ActivityList(status: RequestStatus.pending),
              ConfirmedActivityHeadlinedList(),
            ],
          ),
        )
      ],
    );
  }
}

