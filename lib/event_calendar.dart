import 'dart:convert';
import 'dart:developer';

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:event_calender_app/event_model.dart';
import 'package:event_calender_app/notification_service.dart';
import 'package:event_calender_app/testin_app.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  List<Event> allData = [];

  final now = DateTime.now();
  int notificationIndex = 0;
  NotificationService notificationService = NotificationService();
  TextEditingController updateTitleController = TextEditingController();
  TextEditingController updateDescController = TextEditingController();
  TextEditingController updateTimeController = TextEditingController();
  bool showTooltip = false;
  TimeOfDay? pickedTime;
  TimeOfDay? updatePikedTime;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();
  final timeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDate = _focusedDay;
    // AndroidAlarmManager.initialize();
    super.initState();
    notificationService;
    notificationService.androidIntializeNotification();
    loadPreviousEvents();
  }

  loadPreviousEvents() {
    mySelectedEvents = {
      "2022-09-13": [
        {"eventDescp": "11", "eventTitle": "111", "time": "5:00 AM"},
        {"eventDescp": "22", "eventTitle": "22", "time": "6:00 AM"}
      ],
      "2022-09-30": [
        {"eventDescp": "22", "eventTitle": "22", "time": "8:00 AM"}
      ],
      "2022-09-20": [
        {"eventTitle": "ss", "eventDescp": "ss", "time": "10:00 PM"}
      ]
    };
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

// dialoge to add new event
  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text(
            'Add New Event',
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descpController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller:
                    timeController, //editing controller of this TextField
                decoration: const InputDecoration(
                    icon: Icon(Icons.timer), //icon of text field
                    labelText: "Enter Time" //label text of field
                    ),
                readOnly:
                    true, //set it true, so that user will not able to edit text
                onTap: () async {
                  pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    initialEntryMode: TimePickerEntryMode.inputOnly,
                    context: context,
                  );

                  if (pickedTime != null) {
                    // print(pickedTime!.format(context)); //output 10:51 PM

                    // if (pickedTime ==
                    //     mySelectedEvents[
                    //         DateFormat('yyyy-MM-dd').format(_selectedDate!)]) {
                    //   print("time picked error");
                    // } else {}
                    setState(() {
                      timeController.text = pickedTime!
                          .format(context); //set the value of text field.
                    });
                  } else {
                    print("Time is not selected");
                  }
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
                child: const Text('Add Event'),
                onPressed: () {
                  if (titleController.text.isEmpty &&
                      descpController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Required title and description'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    //Navigator.pop(context);
                    return;
                  }
                  // todo for time collapse

                  else if ((mySelectedEvents[DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!)] !=
                          null) &&
                      (mySelectedEvents[
                              DateFormat('yyyy-MM-dd').format(_selectedDate!)]!
                          .any((element) =>
                              element['time'] ==
                              timeController.text.toString()))) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            " you are trying to add other event on same time")));
                    titleController.clear();
                    descpController.clear();
                    timeController.clear();

                    Navigator.pop(context);
                    setState(() {});
                    log("Time Collapse");
                  } else {
                    setState(() {
                      if (mySelectedEvents[DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!)] !=
                          null) {
                        mySelectedEvents[
                                DateFormat('yyyy-MM-dd').format(_selectedDate!)]
                            ?.add({
                          "eventTitle": titleController.text,
                          "eventDescp": descpController.text,
                          "time": timeController.text
                        });

                        notificationIndex = mySelectedEvents[
                                DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!)]!
                            .indexWhere((element) =>
                                element['time'] == timeController.text);

                        allData.add(Event(
                            eventTitle: titleController.text,
                            eventDescp: descpController.text,
                            time: timeController.text));
                      } else {
                        mySelectedEvents[
                            DateFormat('yyyy-MM-dd').format(_selectedDate!)] = [
                          {
                            "eventTitle": titleController.text,
                            "eventDescp": descpController.text,
                            "time": timeController.text
                          }
                        ];
                      }
                    });
                    notificationService.sendSheduleNotification(
                        notificationIndex,
                        DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            pickedTime!.hour,
                            pickedTime!.minute),
                        titleController.text,
                        descpController.text);
                    print(
                        "New Event for backend developer ${json.encode(mySelectedEvents)}");
                    titleController.clear();
                    descpController.clear();
                    timeController.clear();
                    Navigator.pop(context);
                    return;
                  }
                }),
          ]),
    );
  }

  var key;
  var value;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        // centerTitle: true,
        title: const Text('Event Calendar App'),
        actions: [
          IconButton(
              onPressed: () {
                print(allData);

                mySelectedEvents.forEach((key, value) {
                  print("----------");
                  print(value.runtimeType);
                  print("------------------");
                  print(key);
                  value[0];
                });

                // showDialog(
                //     context: context,
                //     builder: (context) {
                //       return Scaffold(
                //         body: ListView.builder(
                //             itemCount: allData.length,
                //             itemBuilder: (context, index) {
                //               return Padding(
                //                 padding: const EdgeInsets.all(8.0),
                //                 child: Container(
                //                   color: Colors.purple.shade200,
                //                   child: ListTile(
                //                     // leading: Text(mySelectedEvents[
                //                     //         DateFormat('yyyy-MM-dd')
                //                     //             .format(_selectedDate!)]
                //                     //     .toString()),
                //                     title: Text(
                //                         allData[index].eventTitle.toString()),
                //                     subtitle: Text(
                //                         allData[index].eventDescp.toString()),
                //                     trailing:
                //                         Text(allData[index].time.toString()),
                //                   ),
                //                 ),
                //               );
                //             }),
                //       );
                //     });

                // if (_selectedDate!.month == 1) {
                //   print("month 1 no event add");
                // } else if (_selectedDate!.month == 2) {
                //   print("month 2 no event add");
                // } else if (_selectedDate!.month == 3) {
                //   print("month 3 no event add");
                // } else if (_selectedDate!.month == 4) {
                //   print("month 4 no event add");
                // } else if (_selectedDate!.month == 5) {
                //   print(_selectedDate!.month);
                // } else if (_selectedDate!.month == 6) {
                //   print("month 6 no event add");
                // } else if (_selectedDate!.month == 7) {
                //   print("month 7 no event add");
                // } else if (_selectedDate!.month == 8) {
                //   print("month 8 no event add");
                // } else if (key <=
                //     DateTime(2022, 09, 01).compareTo(DateTime(2022, 09, 30))) {
                //   mySelectedEvents.forEach((key, value) {
                //     setState(() {
                //       key ==
                //           mySelectedEvents[
                //               DateFormat('YYYY-MM-DD').format(_selectedDate!)];

                //       print(key);
                //       value ==
                //           value
                //               .every((element) =>
                //                   element['eventTitle'] == 'eventTitle')
                //               .toString();
                //       print(value);
                //     });
                //   });
                // } else if (_selectedDate!.month == 10) {
                //   // print("month 10 no event add");
                //   mySelectedEvents.forEach((key, value) {
                //     setState(() {
                //       key ==
                //           mySelectedEvents[
                //               DateFormat('yyyy-MM-dd').format(_selectedDate!)];

                //       print(key);
                //       value ==
                //           value
                //               .every((element) =>
                //                   element['eventTitle'] == 'eventTitle')
                //               .toString();
                //       print(value);
                //     });
                //   });
                // } else if (_selectedDate!.month == 11) {
                //   print("month 11 no event add");
                // } else if (_selectedDate!.month == 12) {
                //   print("month 12 no event add");
                // } else {
                //   return;
                // }

                // showDialog(
                //     context: context,
                //     builder: (context) {
                //       return Scaffold(
                //         body: Column(
                //           children: [
                //             ListView.builder(
                //                 itemCount: mySelectedEvents.length,
                //                 itemBuilder: (context, index) {
                //                   return Column(
                //                     children: [
                //                       Text(key[index].toString()),
                //                       Text(value[index].toString())
                //                     ],
                //                   );
                //                 }),
                //           ],
                //         ),
                //       );
                //     });
              },
              icon: Icon(Icons.view_day_outlined)),
          SizedBox(
            width: 8,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                // color: Colors.black,
                child: TableCalendar(
                  // holidayPredicate: true,
                  headerVisible: true,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  headerStyle: HeaderStyle(
                    headerMargin: const EdgeInsets.only(bottom: 10),
                    titleTextStyle: const TextStyle(color: Colors.white),
                    decoration: const BoxDecoration(color: Colors.orange),
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: const TextStyle(color: Colors.black),
                    formatButtonShowsNext: false,
                  ),
                  calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: Colors.orange),
                      selectedDecoration: BoxDecoration(color: Colors.black),
                      markerDecoration: BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle)),

                  firstDay: DateTime(2022),
                  lastDay: DateTime(2023),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,

                  // calendarStyle: CalendarStyle(),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDate, selectedDay)) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDate, day);
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      // Call `setState()` when updating calendar format
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    // No need to call `setState()` here
                    _focusedDay = focusedDay;
                  },
                  eventLoader: _listOfDayEvents,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: dayPredicted(_selectedDate!, DateTime.now()),
                ),
              ),
              // TODO defult set list for calender
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
            maxChildSize: 1,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: ListView(
                  controller: controller,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                          child: Text(
                        "Events",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      )),
                    ),
                    IconButton(
                        onPressed: () {
                          print(mySelectedEvents.runtimeType);

                          // print(loadPreviousEvents);
                          //  print(mySelectedEvents);
                        },
                        icon: Icon(Icons.show_chart)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          mySelectedEvents[DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!)] ==
                                  null
                              ? const Text(
                                  "no event added yet",
                                  style: TextStyle(fontSize: 16),
                                )
                              : mySelectedEvents[DateFormat('yyyy-MM-dd')
                                              .format(_selectedDate!)]!
                                          .length ==
                                      1
                                  ? const Text(" only one event add",
                                      style: TextStyle(fontSize: 16))
                                  : Text(
                                      " ${mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)]!.length} events add",
                                      style: const TextStyle(fontSize: 16)),
                          const Spacer(),
                          CircleAvatar(
                              child: IconButton(
                                  onPressed: () {
                                    // TODO for show box to add event

                                    _showAddEventDialog();
                                  },
                                  icon: Icon(Icons.add)))
                        ],
                      ),
                    )
                    // Center(
                    //     child: mySelectedEvents[DateFormat('yyyy-MM-dd')
                    //         .format(_selectedDate!)] ==
                    //         null
                    //         ? Text("no event added yet",style: TextStyle(fontSize: 16),)
                    //         :
                    //     SimpleTooltip(
                    //         backgroundColor: Colors.black12,
                    //         borderColor: Colors.black,
                    //         ballonPadding: EdgeInsets.zero,
                    //         minimumOutSidePadding: 16,
                    //         // targetCenter: Offset(-5,-6),
                    //         tooltipTap: () {
                    //           setState(() {});
                    //
                    //         },
                    //         animationDuration: Duration(seconds: 1),
                    //         show: showTooltip,
                    //         tooltipDirection: TooltipDirection.up,
                    //         targetCenter: Offset(-5,-8),
                    //         child: InkWell(
                    //             onTap: () {
                    //               setState(() {
                    //                 showTooltip = !showTooltip;
                    //               });
                    //             },
                    //             child: Align(
                    //               alignment: Alignment.bottomCenter,
                    //               child: mySelectedEvents[DateFormat('yyyy-MM-dd')
                    //                   .format(_selectedDate!)]!
                    //                   .length ==
                    //                   1
                    //                   ? Text(" only one event add",style: TextStyle(fontSize: 16))
                    //                   : Text(
                    //                   " ${mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)]!.length} events add",style: TextStyle(fontSize: 16)),
                    //             )),
                    //
                    //         content: SizedBox(
                    //           height: 180,
                    //           child: Scaffold(
                    //             backgroundColor: Colors.transparent,
                    //             body: SingleChildScrollView(
                    //               child: Column(
                    //                 children: [
                    //                   ..._listOfDayEvents(_selectedDate!).map(
                    //                         (myEvents) => Padding(
                    //                       padding:
                    //                       const EdgeInsets.only(bottom: 12.0),
                    //                       child: Container(
                    //                         // margin: const EdgeInsets.all(8),
                    //                           decoration: BoxDecoration(
                    //                               border: Border.all(),
                    //                               borderRadius:
                    //                               BorderRadius.circular(10)),
                    //                           child: Padding(
                    //                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //                             child: Row(
                    //                               children: [
                    //                                 const Icon(
                    //                                   Icons.done,
                    //                                   color: Colors.teal,
                    //                                 ),
                    //                                 Text(
                    //                                     '${myEvents['eventTitle']}'),
                    //                                 Spacer(),
                    //                                 InkWell(onTap: (){
                    //
                    //                                   var newList = mySelectedEvents[
                    //                                   DateFormat('yyyy-MM-dd')
                    //                                       .format(_selectedDate!)]!;
                    //
                    //
                    //
                    //                                   newList.forEach((element) {
                    //                                     element = myEvents['eventTitle'];
                    //                                     setState(() {
                    //                                       showTooltip=false;
                    //                                     });
                    //                                     showDialog(
                    //                                       // barrierDismissible: false,
                    //                                         context: context,
                    //                                         builder: (context) {
                    //                                           //TODO alerDialogeBOx
                    //                                           return AlertDialog(
                    //                                             elevation: 0,
                    //                                             content: Column(
                    //                                               mainAxisSize: MainAxisSize.min,
                    //                                               children: [
                    //                                                 Text(element),
                    //                                                 TextFormField(
                    //                                                   controller:
                    //                                                   updateTitleController,
                    //                                                   decoration: InputDecoration(
                    //                                                       hintText: "title"),
                    //                                                 ),
                    //                                                 TextFormField(
                    //                                                   controller:
                    //                                                   updateDescController,
                    //                                                   decoration: InputDecoration(
                    //                                                       hintText: "descr"),
                    //                                                 )
                    //                                               ],
                    //                                             ),
                    //                                             actions: [
                    //                                               TextButton(
                    //                                                   onPressed: () {
                    //                                                     Navigator.pop(context);
                    //                                                     // Navigator.push(context, MaterialPageRoute(builder: (_)=>EventCalendarScreen()));
                    //
                    //                                                     // Navigator.push(context, MaterialPageRoute(builder: (_)=>EventCalendarScreen()));
                    //                                                   },
                    //                                                   child: Text("cancel")),
                    //                                               ElevatedButton(
                    //                                                   onPressed: () {
                    //                                                     myEvents['eventTitle'] =
                    //                                                         updateTitleController
                    //                                                             .text;
                    //                                                     // print(element);
                    //                                                     updateTitleController
                    //                                                         .clear();
                    //                                                     setState(() {});
                    //                                                     Navigator.pop(context);
                    //                                                   },
                    //                                                   child: Text("update"))
                    //                                             ],
                    //                                           );
                    //                                         });
                    //                                   });
                    //                                   // Navigator.pop(context);
                    //                                   // Navigator.pop(context);
                    //
                    //
                    //                                 },child: Icon(Icons.edit),),
                    //                                 InkWell(onTap: (){
                    //
                    //                                   mySelectedEvents[DateFormat('yyyy-MM-dd')
                    //                                       .format(_selectedDate!)]!
                    //                                       .removeLast();
                    //
                    //
                    //                                   setState(() {});
                    //
                    //                                   print(mySelectedEvents);
                    //
                    //
                    //                                 },child: Icon(Icons.delete),)
                    //                               ],
                    //                             ),
                    //                           )),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ))
                    //
                    // )

                    ,
                    Column(children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ..._listOfDayEvents(_selectedDate!).map(
                              (myEvents) => Padding(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.black26,
                                      // border: Border.all(),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    onTap: () {},
                                    leading: const Icon(
                                      Icons.done,
                                      color: Colors.purple,
                                    ),
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        '${myEvents['eventTitle']}',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    subtitle: Text('${myEvents['eventDescp']}',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        )),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(myEvents['time'].toString()),
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    //TODO alerDialogeBOx
                                                    return AlertDialog(
                                                      elevation: 0,
                                                      title:
                                                          Text("Update Event"),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextFormField(
                                                            controller:
                                                                updateTitleController,
                                                            decoration:
                                                                InputDecoration(
                                                                    hintText:
                                                                        "title"),
                                                          ),
                                                          TextFormField(
                                                            controller:
                                                                updateDescController,
                                                            decoration:
                                                                const InputDecoration(
                                                                    hintText:
                                                                        "descr"),
                                                          ),
                                                          TextFormField(
                                                            controller:
                                                                updateTimeController, //editing controller of this TextField
                                                            decoration:
                                                                const InputDecoration(
                                                                    icon: Icon(Icons
                                                                        .timer), //icon of text field
                                                                    labelText:
                                                                        "Enter Time" //label text of field
                                                                    ),
                                                            readOnly:
                                                                true, //set it true, so that user will not able to edit text
                                                            onTap: () async {
                                                              updatePikedTime =
                                                                  await showTimePicker(
                                                                initialTime:
                                                                    TimeOfDay
                                                                        .now(),
                                                                initialEntryMode:
                                                                    TimePickerEntryMode
                                                                        .inputOnly,
                                                                context:
                                                                    context,
                                                              );

                                                              if (updatePikedTime !=
                                                                  null) {
                                                                // print(pickedTime!.format(context)); //output 10:51 PM

                                                                setState(() {
                                                                  updateTimeController
                                                                          .text =
                                                                      updatePikedTime!
                                                                          .format(
                                                                              context); //set the value of text field.
                                                                });
                                                              } else {
                                                                print(
                                                                    "Time is not selected");
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text("cancel")),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                myEvents[
                                                                        'eventTitle'] =
                                                                    updateTitleController
                                                                        .text;
                                                                myEvents[
                                                                        'eventDescp'] =
                                                                    updateDescController
                                                                        .text;
                                                                myEvents[
                                                                        'time'] =
                                                                    updateTimeController
                                                                        .text;
                                                                updateTimeController
                                                                    .clear();
                                                                updateTitleController
                                                                    .clear();
                                                                updateDescController
                                                                    .clear();

                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                              notificationService.sendSheduleNotification(
                                                                  notificationIndex,
                                                                  DateTime(
                                                                      _selectedDate!
                                                                          .year,
                                                                      _selectedDate!
                                                                          .month,
                                                                      _selectedDate!
                                                                          .day,
                                                                      updatePikedTime!
                                                                          .hour,
                                                                      updatePikedTime!
                                                                          .minute),
                                                                  updateTitleController
                                                                      .text,
                                                                  updateDescController
                                                                      .text);
                                                            },
                                                            child: const Text(
                                                                "update"))
                                                      ],
                                                    );
                                                  });

                                              // Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.edit,
                                                color: Colors.white70)),
                                        IconButton(
                                            onPressed: () {
                                              mySelectedEvents[DateFormat(
                                                          'yyyy-MM-dd')
                                                      .format(_selectedDate!)]!
                                                  .removeWhere((element) =>
                                                      element['eventTitle'] ==
                                                      myEvents['eventTitle']);
                                              notificationService
                                                  .cancelNotification(
                                                      notificationIndex);
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.delete,
                                                color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  dayPredicted(DateTime _selectedDate, DateTime today) {
    if (_selectedDate.day - today.day < 0) {
      // (_selectedDate.day - today.day) * -1;

      if (_selectedDate.day - today.day == -1) {
        // print("yesterdat");
        return const Text("yesterday");
      } else {
        // print(('${(_selectedDate.day - today.day) * -1} day(s) ago'));
        return Text('${(_selectedDate.day - today.day) * -1} day(s) ago');
      }
    } else if (_selectedDate.day - today.day > 0) {
      if (_selectedDate.day - today.day == 1) {
        return const Text("tomorrow");
      } else {
        // print('in ${_selectedDate.day - today.day} day(s)');
        return Text('in ${_selectedDate.day - today.day} day(s)');
      }
    } else {
      return const Text("today");
    }
  }

  alarmFun() {
    print("[] Hello, world! isolateunction='");
  }
}

// void _schedulePeriodicAlarm() async {
//   await AndroidAlarmManager.oneShot(
//       Duration(seconds: 10), 0, _periodicTaskCallback);
// }

_periodicTaskCallback() {
  print("Periodic Task Running");
}
