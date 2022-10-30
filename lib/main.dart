import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login.dart';

 Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized;
  await Firebase.initializeApp();
  return runApp(MyApp());
}

/// The app which hosts the home page which contains the calendar on it.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calendar Demo',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: LogIn()
        // / SendNot(),
        //
        // EventCalendarScreen(),
        );
  }
}
//
// /// The hove page which hosts the calendar
// class MyHomePage extends StatefulWidget {
//   /// Creates the home page to display teh calendar widget.
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: SfCalendar(
//           showWeekNumber: true,
//           view: CalendarView.month,
//           dataSource: MeetingDataSource(_getDataSource()),
//           cellEndPadding: -1,
//           showNavigationArrow: true,
//           onTap: ((calendarTapDetails) {
//             CalendarTapDetails(appointments, date, element, resource) {
//               log(date);
//             }
//           }),
//           // by default the month appointment display mode set as Indicator, we can
//           // change the display mode as appointment using the appointment display
//           // mode property
//           monthViewSettings: const MonthViewSettings(
//               appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
//               showAgenda: true),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text("Add Event"),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         TextFormField(
//                           decoration: InputDecoration(hintText: "event name"),
//                         ),
//                       ],
//                     ),
//                     actions: [
//                       TextButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text("Cancel")),
//                       ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text("Save"))
//                     ],
//                   );
//                 });
//           },
//           child: Icon(Icons.add),
//         ),
//       ),
//     );
//   }
//
//   List<Meeting> _getDataSource() {
//     final List<Meeting> meetings = <Meeting>[];
//
//     final DateTime today = DateTime.now();
//     final DateTime startTime = DateTime(today.year, today.month, 12, 9);
//     final DateTime endTime = startTime.add(const Duration(hours: 2));
//
//     meetings.add(Meeting(
//         'Conference 1', startTime, endTime, const Color(0xFF0F8644), false));
//
//     meetings.add(Meeting(
//         'Conference 1',
//         DateTime(today.year, today.month, today.day, 4),
//         endTime,
//         const Color(0xFF0F8644),
//         false));
//
//     // meetings.add(
//     //     Meeting('Conf 2', startTime, endTime, const Color(0xFF0F8644), false));
//
//     return meetings;
//   }
// }
//
// /// An object to set the appointment collection data source to calendar, which
// /// used to map the custom appointment data to the calendar appointment, and
// /// allows to add, remove or reset the appointment collection.
// class MeetingDataSource extends CalendarDataSource {
//   /// Creates a meeting data source, which used to set the appointment
//   /// collection to the calendar
//   MeetingDataSource(List<Meeting> source) {
//     appointments = source;
//   }
//
//   @override
//   DateTime getStartTime(int index) {
//     return _getMeetingData(index).from;
//   }
//
//   @override
//   DateTime getEndTime(int index) {
//     return _getMeetingData(index).to;
//   }
//
//   @override
//   String getSubject(int index) {
//     return _getMeetingData(index).eventName;
//   }
//
//   @override
//   Color getColor(int index) {
//     return _getMeetingData(index).background;
//   }
//
//   @override
//   bool isAllDay(int index) {
//     return _getMeetingData(index).isAllDay;
//   }
//
//   Meeting _getMeetingData(int index) {
//     final dynamic meeting = appointments![index];
//     late final Meeting meetingData;
//     if (meeting is Meeting) {
//       meetingData = meeting;
//     }
//
//     return meetingData;
//   }
// }
//
// /// Custom business object class which contains properties to hold the detailed
// /// information about the event data which will be rendered in calendar.
// class Meeting {
//   /// Creates a meeting class with required details.
//   Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);
//
//   /// Event name which is equivalent to subject property of [Appointment].
//   String eventName;
//
//   /// From which is equivalent to start time property of [Appointment].
//   DateTime from;
//
//   /// To which is equivalent to end time property of [Appointment].
//   DateTime to;
//
//   /// Background which is equivalent to color property of [Appointment].
//   Color background;
//
//   /// IsAllDay which is equivalent to isAllDay property of [Appointment].
//   bool isAllDay;
// }
