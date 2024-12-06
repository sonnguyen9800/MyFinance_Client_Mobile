import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'user_id')
  final String? userId;

  final String name;
  @JsonKey(name: 'icon_name')
  final String iconName;
  final String color;

  Category({
    required this.id,
    this.userId,
    required this.name,
    required this.iconName,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return _$CategoryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
