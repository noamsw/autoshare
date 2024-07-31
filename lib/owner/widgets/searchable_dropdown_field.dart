import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:developer' as developer;

class SearchableDropDown extends StatefulWidget {
  final String hint;
  final String label;
  final String? initialValue;
  final Function(String?) onChanged;
  final List<String> items;
  final bool isSearchable;
  final String? searchHint;
  final String? Function(String?)? validator;

  const SearchableDropDown(
      {Key? key,
      required this.hint,
      required this.label,
      this.initialValue,
      required this.items,
      required this.onChanged,
      this.isSearchable = true,
      this.searchHint,
      this.validator})
      : super(key: key);

  @override
  State<SearchableDropDown> createState() => _SearchableDropDownState();
}

class _SearchableDropDownState extends State<SearchableDropDown> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField2<String>(
        value: widget.initialValue,
        style: const TextStyle(
          fontSize: 15.5,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          fillColor: Colors.white,
          filled: true,
          labelText: widget.label,
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
        buttonDecoration: const BoxDecoration(
        ),
        validator: widget.validator ?? (String? value) => null,
        onMenuStateChange: (bool isOpen) {
          if (isOpen) {
            _searchController.clear();
          }
        },
        hint: Text(
          widget.hint,
          style: TextStyle(
            fontSize: 15.5,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: widget.items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        onChanged: widget.onChanged,
        dropdownMaxHeight: 300,
        searchController: _searchController,
        searchInnerWidget: widget.isSearchable
            ? Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: 'Search for make...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
