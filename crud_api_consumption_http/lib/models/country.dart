import 'package:crud_api_consumption_http/models/currency.dart';
import 'package:crud_api_consumption_http/models/name.dart';

class Country{
  final Name name;
  final Map<String, Currency> currency;
  final List<String> capitals;

  Country({
    required this.name,
    required this.currency,
    required this.capitals,
  });

  factory Country.fromJson(Map<String, dynamic> json){
    return Country(
      name: Name.fromJson(json["name"]),
      currency: (json["currencies"] as Map<String, dynamic>).map(
        (key,value)=> MapEntry(
          key,
          Currency.fromJson(value)
        ),
      ),
      capitals: List<String>.from(json["capital"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'currencies': currency.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'capital': capitals,
    };
  }
}