import 'dart:developer' as developer;
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/models/request.dart';
import 'package:auto_share/database/models/car.dart';
import 'package:auto_share/database/utils.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/owner/widgets/headline_separated_list.dart';

class StreamBadge extends StatelessWidget {
  const StreamBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: context.read<AuthenticationNotifier>().userDataBase!.getIncomingRequestsNumberStream(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if(snapshot.hasData){
          return Badge(
            showBadge: snapshot.data! > 0,
            badgeContent: Text(snapshot.data.toString()),
            child: const Icon(Icons.email_outlined),
          );
        }
        return const Text('');
      }
    );
  }
}


class RequestsList extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const RequestsList(this.scaffoldKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<Car,List<Request>>>(
      stream: context.read<AuthenticationNotifier>().userDataBase!.getIncomingRequestsStream(),
      builder: (context, snapshot) {
        List<String> cars = [];
        if (snapshot.hasError) {
          developer.log('Error: ${snapshot.error.toString()}');
          return const Text('Something went wrong');
        }
        else if (snapshot.hasData || snapshot.data != null) {
          var listContent = snapshot.data!.map((car, requests){
            return MapEntry(
                "${car.toString()} • ${car.licencePlate}",
                requests.map((request) => RequestTileTemplate(
                  scaffoldKey,
                  request: request,
                  onConfirmClick: () async {
                    if(await Database.confirmRequest(request)){
                      snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Request confirmed');
                    }
                    else{
                      snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Error has occurred while confirming request');
                    }
                  },
                  onRejectClick: () async {
                    if(await Database.rejectRequest(request)){
                      snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Request rejected');
                    }
                    else{
                      snackBarMassage(scaffoldKey: scaffoldKey, msg: 'Error has occurred while rejecting request');
                    }
                  },
                )).toList()
            );
          });
          return snapshot.data!.isNotEmpty?
            HeadlineSeparatedList(content: listContent) :
            const Center(child: Text("You don't have any incoming requests"));
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

class RequestsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const RequestsPage(this.scaffoldKey, {Key? key}) : super(key: key);

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {

  @override
  Widget build(BuildContext context) {
    return RequestsList(widget.scaffoldKey);
  }
}

