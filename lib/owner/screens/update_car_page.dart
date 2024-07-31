import 'dart:developer' as developer;
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/storage_api.dart';
import 'package:auto_share/general/utils.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/owner/widgets/custom_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/owner/widgets/image_picker_form_field.dart';
import 'dart:io';
import 'package:ndialog/ndialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_share/owner/widgets/make_model_fields.dart';
import 'package:auto_share/owner/widgets/searchable_dropdown_field.dart';
import 'package:auto_share/database/models/car.dart';
import 'package:tuple/tuple.dart';
import 'package:auto_share/database/utils.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/authentication/auth_notifier.dart';

import '../../renter/searchmodal.dart';

class UpdateCarPage extends StatefulWidget {
  final Car car;
  final Function updateCar;
  const UpdateCarPage({Key? key, required this.car, required this.updateCar}) : super(key: key);

  @override
  State<UpdateCarPage> createState() => _UpdateCarPageState();
}

class _UpdateCarPageState extends State<UpdateCarPage> {
  String? _selectedMake;
  String? _selectedModel;
  final TextEditingController _licencePlateController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _gearboxController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _pricePerDayController = TextEditingController();

  // tuple of image file and network image url = at most one of them is null
  final List<Tuple2<File?, String?>> _images =
      List<Tuple2<File?, String?>>.generate(
          4, (index) => const Tuple2(null, null));

