import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(name: '_id')
  final String? id;
  final String name;
  @JsonKey(name: 'icon_name')
  final String iconName;
  final String color;

  Category({
    this.id,
    required this.name,
    required this.iconName,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
