import 'package:json_annotation/json_annotation.dart';

part 'device_info.g.dart';

@JsonSerializable(explicitToJson: true)
class AppDeviceInfo {
  final String id;
  final String brand;
  final String manufacturer;
  final String model;

  AppDeviceInfo(this.id, this.brand, this.manufacturer, this.model);
  
  factory AppDeviceInfo.fromJson(Map<String, dynamic> json) =>_$AppDeviceInfoFromJson(json);
  
  Map<String, dynamic> toJson()=>_$AppDeviceInfoToJson(this);

}