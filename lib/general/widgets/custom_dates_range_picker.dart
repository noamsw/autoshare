
import 'dart:developer' as developer;
import 'package:auto_share/general/widgets/list_item_template.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:date_format/date_format.dart';
import 'package:time_picker_widget/time_picker_widget.dart';
import 'package:auto_share/general/utils.dart';
import 'dart:math';


class DatesRangePickerBody extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function (DateTime) setStartDate;
  final Function (DateTime) setEndDate;
  final DateTime? maxDate;
  final DateRangePickerSelectionMode selectionMode;
  final String title;
  final Future<String> Function(DateTime, DateTime)? onConfirmRange;
  final Future<String> Function(DateTime)? onConfirmSingle;

  const DatesRangePickerBody(
      {
        Key? key,
        required this.initialStartDate,
        required this.initialEndDate,
        required this.setStartDate,
        required this.setEndDate,
        this.maxDate,
        this.selectionMode = DateRangePickerSelectionMode.range,
        this.onConfirmRange,
        this.onConfirmSingle,
        this.title = 'Pickup and return'
      })
      : super(key: key);

  @override
  State<DatesRangePickerBody> createState() => _DatesRangePickerBodyState();
}

class _DatesRangePickerBodyState extends State<DatesRangePickerBody> {

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _rangePicked = true;
  bool _singlePicked = false;

  final dateFormat = [M, ' ', d];
  final dayTimeFormat = [ H, ':', nn];

  late DateTime minDateRange;
  late DateTime minDateSingle;

  @override
  initState() {
    minDateRange = DateTime.now().isBefore(widget.initialStartDate) ? DateTime.now() : widget.initialStartDate;
    minDateSingle = DateTime.now().add(const Duration(hours: 2));
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SfDateRangePicker(
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (widget.selectionMode == DateRangePickerSelectionMode.range){
                var range = args.value as PickerDateRange;
                setState(() {
                  _rangePicked = (range.endDate != null);
                });
                if (_rangePicked) {
                  setState(() {
                    _startDate = range.startDate ?? _startDate;
                    int pickupHour = _startDate.isAtSameDayAs(DateTime.now())
                        ? max(DateTime
                        .now()
                        .hour + 1, 8)
                        : 8;
                    _startDate = DateTime(
                        _startDate.year, _startDate.month, _startDate.day,
                        pickupHour, 0, 0);
                    _endDate = range.endDate ?? _endDate;
                    int returnHour = _startDate.isAtSameDayAs(_endDate) ? max(
                        _startDate.hour + 1, 17) : 8;

                    _endDate = DateTime(
                        _endDate.year, _endDate.month, _endDate.day, returnHour,
                        0, 0);
                  });
                }
              }
              else if (widget.selectionMode == DateRangePickerSelectionMode.single){
                _singlePicked = true;
                var pickedEndDate = args.value as DateTime;
                setState(() {
                  _endDate = pickedEndDate;
                  int returnHour = 8;
                  if (widget.maxDate!.isAtSameDayAs(_endDate)){
                    returnHour = min(widget.maxDate!.hour - 1, 17);
                  }
                  if(DateTime.now().isAtSameDayAs(_endDate)){
                    returnHour = min(DateTime.now().hour + 3, 24);
                  }
                  _endDate = DateTime(
                      _endDate.year, _endDate.month, _endDate.day, returnHour,
                      0, 0);
              });
              }
            },
            minDate: widget.selectionMode == DateRangePickerSelectionMode.range ? minDateRange : minDateSingle,
            maxDate: widget.maxDate,
            selectionMode: widget.selectionMode,
            initialSelectedRange: PickerDateRange(_startDate, _endDate),
            initialDisplayDate: widget.selectionMode == DateRangePickerSelectionMode.range ? _startDate : _endDate,
          ),
          // if(_rangePicked) const SizedBox(height: 30),
          if(_rangePicked || widget.selectionMode == DateRangePickerSelectionMode.single) const Text(
            'What time suits you?',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          if(_rangePicked || widget.selectionMode == DateRangePickerSelectionMode.single) const SizedBox(height: 30),
          widget.selectionMode == DateRangePickerSelectionMode.range ? (_rangePicked ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                  children: [
                    const Text(
                      "Pickup",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text("   ${formatDate(_startDate, dateFormat)}",
                        style: const TextStyle(fontSize: 15)),
                  ],
                ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => showCustomTimePicker(
                      selectableTimePredicate: (time) {
                        bool exceedNow = false, exceedReturn = false;
                        if(_startDate.isAtSameDayAs(DateTime.now())) {
                          exceedNow = time!.hour <= DateTime.now().hour;
                        }
                        if(_startDate.isAtSameDayAs(_endDate)) {
                          exceedReturn = time!.hour >= _endDate.hour;
                        }
                        if (exceedNow || exceedReturn){
                          return false;
                        }
                        return true;
                      },
                      onFailValidation: (context) => const Text('Unavailable'),
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startDate),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          _startDate = DateTime(
                              _startDate.year,
                              _startDate.month,
                              _startDate.day,
                              value.hour,
                              value.minute);
                        });
                      }
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.timer, color: Colors.grey),
                              Text(formatDate(_startDate, dayTimeFormat)),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Return",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text("   ${formatDate(_endDate, dateFormat)}",
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async => await showCustomTimePicker(
                      selectableTimePredicate: (time) {
                        if(_startDate.isAtSameDayAs(_endDate)) {
                          return time!.hour >= _startDate.hour + 1;
                        }
                        if(_endDate.isAtSameDayAs(DateTime.now())) {
                          return time!.hour >= DateTime.now().hour;
                        }
                        return true;
                      },
                      onFailValidation: (context) => const Text('Unavailable'),
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_endDate),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          DateTime tempEndDate = DateTime(
                              _endDate.year,
                              _endDate.month,
                              _endDate.day,
                              value.hour,
                              value.minute);
                          if(tempEndDate.isBefore(_startDate)) {
                            tempEndDate = _startDate.add(const Duration(hours: 1));
                          }
                          _endDate = tempEndDate;
                        });
                      }
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.timer, color: Colors.grey),
                              Text(formatDate(_endDate, dayTimeFormat)),
                            ],
                          )),
                    ),
                  ),

                ],
              ),
            ],
          ) : const SizedBox.shrink()) : Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text(
                      "Return",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text("   ${formatDate(_endDate, dateFormat)}",
                        style: const TextStyle(fontSize: 15)),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () async => await showCustomTimePicker(
                        selectableTimePredicate: (time) {
                          developer.log("time: ${time}");
                          developer.log("_endDate: $_endDate");
                          if(_endDate.isAtSameDayAs(widget.maxDate!)) {
                            return widget.maxDate!.hour > time!.hour;
                          }
                          if(_endDate.isAtSameDayAs(DateTime.now())) {
                            return time!.hour > DateTime.now().hour + 2;
                          }
                          return true;
                        },
                        onFailValidation: (context) => const Text('Unavailable'),
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_endDate),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            DateTime tempEndDate = DateTime(
                                _endDate.year,
                                _endDate.month,
                                _endDate.day,
                                value.hour,
                                value.minute);
                            if(tempEndDate.isBefore(DateTime.now())) {
                              tempEndDate = DateTime.now().add(const Duration(hours: 1));
                            }
                            _endDate = tempEndDate;
                          });
                        }
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                const Icon(Icons.timer, color: Colors.grey),
                                Text(formatDate(_endDate, dayTimeFormat)),
                              ],
                            )),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

              ],
            ),
          ),
          const SizedBox(height: 25),
          widget.selectionMode == DateRangePickerSelectionMode.range ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _rangePicked? () async {
                    if(_endDate.difference(_startDate).inHours < 1){
                      showAlertDialogue(context, "minimum 1 hour required");
                      return;
                    }
                    if (widget.onConfirmRange != null) {
                      var msg = await widget.onConfirmRange!(_startDate, _endDate);
                      if(msg == "success") {
                        widget.setStartDate(_startDate);
                        widget.setEndDate(_endDate);
                        Navigator.pop(context);
                      }
                      else {
                        showDialog(context: context, builder: (context) => AlertDialog(
                          title: const Text("Error"),
                          content: Text(msg),
                        ));
                      }
                    }
                    else{
                      widget.setStartDate(_startDate);
                      widget.setEndDate(_endDate);
                      Navigator.pop(context);
                    }

                  }
                  : null,
                  child: const Text('Confirm')
                ),
              ),
            )]
          ) : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: _singlePicked? () async {
                        if (widget.onConfirmSingle != null) {
                          var msg = await widget.onConfirmSingle!(_endDate);
                          if(msg == "success") {
                            widget.setStartDate(_endDate);
                            widget.setEndDate(_endDate);
                            Navigator.pop(context);
                          }
                          else {
                            showDialog(context: context, builder: (context) => AlertDialog(
                              title: const Text("Error"),
                              content: Text(msg),
                            ));
                          }
                        }
                        else{
                          widget.setStartDate(_endDate);
                          widget.setEndDate(_endDate);
                          Navigator.pop(context);
                        }
                      }
                          : null,
                      child: const Text('Confirm')
                  ),
                ),
              )]
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}


