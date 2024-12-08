// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PingResponse _$PingResponseFromJson(Map<String, dynamic> json) => PingResponse(
      version: json['version'] as String,
      goVersion: json['goVersion'] as String,
      serverCode: json['serverCode'] as String,
      serverEnv: json['serverEnv'] as String,
    );

Map<String, dynamic> _$PingResponseToJson(PingResponse instance) =>
    <String, dynamic>{
      'version': instance.version,
      'goVersion': instance.goVersion,
      'serverCode': instance.serverCode,
      'serverEnv': instance.serverEnv,
    };
