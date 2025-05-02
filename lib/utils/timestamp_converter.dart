import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<Timestamp, Map<String, dynamic>> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Map<String, dynamic> json) {
    return json['seconds'] != null
        ? Timestamp.fromMillisecondsSinceEpoch(json['seconds'] * 1000)
        : Timestamp.now();
  }

  @override
  Map<String, dynamic> toJson(Timestamp timestamp) {
    return {
      'seconds': timestamp.seconds,
      'nanoseconds': timestamp.nanoseconds,
    };
  }
}