Future<PickerDateRange> customDatesRangePicker(
    BuildContext context,
    {
      DateTime? initialStartDate,
      DateTime? initialEndDate,
      DateTime? maxDate,
      DateRangePickerSelectionMode selectionMode = DateRangePickerSelectionMode.range,
      String title = 'Pickup and return',
      Future<String> Function(DateTime, DateTime)? onConfirmRange,
      Future<String> Function(DateTime)? onConfirmSingle
    }) async {
  DateTime startDate = initialStartDate ?? DateTime.now().add(Duration(minutes: 60- DateTime.now().minute));
  DateTime endDate =
      initialEndDate ?? initialStartDate!.add(const Duration(days: 1));

  setStartDate(DateTime date) {
    startDate = date;
  }
  setEndDate(DateTime date) {
    endDate = date;
  }

  await showMaterialModalBottomSheet(
    enableDrag: false,
    context: context,
    builder: (context) {
      return DatesRangePickerBody(
        initialStartDate: startDate,
        initialEndDate: endDate,
        setStartDate: setStartDate,
        setEndDate: setEndDate,
        maxDate: maxDate,
        onConfirmRange: onConfirmRange,
        onConfirmSingle: onConfirmSingle,
        selectionMode: selectionMode,
        title: title,
      );
    },
  );

  return PickerDateRange(startDate, endDate);
}


Future<PickerDateRange> fullCustomDatesRangePicker(BuildContext context,
    {DateTime? initialStartDate, DateTime? initialEndDate}) async {
  DateTime startDate = initialStartDate ?? DateTime.now().add(Duration(minutes: 60- DateTime.now().minute));
  DateTime endDate =
      initialEndDate ?? initialStartDate!.add(const Duration(days: 1));

  setStartDate(DateTime date) {
    startDate = date;
  }
  setEndDate(DateTime date) {
    endDate = date;
  }

  await showBarModalBottomSheet(
    enableDrag: true,
    context: context,
    builder: (context) {
      return SizedBox(
        height: (MediaQuery.of(context).size.height),
        child: DatesRangePickerBody(
          initialStartDate: startDate,
          initialEndDate: endDate,
          setStartDate: setStartDate,
          setEndDate: setEndDate,
        ),
      );
    },
  );

  return PickerDateRange(startDate, endDate);
}