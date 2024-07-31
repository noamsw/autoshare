import 'dart:developer' as developer;
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/models/car.dart';
import 'package:auto_share/database/utils.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:auto_share/owner/widgets/custom_field.dart';
import 'package:ndialog/ndialog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/general/widgets/custom_dates_range_picker.dart';
import 'package:auto_share/renter/searchmodal.dart';

class AddNewOfferPage extends StatefulWidget {
  const AddNewOfferPage({Key? key}) : super(key: key);

  @override
  State<AddNewOfferPage> createState() => _AddNewOfferPageState();
}

class _AddNewOfferPageState extends State<AddNewOfferPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _datesRangeController = TextEditingController();
  String? _selectedCar;
  DateTime _selectedStartDate = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1);
  DateTime _selectedEndDate = DateTime(DateTime.now().year,
       DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1)
      .add(const Duration(days: 1));
  final _addOfferFormKey = GlobalKey<FormState>();

  final _dateFormat = [M, ' ', d, ', ', H, ':', nn];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<AuthenticationNotifier>().userDataBase!.getCars(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Make new Offer'),
            ),
            body: Form(
              key: _addOfferFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    const Divider(
                      thickness: 2,
                      color: Colors.transparent,
                    ),
                    DropdownButtonFormField(
                      isExpanded: true,
                      items: snapshot.data
                          .map<DropdownMenuItem<String>>((Car car) {
                        return DropdownMenuItem<String>(
                          value: car.id,
                          child:
                              Text("${car.toString()} • ${car.licencePlate}", overflow: TextOverflow.ellipsis,),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        _selectedCar = value;
                        _addressController.text = snapshot.data
                            .firstWhere((Car car) => car.id == value)?.location??'';
                      },
                      decoration: InputDecoration(
                        icon: const Icon(Icons.directions_car),
                        alignLabelWithHint: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const  BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'car',
                        hintText: 'Choose a car',
                        hintStyle: TextStyle(
                          fontSize: 15.5,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        errorStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please choose car';
                        }
                        return null;
                      },
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.transparent,
                    ),
                    TextFormField(
                      readOnly: true,
                      showCursor: false,
                      keyboardType: TextInputType.none,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        icon: const Icon(Icons.calendar_today),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'dates range',
                        hintText: 'Enter dates range',
                        hintStyle: TextStyle(
                          fontSize: 15.5,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        errorStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      controller: _datesRangeController,
                      onTap: () async {
                        final datesRange = await customDatesRangePicker(
                          context,
                          initialStartDate: _selectedStartDate,
                          initialEndDate: _selectedEndDate,
                        );
                        _selectedStartDate = datesRange!.startDate!;
                        _selectedEndDate = datesRange!.endDate!;
                        _datesRangeController.text = formattedDatesRange(
                            _selectedStartDate, _selectedEndDate);
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter start date';
                        }
                        return null;
                      },
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.transparent,
                    ),
                    CustomFormField(
                        onTap: () async {
                          var location = await modalSearchBar(context);
                          _addressController.text = location!.address;
                        },
                        readOnly: true,
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        inputAction: TextInputAction.done,
                        icon: const Icon(Icons.location_on),
                        label: 'pickup address',
                        hint: 'Enter pickup address',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pickup address';
                          }
                          return null;
                        },
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.transparent,
                    ),
                    Center(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_addOfferFormKey.currentState!.validate()) {
                              _addOfferFormKey.currentState!.save();
                              developer.log("add offer form is valid");
                              await ProgressDialog.future(
                                context,
                                title: const Text("Uploading offer..."),
                                message: const Text("This may take few seconds"),
                                future: context.read<AuthenticationNotifier>().userDataBase!.createNewOfferDoc(
                                    carId: _selectedCar!,
                                    startDate: _selectedStartDate,
                                    endDate: _selectedEndDate,
                                    address: _addressController.text
                                ),
                                onProgressError: (dynamic error) {
                                  developer.log("error while uploading car information");
                                  developer.log(error.toString());
                                  snackBarMassage(scaffoldKey: _scaffoldKey, msg: error.toString());
                                  // GoRouter.of(context).pop();
                                },
                                onProgressFinish: (doc) {
                                  developer.log("new offer was added with id: ${doc.id}");
                                  snackBarMassage(scaffoldKey: _scaffoldKey, msg: 'New offer was added to My offer');
                                  GoRouter.of(context).pop();
                                },
                                dismissable: false,
                              );
                            }
                          },
                          child: const Text('Add Offer'),
                        ),
                      ),
                    ),
                  ],
                )),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _datesRangeController.dispose();
    super.dispose();
  }
}
