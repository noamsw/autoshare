import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:auto_share/owner/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityItemsList extends StatelessWidget {
  final bool inProgress;
  const ActivityItemsList({super.key, this.inProgress=false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Request?>>(
      stream: context.read<AuthenticationNotifier>().userDataBase!.getUpcomingCarOwnerActivityStream(inProgress: inProgress),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }
        else if (snapshot.hasData || snapshot.data != null) {
          return snapshot.data!.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (_, __) {
                    return Container(height: 8.0);
                  },
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Request? request = snapshot.data![index];
                    List<String?> offerInfos = [
                      request?.offer.car.toString(),
                      request?.offer.car.licencePlate.toString()
                    ].where((e) => e != null).toList();
                    if (request == null) {
                      return const Text('error');
                    } else {
                      return ListItemTemplate(
                        title: formattedDatesRange(
                            request.startDateHour, request.endDateHour),
                        firstSubtitle: offerInfos.join(' • '),
                        secondSubtitle: request.offer.location,
                        imageUrl: request.requestedBy.profilePicture,
                        locationIcon: true,
                        avatarPicture: true,
                        renterName: request.requestedBy.toString(),
                        onTap: () async{
                          if(inProgress) {
                            activeRentalModalBottomSheet(context, request, UserMode.ownerMode);
                            return;
                          }
                          requestInfoModalBottomSheet(
                            context,
                            request,
                          );
                          return;
                        },
                      );
                    }
                  },
                )
              : Center(
                  child: Text(inProgress
                      ? "You don't have any rides in progress"
                      : "You don't have any upcoming rides"));
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
  const ActivityPage(this.scaffoldKey, {Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with TickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
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
              Tab(text: "In progress"),
              Tab(text: "Upcoming"),
            ]),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ActivityItemsList(inProgress: true),
              ActivityItemsList(),
            ],
          ),
        )
      ],
    );
  }
}

