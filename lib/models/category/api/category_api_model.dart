import 'package:json_annotation/json_annotation.dart';
part 'category_api_model.g.dart';

@JsonSerializable()
class CategoryUpdateRequest {
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'color')
  final String color;
  @JsonKey(name: 'icon_name')
  final String iconName;

  CategoryUpdateRequest({
    required this.name,
    required this.color,
    required this.iconName,
  });

  factory CategoryUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryUpdateRequestToJson(this);
}
