import 'package:json_annotation/json_annotation.dart';

part 'ping_model.g.dart';

@JsonSerializable()
class PingResponse {
  final String version;
  final String goVersion;
  final String serverCode;
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
