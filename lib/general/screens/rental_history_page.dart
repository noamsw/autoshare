import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/database/models/history_item.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:cupertino_icons/cupertino_icons.dart';


class RentalHistoryPage extends StatefulWidget {
  const RentalHistoryPage({Key? key}) : super(key: key);

  @override
  State<RentalHistoryPage> createState() => RentalHistoryPageState();
}

class RentalHistoryPageState extends State<RentalHistoryPage> with TickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if(MediaQuery.of(context).viewInsets.bottom != 0){
            FocusScope.of(context).requestFocus(FocusNode());
            return false;
          }
          return true;
        },
        child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Rental History'),
        ),
        body: FutureBuilder(
          future: context.read<AuthenticationNotifier>().userDataBase!.cleanOutOfDateRequestsAndOfferAndUpdateHistory(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              developer.log(snapshot.error.toString());
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: "Renter"),
                        Tab(text: "Car Owner"),
                      ]),
                  Flexible(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        FutureBuilder(
                          future: context.read<AuthenticationNotifier>().userDataBase!.getRenterHistory(),
                          builder: (BuildContext context, AsyncSnapshot<List<RenterHistoryItem>> renterSnapshot) {
                            if (renterSnapshot.hasError) {
                              developer.log(renterSnapshot.error.toString());
                              return const Text('Something went wrong');
                            }
                            if (renterSnapshot.connectionState == ConnectionState.done) {
                              return renterSnapshot.data!.isNotEmpty ?
                                ListView.builder(
                                itemCount: renterSnapshot.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              icon: const Icon(Icons.history),
                                              title: const Text('Rental Details'),
                                              content: SizedBox(
                                                // height: 180,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.drive_eta,
                                                                size: 15),
                                                            const SizedBox(width: 5),
                                                            Expanded(
                                                              child: Text(renterSnapshot.data![index].carInfo,
                                                                overflow: TextOverflow.clip,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const Divider(thickness: 1, color: Colors.transparent),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.history,
                                                                size: 15),
                                                            const SizedBox(width: 5),
                                                            Expanded(
                                                              child: Text(formattedDatesRange(
                                                                  renterSnapshot
                                                                      .data![index].startDate,
                                                                  renterSnapshot
                                                                      .data![index].endDate),
                                                                overflow: TextOverflow.clip,),
                                                            )
                                                          ],
                                                        ),
                                                        const Divider(thickness: 1, color: Colors.transparent),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.location_on,
                                                                size: 15),
                                                            const SizedBox(width: 5),
                                                            Expanded(
                                                              child: Text(
                                                                  renterSnapshot.data![index].location,
                                                                overflow: TextOverflow.clip,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const Divider(thickness: 1, color: Colors.transparent),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.person,
                                                                size: 15),
                                                            const SizedBox(width: 5),
                                                            Expanded(
                                                              child: Text(
                                                                  [renterSnapshot.data![index].carOwnerName, renterSnapshot.data![index].carOwnerPhone].where((element) => element!=null).join(", "),
                                                                overflow: TextOverflow.clip,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const Divider(thickness: 1, color: Colors.transparent),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.attach_money,
                                                                size: 15),
                                                            const SizedBox(width: 5),
                                                            Text(
                                                                "${renterSnapshot.data![index].price}\$"),
                                                          ],
                                                        )
                                                      ]),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: const Text('ok'),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Card(
                                      child: ListTile(
                                        leading: const Icon(Icons.history),
                                        title: Text(renterSnapshot
                                            .data![index].carInfo,
                                          overflow: TextOverflow.fade,),
                                        subtitle: Text(formattedDatesRange(
                                            renterSnapshot
                                                .data![index].startDate,
                                            renterSnapshot
                                                .data![index].endDate),
                                          overflow: TextOverflow.fade,),
                                        trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                                      ),
                                    ),
                                  );
                                },
                              )
                                : const Center(child: Text("You don't have history yet"));;
                            }
                            return const Center(child: CircularProgressIndicator());
                          }
                        ),
                        FutureBuilder(
                            future: context.read<AuthenticationNotifier>().userDataBase!.getCarsOwnerHistory(),
                            builder: (BuildContext context, AsyncSnapshot<List<CarOwnerHistoryItem>> ownerSnapshot) {
                              if (ownerSnapshot.hasError) {
                                developer.log(ownerSnapshot.error.toString());
                                return const Text('Something went wrong');
                              }
                              if (ownerSnapshot.connectionState == ConnectionState.done) {
                                return ownerSnapshot.data!.isNotEmpty ?
                                  ListView.builder(
                                  itemCount: ownerSnapshot.data!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                icon: const Icon(Icons.history),
                                                title: const Text('Rental Details'),
                                                content: SizedBox(
                                                  height: 180,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.drive_eta,
                                                                  size: 15),
                                                              const SizedBox(width: 5),
                                                              Expanded(
                                                                child: Text(
                                                                  ownerSnapshot.data![index].carInfo,
                                                                  overflow: TextOverflow.clip,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Divider(thickness: 1, color: Colors.transparent),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.history,
                                                                  size: 15),
                                                              const SizedBox(width: 5),
                                                              Expanded(
                                                                child: Text(formattedDatesRange(
                                                                    ownerSnapshot
                                                                        .data![index].startDate,
                                                                    ownerSnapshot
                                                                        .data![index].endDate),
                                                                  overflow: TextOverflow.clip,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(thickness: 1, color: Colors.transparent),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.location_on,
                                                                  size: 15),
                                                              const SizedBox(width: 5),
                                                              Expanded(
                                                                child: Text(
                                                                  ownerSnapshot.data![index].location,
                                                                  overflow: TextOverflow.clip,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(thickness: 1, color: Colors.transparent),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.person,
                                                                  size: 15),
                                                              const SizedBox(width: 5),
                                                              Expanded(
                                                                child: Text(
                                                                    [ownerSnapshot.data![index].renterName.toTitleCase(), ownerSnapshot.data![index].renterPhone].where((element) => element!=null).join(", "),
                                                                  overflow: TextOverflow.clip,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const Divider(thickness: 1, color: Colors.transparent),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                  Icons.attach_money,
                                                                  size: 15),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                  "${ownerSnapshot.data![index].price}\$"),
                                                            ],
                                                          )
                                                        ]),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: const Text('ok'),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: Card(
                                        child: ListTile(
                                          leading: const Icon(Icons.history),
                                          title: Text(ownerSnapshot
                                              .data![index].carInfo),
                                          subtitle: Text(formattedDatesRange(
                                              ownerSnapshot
                                                  .data![index].startDate,
                                              ownerSnapshot
                                                  .data![index].endDate),
                                            overflow: TextOverflow.ellipsis,),
                                          trailing: const Icon(Icons.keyboard_arrow_right_outlined),
                                        ),
                                      ),
                                    );
                                  },
                                )
                                  : const Center(child: Text("You don't have history yet"));
                              }
                              return const Center(child: CircularProgressIndicator());
                            }
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
    ),

    );
  }
}
