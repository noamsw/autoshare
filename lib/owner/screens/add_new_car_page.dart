import 'dart:developer' as developer;
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/database/storage_api.dart';
import 'package:auto_share/owner/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/owner/widgets/image_picker_form_field.dart';
import 'dart:io';
import 'package:ndialog/ndialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_share/owner/widgets/make_model_fields.dart';
import 'package:auto_share/owner/widgets/searchable_dropdown_field.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:auto_share/renter/searchmodal.dart';

class AddNewCarPage extends StatefulWidget {
  const AddNewCarPage({Key? key}) : super(key: key);

  @override
  State<AddNewCarPage> createState() => _AddNewCarPageState();
}

class _AddNewCarPageState extends State<AddNewCarPage> {
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
  final List<File?> _images = List<File?>.generate(4, (index) => null);

  void _addImage(File image, int index) {
    _images[index] = image;
  }

  void _removeImage(int index) {
    _images[index] = null;
  }

  final _addCarFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    _categoryController.text = 'Economy';
    super.initState();
  }

  Future<DocumentReference<Map<String, dynamic>>> uploadImagesAndCreateCarDoc() async {
    var imageUrls = await StorageService.uploadImages(_images,'cars/');
    return await context.read<AuthenticationNotifier>().userDataBase!.createNewCarDoc(
      make: _selectedMake!,
      model: _selectedModel!,
      licencePlate: _licencePlateController.text,
      year: _yearController.text!=''? int.parse(_yearController.text) : null,
      mileage: _mileageController.text!=''? int.parse(_mileageController.text) : null,
      gearbox: _gearboxController.text==''? null : _gearboxController.text,
      category: _categoryController.text,
      location: _locationController.text,
      description: _descriptionController.text,
      pricePerHour: int.parse(_pricePerHourController.text),
      pricePerDay: int.parse(_pricePerDayController.text),
      imageUrls: imageUrls.isNotEmpty? imageUrls : null,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          if (snapshot.hasData){
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: const Text('Add new car'),
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
                          label: "Car licence plate",
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
                        label: 'Year',
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
                        label: 'Mileage'),
                      const Divider(
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      SearchableDropDown(
                        label: 'gearbox',
                        items: const [
                          'Automatic',
                          'Manual',
                          'Semi-automatic',
                          'Other'
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
                        initialValue: 'Economy',
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
                        label: 'Description',
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
                        label: 'Price per hour',
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
                        label: 'Price per day',
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
                                index: 3,
                                carId: 'car-id',
                                imageAdded: _addImage,
                                imageRemoved: _removeImage),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_addCarFormKey.currentState!.validate()) {
                              developer.log("add car form is valid");
                              await ProgressDialog.future(
                                context,
                                title: const Text("Uploading car..."),
                                message: const Text("This may take few seconds"),
                                future: uploadImagesAndCreateCarDoc(),
                                onProgressFinish: (doc) => developer
                                    .log("new car was added with id: ${doc.id}"),
                                onProgressError: (error) => developer
                                    .log("error while uploading car: $error"),
                                dismissable: false,
                              );
                              snackBarMassage(scaffoldKey: _scaffoldKey, msg:
                              '$_selectedMake $_selectedModel added to My cars');
                              GoRouter.of(context).pop();
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            );
          }
          else{
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _gearboxController.dispose();
    _locationController.dispose();
    _pricePerDayController.dispose();
    _pricePerHourController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
