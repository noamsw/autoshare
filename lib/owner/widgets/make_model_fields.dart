import 'package:flutter/material.dart';
import 'package:auto_share/owner/widgets/searchable_dropdown_field.dart';
import 'dart:developer' as developer;
import 'package:dropdown_button2/dropdown_button2.dart';

class MakeModelFormFields extends StatefulWidget {
  const MakeModelFormFields({Key? key, this.make, this.model, required this.onMakeChanged, required this.onModelChanged, required this.makeModelList}) : super(key: key);
  final String? make;
  final String? model;
  final Function(String?) onMakeChanged;
  final Function(String?) onModelChanged;
  final Map<String,dynamic> makeModelList;

  @override
  State<MakeModelFormFields> createState() => _MakeModelFormFieldsState();
}

class _MakeModelFormFieldsState extends State<MakeModelFormFields> {

  String? _selectedMake;
  String? _selectedModel;

  @override
  void initState() {
    _selectedMake = widget.make;
    _selectedModel = widget.model;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    developer.log("make_model_fields.dart: build() called");
    List<dynamic> modelList = widget.makeModelList?[_selectedMake]??[];
    String? firstModel = modelList.isNotEmpty? modelList.first : null;
    return Column(
      children: [
        SearchableDropDown(
          initialValue: widget.make,
          label: 'car make',
          hint: 'Select Make',
          items: widget.makeModelList.keys.map((value) => value.toString()).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMake = value??'Select make';
              widget.onMakeChanged(value);
              _selectedModel = null;
              modelList = widget.makeModelList?[_selectedMake]??[];
              widget.onModelChanged(modelList.isNotEmpty?modelList.first.toString():null);
              modelList = [];
            });
          },
          searchHint: 'Select make',
          validator: (value) {
            if (value==null || value.isEmpty) {
              return "Please enter car make";
            }
            return null;
          }
        ),
        const Divider(thickness: 2, color: Colors.transparent,),
        SearchableDropDown(
          label: 'car model',
          initialValue: _selectedModel??firstModel,
          hint: 'Select Model',
          items: modelList.map((value) => value.toString()).toList(),
          onChanged: (value) {
            setState(() {
              _selectedModel = value;
              widget.onModelChanged(value);
            });
          },
          searchHint: 'Select model',
          validator: (value) {
            if (value==null || value.isEmpty) {
              return "Please enter car model";
            }
            return null;
          }
        ),
      ],
    );
  }
}
