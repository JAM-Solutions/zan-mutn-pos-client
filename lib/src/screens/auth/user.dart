import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String email;

  User(this.id, this.firstName, this.lastName, this.email);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}