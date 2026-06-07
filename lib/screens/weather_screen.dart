import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  Map<String, dynamic>? _weatherData;
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = false;
  final _controller = TextEditingController();
  String _city = 'Karachi';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getWeatherByCity(_city);
      final forecast = await _service.getForecast(_city);
      setState(() {
        _weatherData = data;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: City not found!')),
      );
    }
  }

  String _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('thunder') || condition.contains('storm')) return '⛈️';
    if (condition.contains('rain') || condition.contains('drizzle')) return '🌧️';
    if (condition.contains('snow')) return '❄️';
    if (condition.contains('mist') || condition.contains('fog')) return '🌫️';
    if (condition.contains('overcast')) return '☁️';
    if (condition.contains('cloud')) return '⛅';
    if (condition.contains('clear')) return '☀️';
    return '🌤️';
  }

  List<Color> _getGradient(String condition, int temp) {
    condition = condition.toLowerCase();
    if (condition.contains('thunder') || condition.contains('storm')) {
      return [Color(0xFF0d0d1a), Color(0xFF3a0a6e)];
    }
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return [Color(0xFF0a2a3a), Color(0xFF0d5c7a)];
    }
    if (condition.contains('snow')) {
      return [Color(0xFF2c4a6e), Color(0xFF89c4e1)];
    }
    if (condition.contains('clear') && temp >= 35) {
      return [Color(0xFFb34700), Color(0xFFff8c00)];
    }
    if (condition.contains('clear')) {
      return [Color(0xFF0a3d7a), Color(0xFF1e90ff)];
    }
    if (condition.contains('cloud')) {
      return [Color(0xFF2c3e50), Color(0xFF4ca1af)];
    }
    return [Color(0xFF1a1a2e), Color(0xFF16213e)];
  }

  String _getAdvice(String condition, int temp) {
    condition = condition.toLowerCase();
    if (condition.contains('thunder') || condition.contains('storm')) {
      return '⚠️ Storm Alert! Stay indoors, avoid travel.';
    }
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return '🌂 Rain Alert! Carry an umbrella today.';
    }
    if (condition.contains('snow')) {
      return '❄️ Snow Alert! Roads may be slippery.';
    }
    if (temp >= 40) return '🥵 Extreme Heat! Stay hydrated, avoid going out.';
    if (temp >= 35) return '☀️ Very Hot! Drink plenty of water.';
    if (temp >= 30) return '😓 Hot weather. Light clothes recommended.';
    if (temp <= 5) return '🧥 Very Cold! Wear warm clothes.';
    return '✅ Weather is fine. Have a great day!';
  }

  String _getDayName(String dtTxt) {
    final date = DateTime.parse(dtTxt);
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final condition = _weatherData?['weather']?[0]?['description'] ?? '';
    final temp = (_weatherData?['main']?['temp'] ?? 25).round();
    final gradient = _getGradient(condition, temp);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _buildUI(),
        ),
      ),
    );
  }

  Widget _buildUI() {
    if (_weatherData == null) return const SizedBox();

    final temp = _weatherData!['main']['temp'].round();
    final feels = _weatherData!['main']['feels_like'].round();
    final humidity = _weatherData!['main']['humidity'];
    final wind = _weatherData!['wind']['speed'];
    final desc = _weatherData!['weather'][0]['description'];
    final city = _weatherData!['name'];
    final pressure = _weatherData!['main']['pressure'];
    final icon = _getWeatherIcon(desc);
    final advice = _getAdvice(desc, temp);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [

          // Search bar
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search city...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() => _city = _controller.text);
                  _loadWeather();
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Weather Icon + City + Description
          Text(icon, style: const TextStyle(fontSize: 75)),
          const SizedBox(height: 4),
          Text(city,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          Text(desc.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white60, fontSize: 13, letterSpacing: 2)),

          const SizedBox(height: 10),

          // Temperature
          Text('$temp°C',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 85,
                  fontWeight: FontWeight.w200)),
          Text('Feels like $feels°C',
              style: const TextStyle(color: Colors.white54, fontSize: 14)),

          const SizedBox(height: 12),

          // Advice Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(advice,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),

          const SizedBox(height: 12),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statCard('💧', 'Humidity', '$humidity%'),
              _statCard('💨', 'Wind', '${wind}m/s'),
              _statCard('🌡️', 'Pressure', '${pressure}hPa'),
            ],
          ),

          const SizedBox(height: 20),

          // 7-Day Forecast
          if (_forecast.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('7-Day Forecast',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _forecast.map((item) {
                  final dayName = _getDayName(item['dt_txt']);
                  final dayTemp = item['main']['temp'].round();
                  final dayMin = item['main']['temp_min'].round();
                  final dayIcon = _getWeatherIcon(
                      item['weather'][0]['description']);
                  return Column(
                    children: [
                      Text(dayName,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(dayIcon,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text('$dayTemp°',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      Text('$dayMin°',
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statCard(String icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}