import 'package:flutter/material.dart';

class Cylinder {
  final String tag;
  final String size;
  final double percent;

  const Cylinder({
    required this.tag,
    required this.size,
    required this.percent,
  });

  factory Cylinder.fromJson(Map<String, dynamic> json) {
    return Cylinder(
      tag: json['tag'],
      size: json['size'],
      percent: json['percent'] ?? 0.0,
    );
  }

  static List<Cylinder> listFromJson(List<dynamic> json) {
    List<Cylinder> cylinders = [];
    for (var cylinderJson in json) {
      cylinders.add(Cylinder.fromJson(cylinderJson));
    }
    return cylinders;
  }
}
