import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/hourly_forcast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_icons/weather_icons.dart';

import 'secrets.dart';
//import 'package:weather_icons/weather_icons.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  final TextEditingController _cityController = TextEditingController();
  String _cityName = 'London';

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final result = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$_cityName&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(result.body);

      if (data['cod'] != '200') {
        throw data['message'];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  void _searchCity() {
    setState(() {
      _cityName = _cityController.text.trim(); // Update city name
      weather = getCurrentWeather(); // Fetch new data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mausam - The Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // Here search section will come to search a city
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController, // Bind controller
                    decoration: const InputDecoration(
                      labelText: "Enter City",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchCity(), // Handle "Enter" key
                  ),
                ),
                IconButton(
                  onPressed: _searchCity, // Handle search button press
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main card
            Expanded(
              child: FutureBuilder(
                future: weather,
                builder: (context, snapshot) {
                  print(snapshot);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator.adaptive());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final data = snapshot.data!;
                  final currentWeatherData = data['list'][0];
                  final currentTemp = currentWeatherData['main']['temp'] - 273.15;
                  final currentSky = data['list'][0]['weather'][0]['main'];
                  final currentPressure = currentWeatherData['main']['pressure'];
                  final currentWindSpeed = currentWeatherData['wind']['speed'];
                  final currentHumidity = currentWeatherData['main']['humidity'];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Main card
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        ("${currentTemp.toStringAsFixed(2)} °C"),
                                        style: TextStyle(
                                            fontSize: 32, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      Icon(
                                        currentSky == 'Clouds' || currentSky == 'Rain'
                                            ? Icons.cloud
                                            : Icons.sunny,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "$currentSky",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Hourly Forecast",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Weather forecast cards
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: 7,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final hourlyForecastData = data['list'][index + 1];
                              final hourlySky = data['list'][index + 1]['weather'][0]['main'];
                              final time = DateTime.parse(hourlyForecastData['dt_txt']);

                              return HourlyForecastItem(
                                icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                    ? WeatherIcons.cloud
                                    : Icons.wb_sunny,
                                label: DateFormat.j().format(time),
                                value:
                                    (hourlyForecastData['main']['temp'] - 273.15)
                                            .toStringAsFixed(2) +
                                        " °C",
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Additional Information",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  size: 50,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Humidity",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$currentHumidity %",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.air,
                                  size: 50,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Wind",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$currentWindSpeed",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 50,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Pressure",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$currentPressure mb",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}