  // list of image network urls to be deleted from storage when update is successful
  final List<String> _networkImagesToDelete = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _selectedMake = widget.car.make;
    _selectedModel = widget.car.model;
    _licencePlateController.text = widget.car.licencePlate ?? '';
    _yearController.text = widget.car.year?.toString() ?? '';
    _mileageController.text = widget.car.mileage?.toString() ?? '';
    _gearboxController.text = widget.car.gearbox ?? '';
    _categoryController.text = widget.car.category ?? '';
    _locationController.text = widget.car.location ?? '';
    _descriptionController.text = widget.car.description ?? '';
    _pricePerHourController.text = widget.car.pricePerHour.toString() ?? '';
    _pricePerDayController.text = widget.car.pricePerDay.toString() ?? '';
    widget.car.pictures
        .asMap()
        .forEach((index, imageUrl) => _images[index] = Tuple2(null, imageUrl));
    super.initState();
  }

  void _addImage(File image, int index) {
    _images[index] = Tuple2(image, null);
  }

  void _removeImage(int index) {
    developer.log("index: $index");
    if (_images[index].item2 != null) {
      _networkImagesToDelete.add(_images[index].item2!);
    }
    _images[index] = const Tuple2(null, null);
  }

  final _addCarFormKey = GlobalKey<FormState>();

  Future<DocumentReference<Map<String, dynamic>>>
      uploadImagesAndUpdateCarDoc() async {
    for (var imageUrl in _networkImagesToDelete) {
      await StorageService.deleteImage(imageUrl);
    }
    List<String> existingImageUrls = _images
        .where((tuple) => tuple.item2 != null)
        .map((tuple) => tuple.item2!)
        .toList();
    List<String> newImageUrls = await StorageService.uploadImages(
        _images
            .where((tuple) => tuple.item1 != null)
            .map((tuple) => tuple.item1!)
            .toList(),
        'cars/');
    var imageUrls = existingImageUrls + newImageUrls;
    return await context.read<AuthenticationNotifier>().userDataBase!.createNewCarDoc(
      updateExistingCar: true,
      id: widget.car.id,
      make: _selectedMake!,
      model: _selectedModel!,
      licencePlate: _licencePlateController.text,
      year: _yearController.text != '' ? int.parse(_yearController.text) : null,
      mileage: _mileageController.text != ''
          ? int.parse(_mileageController.text)
          : null,
      gearbox: _gearboxController.text == '' ? null : _gearboxController.text,
      category: _categoryController.text,
      location: _locationController.text,
      description: _descriptionController.text,
      pricePerHour: int.parse(_pricePerHourController.text),
      pricePerDay: int.parse(_pricePerDayController.text),
      imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log("update form opened for: ${widget.car.toString()}");
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('All the data will be lost.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
    },
      child: FutureBuilder(
        future: Database.getMakeModelList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: const Text('Update car information'),
              ),
              body: Form(
                key: _addCarFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                      child: Column(
                    children: <Widget>[
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      MakeModelFormFields(
                        make: widget.car.make,
                        model: widget.car.model,
                        onMakeChanged: (String? make) {
                          _selectedMake = make;
                        },
                        onModelChanged: (String? model) {
                          _selectedModel = model;
                        },
                        makeModelList: snapshot.data,
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      CustomFormField(
                          maxLength: 9,
                          controller: _licencePlateController,
                          keyboardType: TextInputType.text,
                          inputAction: TextInputAction.next,
                          hint: "Enter Car licence plate",
                          label: "car licence plate",
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter car licence plate';
                            }
                            return null;
                          }),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      CustomFormField(
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        inputAction: TextInputAction.next,
                        controller: _yearController,
                        hint: 'Enter car year',
                        label: 'year',
                        validator: (dynamic value) {
                          if (value != null && value.isNotEmpty) {
                            final int year = int.parse(value);
                            if (year.toInt() < 1900 ||
                                year.toInt() > DateTime.now().year + 1) {
                              return 'Please enter a valid year';
                            }
                          }
                          return null;
                        },
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      CustomFormField(
                          maxLength: 7,
                          keyboardType: TextInputType.number,
                          inputAction: TextInputAction.next,
                          controller: _mileageController,
                          hint: 'Enter car mileage',
                          label: 'mileage'),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      SearchableDropDown(
                        initialValue: widget.car.gearbox,
                        label: 'gearbox',
                        items: const [
                          'automatic',
                          'manual',
                          'semi-Automatic',
                          'other'
                        ],
                        isSearchable: false,
                        hint: 'Select gearbox',
                        onChanged: (String? value) {
                          _gearboxController.text = value!;
                        },
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      SearchableDropDown(
                        initialValue: widget.car.category.toTitleCase(),
                        label: 'Category',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        items: const [
                          'Economy',
                          'Compact',
                          'Standard',
                          'Full-size',
                          'Luxury',
                          'Suv',
                          'Minivan',
                        ],
                        isSearchable: false,
                        hint: 'Select category',
                        onChanged: (String? value) {
                          _categoryController.text = value!;
                        },
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      CustomFormField(
                        onTap: () async {
                          var location = await modalSearchBar(context);
                          _locationController.text = location!.address;
                        },
                        readOnly: true,
                        keyboardType: TextInputType.streetAddress,
                        inputAction: TextInputAction.next,
                        controller: _locationController,
                        hint: 'Enter car pickup location',
                        label: 'Default pickup location',
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      CustomFormField(
                        keyboardType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        controller: _descriptionController,
                        hint: 'Enter car description',
                        label: 'description',
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      CustomFormField(
                        maxLength: 5,
                        keyboardType: TextInputType.number,
                        inputAction: TextInputAction.next,
                        controller: _pricePerHourController,
                        hint: 'Enter car price per hour',
                        label: 'price per hour',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car price';
                          }
                          if (value.contains(RegExp(r'[^\d]'))) {
                            return 'Please enter an integer price';
                          }
                          return null;
                        },
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      CustomFormField(
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        inputAction: TextInputAction.done,
                        controller: _pricePerDayController,
                        hint: 'Enter car price per day',
                        label: 'price per day',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter car price';
                          }
                          if (value.contains(RegExp(r'[^\d]'))) {
                            return 'Please enter an integer price';
                          }
                          return null;
                        },
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ImagePickerFormField(
                                networkImageUrl: _images[0].item2,
                                index: 0,
                                carId: 'car-id',
                                imageAdded: _addImage,
                                imageRemoved: _removeImage),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ImagePickerFormField(
                                networkImageUrl: _images[1].item2,
                                index: 1,
                                carId: 'car-id',
                                imageAdded: _addImage,
                                imageRemoved: _removeImage),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ImagePickerFormField(
                                networkImageUrl: _images[2].item2,
                                index: 2,
                                carId: 'car-id',
                                imageAdded: _addImage,
                                imageRemoved: _removeImage),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ImagePickerFormField(
                                networkImageUrl: _images[3].item2,
                                index: 3,
                                carId: 'car-id',
                                imageAdded: _addImage,
                                imageRemoved: _removeImage),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () async {
                            if (_addCarFormKey.currentState!.validate()) {
                              developer.log("update car form is valid");
                              await ProgressDialog.future(
                                context,
                                title: const Text("Updating car information..."),
                                message: const Text("This may take few seconds"),
                                future: uploadImagesAndUpdateCarDoc(),
                                onProgressFinish: (doc) async {
                                  var carDoc = await doc.get();
                                  developer.log("car: ${doc.id} was updated");
                                  widget.updateCar(Car.fromDoc(carDoc));
                                },
                                dismissable: false,
                              );
                              snackBarMassage(scaffoldKey: _scaffoldKey, msg:
                              '$_selectedMake $_selectedModel was updated successfully');
                              GoRouter.of(context).pop();
                            }
                          },
                          child: const Text('Update'),
                        ))
                      ]),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
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
      ),
    );
  }
}
