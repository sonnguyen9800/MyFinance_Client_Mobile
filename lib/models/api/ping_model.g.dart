// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PingResponse _$PingResponseFromJson(Map<String, dynamic> json) => PingResponse(
      version: json['version'] as String,
      goVersion: json['go_version'] as String,
      serverCode: json['server_code'] as String,
      serverEnv: json['server_env'] as String,
    );

Map<String, dynamic> _$PingResponseToJson(PingResponse instance) =>
    <String, dynamic>{
      'version': instance.version,
      'go_version': instance.goVersion,
      'server_code': instance.serverCode,
      'server_env': instance.serverEnv,
    };
