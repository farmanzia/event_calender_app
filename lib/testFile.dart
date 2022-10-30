import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'notification_service.dart';

class SendNot extends StatefulWidget {
  const SendNot({Key? key}) : super(key: key);

  @override
  State<SendNot> createState() => _SendNotState();
}

class _SendNotState extends State<SendNot> {
  NotificationService notificationService = NotificationService();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  final TextEditingController _date = TextEditingController();
  final TextEditingController _time = TextEditingController();

  DateTime dateTime = DateTime.now();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    notificationService.androidIntializeNotification();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // const IOSInitializationSettings iosInitializationSettings =
    //     IOSInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: null,
      macOS: null,
      linux: null,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: (dataYouNeedToUseWhenNotificationIsClicked) {},
    );
  }

  showNotification() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "ScheduleNotification001",
      "Notify Me",
      importance: Importance.high,
    );

    // const IOSNotificationDetails iosNotificationDetails =
    //     IOSNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: null,
      macOS: null,
      linux: null,
    );

    flutterLocalNotificationsPlugin.show(
        01, _title.text, _desc.text, notificationDetails);

    // tz.initializeTimeZones();
    // final tz.TZDateTime scheduledAt = tz.TZDateTime.from(dateTime, tz.local);

    // flutterLocalNotificationsPlugin.zonedSchedule(
    //     01, _title.text, _desc.text, scheduledAt, notificationDetails,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.wallClockTime,
    //     androidAllowWhileIdle: true,
    //     payload: 'Ths s the data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () {
                    // notificationService.sendSheduleNotification(
                    //     DateTime.now().add(Duration(seconds: 10)));
                    // notificationService.sendNotification(
                    //     "this is title", "this is body");
                  },
                  child: Text("Test Me")),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  label: Text("Notification Title"),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _desc,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  label: Text("Notification Description"),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _date,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: InkWell(
                      child: Icon(Icons.date_range),
                      onTap: () async {
                        final DateTime? newlySelectedDate =
                            await showDatePicker(
                          context: context,
                          initialDate: dateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2095),
                        );

                        if (newlySelectedDate == null) {
                          return;
                        }

                        setState(() {
                          dateTime = newlySelectedDate;
                          // _date.text =
                          //     "${dateTime.year}/${dateTime.month}/${dateTime.day}";
                        });
                      },
                    ),
                    label: Text("Date")),
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextField(
                controller: _time,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: InkWell(
                      child: const Icon(
                        Icons.timer_outlined,
                      ),
                      onTap: () async {
                        final TimeOfDay? slectedTime = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());

                        if (slectedTime == null) {
                          return;
                        }

                        _time.text =
                            "${slectedTime.hour}:${slectedTime.minute}";

                        DateTime newDT = DateTime(
                          dateTime.year,
                          dateTime.month,
                          dateTime.day,
                          slectedTime.hour,
                          slectedTime.minute,
                        );
                        setState(() {
                          dateTime = newDT;
                        });
                      },
                    ),
                    label: Text("Time")),
              ),
              const SizedBox(
                height: 24.0,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                  ),
                  onPressed: showNotification,
                  child: Text("Show Notification")),
            ],
          ),
        ),
      ),
    );
  }
}
