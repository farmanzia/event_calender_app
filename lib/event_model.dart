// To parse this JSON data, do
//
//     final event = eventFromJson(jsonString);

import 'dart:convert';

Map<String, List<Event>> eventFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) => MapEntry<String, List<Event>>(
        k, List<Event>.from(v.map((x) => Event.fromJson(x)))));

String eventToJson(Map<String, List<Event>> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(
        k, List<dynamic>.from(v.map((x) => x.toJson())))));

class Event {
  Event({
    this.eventDescp,
    this.eventTitle,
    this.time,
  });

  String? eventDescp;
  String? eventTitle;
  String? time;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        eventDescp: json["eventDescp"],
        eventTitle: json["eventTitle"],
        time: json["time"],
      );

  Map<String, dynamic> toJson() => {
        "eventDescp": eventDescp,
        "eventTitle": eventTitle,
        "time": time,
      };
}
