import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:pill_reminder/constants.dart';
import 'package:pill_reminder/main.dart';
import 'package:pill_reminder/models/errors.dart';
import 'package:pill_reminder/models/medicine.dart';
import 'package:pill_reminder/models/medicine_type.dart';
import 'package:pill_reminder/pages/home_page.dart';
import 'package:pill_reminder/pages/new_entry/new_entry_block.dart';
import 'package:sizer/sizer.dart';
import '../../common/convert_Time.dart';
import 'package:provider/provider.dart';

import '../../global_bloc.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage({super.key});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late TextEditingController nameController;
  late TextEditingController dosageController;

  late NewEntryBlock _newEntryBlock;
  late GlobalKey<ScaffoldState> _scaffoldKey;

  final StreamController<MedicineType> medicineStreamController =
      StreamController<MedicineType>.broadcast();
  MedicineType selectedMedicineType = MedicineType.bottle;

  @override
  void dispose() {
    super.dispose();
    medicineStreamController.close();
    nameController.dispose();
    dosageController.dispose();
    _newEntryBlock.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dosageController = TextEditingController();
    _newEntryBlock = NewEntryBlock();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void selectMedicineType(MedicineType type) {
    selectedMedicineType = type;
    medicineStreamController.add(type);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add New'),
      ),
      body: Provider<NewEntryBlock>.value(
        value: _newEntryBlock,
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PanelTitle(
                title: 'Medicine Name',
                isRequired: true,
              ),
              TextFormField(
                maxLength: 12,
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: kOtherColor),
              ),
              const PanelTitle(
                title: 'Dosage in mg',
                isRequired: false,
              ),
              TextFormField(
                maxLength: 12,
                controller: dosageController,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: kOtherColor),
              ),
              SizedBox(
                height: 2.h,
              ),
              const PanelTitle(title: "Medicine Type", isRequired: false),
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: StreamBuilder<MedicineType>(
                  stream: _newEntryBlock.selectedMedicineType,
                  initialData: selectedMedicineType,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MedicineTypeColumn(
                          medicineType: MedicineType.bottle,
                          name: 'Bottle',
                          iconValue: 'assets/icons/syrup.png',
                          isSelected: snapshot.data == MedicineType.bottle
                              ? true
                              : false,
                          onTap: () {},
                        ),
                        MedicineTypeColumn(
                          medicineType: MedicineType.syringe,
                          name: 'Syringe',
                          iconValue: 'assets/icons/syringe.png',
                          isSelected: snapshot.data == MedicineType.syringe
                              ? true
                              : false,
                          onTap: () {},
                        ),
                        MedicineTypeColumn(
                          medicineType: MedicineType.pill,
                          name: 'Pill',
                          iconValue: 'assets/icons/pill.png',
                          isSelected:
                              snapshot.data == MedicineType.pill ? true : false,
                          onTap: () {},
                        ),
                        MedicineTypeColumn(
                          medicineType: MedicineType.tablet,
                          name: 'Tablet',
                          iconValue: 'assets/icons/tablet_.png',
                          isSelected: snapshot.data == MedicineType.tablet
                              ? true
                              : false,
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
              ),
              const PanelTitle(title: 'Interval Selection', isRequired: true),
              const IntervalSelection(),
              const PanelTitle(title: 'Starting Time', isRequired: true),
              const SelectTime(),
              SizedBox(
                height: 2.h,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                  right: 8.w,
                ),
                child: SizedBox(
                  width: 80.h,
                  height: 8.h,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: const StadiumBorder(),
                    ),
                    child: Center(
                      child: Text(
                        "Confirm",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: kScaffoldColor,
                            ),
                      ),
                    ),
                    onPressed: () {
                      String? medicineName;
                      int? dosage;
                      //medicineName
                      if (nameController.text == "") {
                        _newEntryBlock.submitError(EntryError.nameNull);
                        return;
                      }
                      //dosage
                      if (nameController.text != "") {
                        medicineName = nameController.text;
                      }
                      if (dosageController.text == "") {
                        dosage = 0;
                      }
                      if (dosageController.text != "") {
                        dosage = int.parse(dosageController.text);
                      }
                      for (var medicine in globalBloc.medicineList$!.value) {
                        if (medicineName == medicine.medicineName) {
                          _newEntryBlock.submitError(EntryError.nameDuplidcate);
                          return;
                        }
                      }
                      if (_newEntryBlock.selectIntervals!.value == 0) {
                        _newEntryBlock.submitError(EntryError.interval);
                        return;
                      }
                      if (_newEntryBlock.selectedTimeOfDay$!.value == 'None') {
                        _newEntryBlock.submitError(EntryError.startTime);
                        return;
                      }

                      String medicineType = _newEntryBlock
                          .selectedMedicineType!.value
                          .toString()
                          .substring(13);

                      int interval = _newEntryBlock.selectIntervals!.value;
                      String startTime =
                          _newEntryBlock.selectedTimeOfDay$!.value;

                      List<int> intIDs =
                          makeIDs(24 / _newEntryBlock.selectIntervals!.value);
                      List<String> notificationIDs =
                          intIDs.map((i) => i.toString()).toList();

                      Medicine newEntryMedicine = Medicine(
                          notificationIDs: notificationIDs,
                          medicineName: medicineName,
                          dosage: dosage,
                          medicineType: medicineType,
                          interval: interval,
                          startTime: startTime);

                      globalBloc.updateMedicineList(newEntryMedicine);

                      //schedule notification

                      //go to sccess screen
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<int> makeIDs(double n) {
    var rng = Random();
    List<int> ids = [];
    for (int i = 0; i < n; i++) {
      ids.add(rng.nextInt(10000000000000));
    }
    return ids;
  }
}

