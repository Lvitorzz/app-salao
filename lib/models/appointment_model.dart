import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  String id;
  String serviceId;
  String serviceName;
  String clientId;
  String clientName;
  DateTime dateTime;
  Timestamp createdAt;

  Appointment({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.clientId,
    required this.clientName,
    required this.dateTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'clientId': clientId,
        'clientName': clientName,
        'dateTime': Timestamp.fromDate(dateTime),
        'createdAt': createdAt,
      };

  factory Appointment.fromMap(String id, Map<String, dynamic> m) {
    return Appointment(
      id: id,
      serviceId: m['serviceId'] as String,
      serviceName: m['serviceName'] as String,
      clientId: m['clientId'] as String,
      clientName: m['clientName'] as String,
      dateTime: (m['dateTime'] as Timestamp).toDate(),
      createdAt: m['createdAt'] as Timestamp,
    );
  }
}
