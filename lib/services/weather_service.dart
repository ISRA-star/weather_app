import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherService {
  final String apiKey = '13e4c35d953e20901d347a415b6d2669';

  final String baseUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/https://api.openweathermap.org/data/2.5/weather'
      : 'https://api.openweathermap.org/data/2.5/weather';

  final String forecastUrl = kIsWeb
      ? 'https://cors-anywhere.herokuapp.com/https://api.openweathermap.org/data/2.5/forecast'
      : 'https://api.openweathermap.org/data/2.5/forecast';

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = '$baseUrl?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('City not found!');
    }
  }

  Future<List<Map<String, dynamic>>> getForecast(String city) async {
    final url = '$forecastUrl?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List allItems = data['list'];
      final List<Map<String, dynamic>> daily = [];
      for (int i = 0; i < allItems.length; i += 8) {
        daily.add(Map<String, dynamic>.from(allItems[i]));
        if (daily.length == 7) break;
      }
      return daily;
    } else {
      throw Exception('Forecast not found!');
    }
  }
}