class SelectTime extends StatefulWidget {
  const SelectTime({super.key});

  @override
  State<SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 00);
  bool _clicked = false;

  Future<TimeOfDay> _selectTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _time);

    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _clicked = true;

        //update state via provider. I will do later.
      });
    }
    return picked!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.h,
      child: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: kPrimaryColor, shape: const StadiumBorder()),
          onPressed: () {
            _selectTime();
          },
          child: Center(
            child: Text(
              _clicked == false
                  ? "Select Time"
                  : "${convertTime(_time.hour.toString())}:${convertTime(_time.minute.toString())}",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: kScaffoldColor),
            ),
          ),
        ),
      ),
    );
  }
}

class IntervalSelection extends StatefulWidget {
  const IntervalSelection({super.key});

  @override
  State<IntervalSelection> createState() => _IntervalSelectionState();
}

class _IntervalSelectionState extends State<IntervalSelection> {
  final _intervals = [6, 8, 12, 24];
  var _selected = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Remind me every',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: kTextColor,
                ),
          ),
          DropdownButton(
            iconEnabledColor: kOtherColor,
            dropdownColor: kScaffoldColor,
            itemHeight: 8.h,
            hint: _selected == 0
                ? Text(
                    'Select an Interval',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kPrimaryColor,
                        ),
                  )
                : null,
            elevation: 4,
            value: _selected == 0 ? null : _selected,
            items: _intervals.map(
              (int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kSecondaryColor,
                        ),
                  ),
                );
              },
            ).toList(),
            onChanged: (newVal) {
              setState(
                () {
                  _selected = newVal!;
                },
              );
            },
          ),
          Text(
            _selected == 1 ? " hour" : " hours",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: kTextColor,
                ),
          ),
        ],
      ),
    );
  }
}

class MedicineTypeColumn extends StatelessWidget {
  const MedicineTypeColumn({
    super.key,
    required this.medicineType,
    required this.name,
    required this.iconValue,
    required this.isSelected,
    required this.onTap,
  });

  final MedicineType medicineType;
  final String name;
  final String iconValue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final NewEntryBlock newEntryBlock = Provider.of<NewEntryBlock>(context);
    return GestureDetector(
      onTap: () {
        //select medicine type
        newEntryBlock.updateSelectedMedicine(medicineType);
      },
      child: Column(
        children: [
          Container(
            width: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.h),
              color: isSelected ? kOtherColor : Colors.white,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 1.h, bottom: 1.h),
                child: Image.asset(
                  iconValue,
                  height: 7.h,
                  color: isSelected ? Colors.white : kOtherColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Container(
              width: 20.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected ? kOtherColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: isSelected ? Colors.white : kOtherColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanelTitle extends StatelessWidget {
  const PanelTitle({super.key, required this.title, required this.isRequired});

  final String title;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: title,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            TextSpan(
              text: isRequired ? " *" : "",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: kPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
