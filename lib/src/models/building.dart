import 'package:json_annotation/json_annotation.dart';

part 'building.g.dart';

@JsonSerializable(explicitToJson: true)
class Building {
  final String houseNumber;
  final int buildingCategoryId;
  final String location;
  final String status;

  Building(this.houseNumber, this.buildingCategoryId, this.location, this.status);

  factory Building.fromJson(Map<String, dynamic> json) =>
      _$BuildingFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingToJson(this);
}
