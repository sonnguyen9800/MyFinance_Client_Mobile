import 'package:json_annotation/json_annotation.dart';

part 'ping_model.g.dart';

@JsonSerializable()
class PingResponse {
  @JsonKey(name: 'version')
  final String version;

  @JsonKey(name: 'go_version')
  final String goVersion;

  @JsonKey(name: 'server_code')
  final String serverCode;

  @JsonKey(name: 'server_env')
  final String serverEnv;

  PingResponse({
    required this.version,
    required this.goVersion,
    required this.serverCode,
    required this.serverEnv,
  });

  factory PingResponse.fromJson(Map<String, dynamic> json) =>
      _$PingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PingResponseToJson(this);
}
