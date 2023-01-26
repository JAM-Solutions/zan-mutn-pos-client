import 'package:json_annotation/json_annotation.dart';

part 'buildings.g.dart';

@JsonSerializable(explicitToJson: true)
class Buildings {
  final String houseNumber;
  final int building_category_id;
  final String location;
  final String status;

  Buildings(this.houseNumber, this.building_category_id, this.location, this.status);

  factory Buildings.fromJson(Map<String, dynamic> json) =>
      _$BuildingsFromJson(json);

  Map<String, dynamic> toJson() => _$BuildingsToJson(this);
}
