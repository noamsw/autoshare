import 'dart:developer' as developer;
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/database/models/car.dart';
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:flutter/material.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/database/utils.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:auto_share/owner/widgets/headline_separated_list.dart';

class OffersList extends StatelessWidget {
  const OffersList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<Car, List<Offer?>>>(
      stream: context
          .read<AuthenticationNotifier>()
          .userDataBase!
          .getOffersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          developer.log(snapshot.error.toString(), name: 'OffersList');
          return const Text('Something went wrong');
        } else if (snapshot.hasData || snapshot.data != null) {
          var listContent = snapshot.data!.map((car, offers){
            return MapEntry(
                "${car.toString()} • ${car.licencePlate}",
                offers.map((offer) => ListItemTemplate(
                  title: formattedDatesRange(
                      offer!.startDateHour, offer.endDateHour),
                  firstSubtitle: [
                    offer.car.toString(),
                    offer.car.licencePlate.toString()
                  ].where((e) => e != null).toList().join(' • '),
                  secondSubtitle: offer.location.toString(),
                  imageUrl: offer.car.primaryPicture,
                  locationIcon: true,
                  onTap: () => context.pushNamed(
                      RouteConstants.offerDetails,
                      extra: offer),
                )).toList()
            );
          });
          return snapshot.data!.isNotEmpty?
          HeadlineSeparatedList(content: listContent):
          const Center(child: Text("You haven't added any offers yet"));

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

class OffersPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const OffersPage(this.scaffoldKey, {Key? key}) : super(key: key);

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  @override
  Widget build(BuildContext context) {
    return const OffersList();
  }
}
