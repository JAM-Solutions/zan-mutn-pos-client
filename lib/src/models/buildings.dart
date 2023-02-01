import 'package:json_annotation/json_annotation.dart';

part 'buildings.g.dart';

@JsonSerializable(explicitToJson: true)
class Buildings {
  final String houseNumber;
  final int buildingCategoryid;
  final String location;
  final String status;

  Buildings(this.houseNumber, this.buildingCategoryid, this.location, this.status);

  factory Buildings.fromJson(Map<String, dynamic> json) =>
      _$BuildingsFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingsToJson(this);
}
