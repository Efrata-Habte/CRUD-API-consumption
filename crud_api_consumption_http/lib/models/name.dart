import "package:crud_api_consumption_http/models/native_name.dart";

class Name{
  final String common;
  final String official;
  final Map<String, NativeName> nativeName;

  Name({
    required this.common,
    required this.official,
    required this.nativeName,
  });

  factory Name.fromJson(Map <String, dynamic> json){
    return Name(
      common: json["common"],
      official: json["official"],
      nativeName: (json["nativeName"] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          NativeName.fromJson(value),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'common': common,
      'official': official,
      'nativeName': nativeName.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}