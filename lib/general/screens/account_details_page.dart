import 'package:auto_share/res/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:auto_share/authentication/email_password/widgets/custom_form_field.dart';
import 'package:auto_share/authentication/validator.dart';
import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/general/utils.dart';
import 'package:ndialog/ndialog.dart';
import 'package:auto_share/general/widgets/snackbar_popup.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import 'package:auto_share/database/database_api.dart';
import 'package:auto_share/general/widgets/title_divider.dart';
import 'package:auto_share/general/widgets/text_field_row.dart';
import 'package:auto_share/database/models/user.dart';


class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {

  late DateTime? _birthDate;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();

  bool _isEditing = false;

  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _PhoneNumberFocusNode;
  late FocusNode _LicenseNumberFocusNode;

  String? _errorFirstName;
  String? _errorLastName;
  String? _errorPhoneNumber;
  String? _errorLicenseNumber;

  bool _isEditingFirstName = false;
  bool _isEditingLastName = false;
  bool _isEditingPhoneNumber = false;
  bool _isEditingLicenseNumber = false;


  @override
  void initState() {
    _birthDate = context.read<AuthenticationNotifier>().autoShareUser.birthDate;
    _firstNameController.text = context.read<AuthenticationNotifier>().autoShareUser.firstName;
    _lastNameController.text = context.read<AuthenticationNotifier>().autoShareUser.lastName;
    _emailController.text = context.read<AuthenticationNotifier>().autoShareUser.email;
    _phoneNumberController.text = context.read<AuthenticationNotifier>().autoShareUser.phone ?? '';
    _birthDateController.text = birthDateToString(_birthDate);
    _licenseNumberController.text = context.read<AuthenticationNotifier>().autoShareUser.licenseNumber?.toString() ?? '';


    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _PhoneNumberFocusNode = FocusNode();
    _LicenseNumberFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _birthDateController.dispose();
    _licenseNumberController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _PhoneNumberFocusNode.dispose();
    _LicenseNumberFocusNode.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          title: const Text('Personal Details'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(
                  thickness: 2,
                  color: Colors.transparent,
                ),
                TextFieldRow(
                  controller: _firstNameController,
                  hint: 'Your first name',
                  label: 'First name',
                  prefixIcon: const Icon(Icons.person, color: Palette.autoShareBlue,),
                  keyboardType: TextInputType.name,
                  validator: (value) => Validator.validateName(name: value),
                  fieldType: FieldType.firstName,
                ),
                TextFieldRow(
                  controller: _lastNameController,
                  hint: 'Your last name',
                  label: 'Last name',
                  prefixIcon: const Icon(Icons.person, color: Palette.autoShareBlue,),
                  keyboardType: TextInputType.name,
                  validator: (value) => Validator.validateName(name: value),
                  fieldType: FieldType.lastName,
                ),
                TextFieldRow(
                  controller: _emailController,
                  hint: 'Your email',
                  label: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined, color: Palette.autoShareBlue,),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => Validator.validateEmail(email: value),
                  fieldType: FieldType.email,
                  editable: false,
                ),
                TextFieldRow(
                  controller: _phoneNumberController,
                  hint: 'Your phone number',
                  label: 'Phone number',
                  prefixIcon: const Icon(Icons.phone, color: Palette.autoShareBlue,),
                  keyboardType: TextInputType.phone,
                  validator: (value) => Validator.validatePhoneNumber(phoneNumber: value),
                  fieldType: FieldType.phoneNumber,
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      flex: 12,
                      child: TextField(
                        enabled: false,
                        textAlignVertical: TextAlignVertical.bottom,
                        controller: _birthDateController,
                        autofocus: false,
                        decoration: const InputDecoration(
                          hintText: "Your birthday",
                          labelText: "Birthday",
                          prefixIcon: Icon(Icons.cake, color: Palette.autoShareBlue,),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 5,
                      child: Row(
                        children: <Widget>[
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Palette.autoShareDarkGrey,),
                            onPressed: () async {
                              // FocusScope.of(context).requestFocus(FocusNode());
                              final datePick = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1920),
                                  lastDate: DateTime.now()
                              );
                              if(datePick != null){
                                setState(() {
                                  _birthDateController.text = birthDateToString(datePick);
                                  _birthDateController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _birthDateController.text.length));
                                });
                                if(!mounted) return;
                                AutoShareUser currUser = context.read<AuthenticationNotifier>().autoShareUser;
                                await Database.createNewAutoShareUserDoc(
                                  id: currUser.id,
                                  firstName: currUser.firstName,
                                  lastName: currUser.lastName,
                                  email: currUser.email, //cannot update email
                                  phone: currUser.phone,
                                  birthDate: datePick,
                                  licenseNumber: currUser.licenseNumber,
                                  profilePicture: currUser.profilePicture,
                                );
                                if(!mounted) return;
                                context.read<AuthenticationNotifier>().autoShareUser = await Database.getAutoShareUserById(context.read<AuthenticationNotifier>().autoShareUser.id);
                                if(!mounted) return;
                                context.read<AuthenticationNotifier>().userDataBase!.loggedInAutoShareUser = context.read<AuthenticationNotifier>().autoShareUser;
                              }
                            } ,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TextFieldRow(
                  controller: _licenseNumberController,
                  hint: 'Your license number',
                  label: 'License number',
                  prefixIcon: const Icon(Icons.document_scanner, color: Palette.autoShareBlue,),
                  keyboardType: TextInputType.number,
                  validator: (value) => Validator.validateLicenseNumber(licenseNumber: value),
                  fieldType: FieldType.licenseNumber,
                ),
              ],
            ),
          ),
        )
    ),
    );
  }
}
