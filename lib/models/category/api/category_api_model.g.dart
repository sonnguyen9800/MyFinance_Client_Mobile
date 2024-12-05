// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryUpdateRequest _$CategoryUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    CategoryUpdateRequest(
      name: json['name'] as String,
      color: json['color'] as String,
      iconName: json['icon_name'] as String,
    );

Map<String, dynamic> _$CategoryUpdateRequestToJson(
        CategoryUpdateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
      'icon_name': instance.iconName,
    };
