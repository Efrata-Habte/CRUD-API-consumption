import 'package:crud_api_consumption_http/models/country.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServices{
  static const String baseUrl = 'https://restcountries.com/v3.1/all?fields=name,capital,currencies';

  static Future <List<Country>> getCountries() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200){
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Country.fromJson(e)).toList();
    }
    else{
      throw Exception("Failed to load countries");
    }
  }

  static Future <Country> getCountry(String name) async{
    final response = await http.get(Uri.parse('$baseUrl&name=$name'));

    if (response.statusCode == 200){
      return Country.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception("Failed to load country");
    }
  }
}